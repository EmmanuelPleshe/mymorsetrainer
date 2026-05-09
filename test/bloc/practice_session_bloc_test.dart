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
        'emits feedback then retry then ready after wrong answer',
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
        wait: const Duration(milliseconds: 1400),
        expect: () => [
          isA<PracticeSessionLoading>(),
          isA<PracticeSessionActive>(),
          isA<PracticeSessionActive>().having(
            (s) => (s as PracticeSessionActive).lastAnswerCorrect,
            'lastAnswerCorrect',
            false,
          ),
          isA<PracticeSessionActive>().having(
            (s) => (s as PracticeSessionActive).isRetrying,
            'isRetrying',
            true,
          ),
          isA<PracticeSessionActive>().having(
            (s) => (s as PracticeSessionActive).lastAnswerCorrect,
            'lastAnswerCorrect',
            null,
          ),
        ],
      );

      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'allows retry after wrong answer then advances on correct',
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
          await Future.delayed(const Duration(milliseconds: 1300));

          // Retry with correct pattern
          bloc.add(const SubmitMorsePattern('-.-'));
        },
        wait: const Duration(milliseconds: 1000),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<PracticeSessionActive>());
          final activeState = state as PracticeSessionActive;
          expect(activeState.currentIndex, 1);
          expect(activeState.lastAnswerCorrect, null);
          expect(activeState.correctCount, 1);
          expect(activeState.totalAnswered, 2);
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
        'ignores SubmitAnswer when no active session',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) => bloc.add(const SubmitAnswer('K')),
        expect: () => [],
      );

      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'ignores SubmitAnswer when character is null',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));
          // Advance past all characters so currentCharacter is null
          bloc.add(const NextCharacter());
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const NextCharacter());
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const SubmitAnswer('K'));
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<PracticeSessionLoading>(),
          isA<PracticeSessionActive>(),
          isA<PracticeSessionActive>(),
          isA<PracticeSessionActive>(),
        ],
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

    group('SubmitAnswer', () {
      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'correct answer advances via NextCharacter',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const SubmitAnswer('K'));
        },
        wait: const Duration(milliseconds: 600),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<PracticeSessionActive>());
          final active = state as PracticeSessionActive;
          expect(active.currentIndex, 1);
          expect(active.correctCount, 1);
          expect(active.currentStreak, 1);
          expect(active.lastAnswerCorrect, null);
        },
      );

      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'wrong answer resets streak and emits feedback',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) async {
          bloc.add(const StartSession(1));
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const SubmitAnswer('X'));
        },
        wait: const Duration(milliseconds: 200),
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<PracticeSessionActive>());
          final active = state as PracticeSessionActive;
          expect(active.correctCount, 0);
          expect(active.currentStreak, 0);
          expect(active.totalAnswered, 1);
          expect(active.lastAnswerCorrect, false);
        },
      );
    });

    group('CompleteOnboarding', () {
      blocTest<PracticeSessionBloc, PracticeSessionState>(
        'updates user progress with skipIntro flag',
        build: () => PracticeSessionBloc(
          kochService: mockKochService,
          gamificationService: mockGamificationService,
          spacedRepetitionService: mockSpacedRepetitionService,
          userProgressRepository: mockUserProgressRepository,
        ),
        act: (bloc) => bloc.add(const CompleteOnboarding(skipIntro: true)),
        verify: (_) {
          final captured = verify(() => mockUserProgressRepository.updateUserProgress(captureAny())).captured.single as UserProgress;
          expect(captured.hasCompletedOnboarding, true);
          expect(captured.skipIntroOnboarding, true);
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