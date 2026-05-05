import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/character.dart';
import 'package:morse_trainer/data/models/user_progress.dart';
import 'package:morse_trainer/data/repositories/user_progress_repository.dart';
import 'package:morse_trainer/domain/koch/koch_progression_service.dart';
import 'package:morse_trainer/domain/gamification/gamification_service.dart';
import 'package:morse_trainer/domain/spaced_repetition/spaced_repetition_service.dart';
import 'package:morse_trainer/ui/bloc/practice_session_bloc.dart';

class MockKochProgressionService extends Mock implements KochProgressionService {}
class MockGamificationService extends Mock implements GamificationService {}
class MockSpacedRepetitionService extends Mock implements SpacedRepetitionService {}
class MockUserProgressRepository extends Mock implements UserProgressRepository {}

void main() {
  late MockKochProgressionService mockKochService;
  late MockGamificationService mockGamificationService;
  late MockSpacedRepetitionService mockSpacedRepetitionService;
  late MockUserProgressRepository mockUserProgressRepository;

  final testCharacters = [
    Character(id: '1', symbol: 'K', morsePattern: '-.-', kochOrder: 0),
    Character(id: '2', symbol: 'M', morsePattern: '--', kochOrder: 1),
  ];

  setUpAll(() {
    registerFallbackValue(const StartSession(1));
    registerFallbackValue(const SubmitMorsePattern('.-'));
    registerFallbackValue(UserProgress(
      currentLevel: 1,
      currentStreak: 0,
      longestStreak: 0,
      charactersMastered: 0,
      totalSessionsCompleted: 0,
      hasCompletedOnboarding: false,
    ));
  });

  setUp(() {
    mockKochService = MockKochProgressionService();
    mockGamificationService = MockGamificationService();
    mockSpacedRepetitionService = MockSpacedRepetitionService();
    mockUserProgressRepository = MockUserProgressRepository();

    when(() => mockUserProgressRepository.getCurrentLevel()).thenAnswer((_) async => 1);
    when(() => mockUserProgressRepository.getUserProgress())
        .thenAnswer((_) async => _createTestProgress());
    when(() => mockUserProgressRepository.updateUserProgress(any()))
        .thenAnswer((_) async {});
    when(() => mockKochService.getPracticeCharacters(any()))
        .thenAnswer((_) async => testCharacters);
    when(() => mockKochService.recordAttempt(any(), any())).thenAnswer((_) async {});
    when(() => mockSpacedRepetitionService.scheduleReview(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockGamificationService.recordCorrectAnswer())
        .thenAnswer((_) async {});
    when(() => mockGamificationService.recordIncorrectAnswer())
        .thenAnswer((_) async {});
    when(() => mockGamificationService.completeSession()).thenAnswer((_) async {});
    when(() => mockKochService.canAdvanceLevel(any())).thenAnswer((_) async => false);
  });

  group('PracticeSessionBloc', () {
    group('regression: stuck retry state', () {
      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'should enter explicit retry state after wrong answer, not just null',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));

          // Submit wrong pattern (K = '-.-', user sends '.-' = A)
          bloc.add(const SubmitMorsePattern('.-'));
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<PracticeSessionActive>());
          final activeState = state as PracticeSessionActive;

          // First: should show wrong answer (lastAnswerCorrect = false)
          expect(activeState.lastAnswerCorrect, false);
          expect(activeState.isRetrying, false);
        },
      );

      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'should set isRetrying=true during retry delay after wrong answer',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));

          // Submit wrong pattern
          bloc.add(const SubmitMorsePattern('.-'));
        },
        wait: const Duration(milliseconds: 800), // In middle of retry delay (600-1200ms)
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<PracticeSessionActive>());
          final activeState = state as PracticeSessionActive;

          // During retry window: should be retrying
          // isRetrying should be true
          // lastAnswerCorrect should be false (still showing wrong answer)
          expect(activeState.isRetrying, true);
          expect(activeState.lastAnswerCorrect, false);
          // Should still be on same character (index 0)
          expect(activeState.currentIndex, 0);
        },
      );

      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'should NOT replay audio after wrong answer until user is ready',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));

          // Submit wrong pattern
          bloc.add(const SubmitMorsePattern('.-'));

          // Immediately submit correct pattern (during what USED to be the bug)
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const SubmitMorsePattern('-.-')); // Correct K

          // Wait for wrong answer retry (1200ms) + correct answer advance (400ms)
          await Future.delayed(const Duration(milliseconds: 2000));
        },
        verify: (bloc) {
          final state = bloc.state;
          // Should have advanced to character index 1
          expect(state, isA<PracticeSessionActive>());
          final activeState = state as PracticeSessionActive;
          expect(activeState.currentIndex, 1);
          expect(activeState.lastAnswerCorrect, null);
          expect(activeState.correctCount, 1);
        },
      );
    });

    group('correct answer flow', () {
      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'should advance to next character after correct answer',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));

          // Submit correct K pattern
          bloc.add(const SubmitMorsePattern('-.-'));
        },
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<PracticeSessionActive>());
          final activeState = state as PracticeSessionActive;

          expect(activeState.currentIndex, 1); // Advanced to M
          expect(activeState.lastAnswerCorrect, null);
          expect(activeState.correctCount, 1);
          expect(activeState.currentStreak, 1);
        },
      );
    });

    group('state transitions', () {
      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'emits PracticeSessionLoading then PracticeSessionActive on StartSession',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) => bloc.add(const StartSession(1)),
        expect: () => [
          isA<PracticeSessionLoading>(),
          isA<PracticeSessionActive>(),
        ],
      );
    });

    group('edge cases', () {
      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'ignores SubmitMorsePattern when no active session',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) => bloc.add(const SubmitMorsePattern('.-')),
        expect: () => [],
      );

      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'emits PracticeSessionComplete when session ends',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));

          // Submit correct for both characters
          bloc.add(const SubmitMorsePattern('-.-')); // K correct
          await Future.delayed(const Duration(milliseconds: 500));
          bloc.add(const SubmitMorsePattern('--')); // M correct
        },
        wait: const Duration(milliseconds: 1000),
        verify: (bloc) {
          expect(bloc.state, isA<PracticeSessionComplete>());
        },
      );
    });
  });
}

UserProgress _createTestProgress() => UserProgress(
      currentLevel: 1,
      currentStreak: 0,
      longestStreak: 0,
      charactersMastered: 0,
      totalSessionsCompleted: 0,
      hasCompletedOnboarding: false,
    );