import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/character.dart';
import '../../data/repositories/user_progress_repository.dart';
import '../../domain/koch/koch_progression_service.dart';
import '../../domain/gamification/gamification_service.dart';
import '../../domain/spaced_repetition/spaced_repetition_service.dart';

// Events
abstract class PracticeSessionEvent extends Equatable {
  const PracticeSessionEvent();

  @override
  List<Object?> get props => [];
}

class StartSession extends PracticeSessionEvent {
  final int level;
  const StartSession(this.level);
}

class PlayCharacter extends PracticeSessionEvent {
  const PlayCharacter();
}

class SubmitAnswer extends PracticeSessionEvent {
  final String answer;
  const SubmitAnswer(this.answer);
}

class SubmitMorsePattern extends PracticeSessionEvent {
  final String morsePattern;
  const SubmitMorsePattern(this.morsePattern);
}

class NextCharacter extends PracticeSessionEvent {
  const NextCharacter();
}

class PlayCurrentCharacter extends PracticeSessionEvent {
  const PlayCurrentCharacter();
}

class CompleteOnboarding extends PracticeSessionEvent {
  final bool skipIntro;
  const CompleteOnboarding({this.skipIntro = false});
}

// States
abstract class PracticeSessionState extends Equatable {
  const PracticeSessionState();

  @override
  List<Object?> get props => [];
}

class PracticeSessionInitial extends PracticeSessionState {}

class PracticeSessionLoading extends PracticeSessionState {}

class PracticeSessionActive extends PracticeSessionState {
  final List<Character> characters;
  final int currentIndex;
  final int correctCount;
  final int totalAnswered;
  final int currentStreak;
  final bool? lastAnswerCorrect;
  final bool isRetrying;
  final bool showUnlockNotification;

  const PracticeSessionActive({
    required this.characters,
    required this.currentIndex,
    required this.correctCount,
    required this.totalAnswered,
    required this.currentStreak,
    this.lastAnswerCorrect,
    this.isRetrying = false,
    this.showUnlockNotification = false,
  });

  Character? get currentCharacter =>
      currentIndex < characters.length ? characters[currentIndex] : null;

  double get accuracy =>
      totalAnswered > 0 ? correctCount / totalAnswered : 0.0;

  bool get isComplete => currentIndex >= characters.length;

  PracticeSessionActive copyWith({
    List<Character>? characters,
    int? currentIndex,
    int? correctCount,
    int? totalAnswered,
    int? currentStreak,
    bool? lastAnswerCorrect,
    bool? isRetrying,
    bool? showUnlockNotification,
  }) {
    return PracticeSessionActive(
      characters: characters ?? this.characters,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      currentStreak: currentStreak ?? this.currentStreak,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      isRetrying: isRetrying ?? this.isRetrying,
      showUnlockNotification: showUnlockNotification ?? this.showUnlockNotification,
    );
  }

  @override
  List<Object?> get props => [
        characters,
        currentIndex,
        correctCount,
        totalAnswered,
        currentStreak,
        lastAnswerCorrect,
        isRetrying,
        showUnlockNotification,
      ];
}

class PracticeSessionComplete extends PracticeSessionState {
  final int correctCount;
  final int totalQuestions;
  final double accuracy;
  final bool unlockedNextLevel;

  const PracticeSessionComplete({
    required this.correctCount,
    required this.totalQuestions,
    required this.accuracy,
    required this.unlockedNextLevel,
  });

  @override
  List<Object?> get props => [correctCount, totalQuestions, accuracy, unlockedNextLevel];
}

// BLoC
class PracticeSessionBloc
    extends Bloc<PracticeSessionEvent, PracticeSessionState> {
  final KochProgressionService _kochService;
  final GamificationService _gamificationService;
  final SpacedRepetitionService _spacedRepetitionService;
  final UserProgressRepository _userProgressRepository;
  int _currentLevel = 1;

  PracticeSessionBloc({
    required KochProgressionService kochService,
    required GamificationService gamificationService,
    required SpacedRepetitionService spacedRepetitionService,
    required UserProgressRepository userProgressRepository,
  })  : _kochService = kochService,
        _gamificationService = gamificationService,
        _spacedRepetitionService = spacedRepetitionService,
        _userProgressRepository = userProgressRepository,
        super(PracticeSessionInitial()) {
    on<StartSession>(_onStartSession, transformer: sequential());
    on<SubmitAnswer>(_onSubmitAnswer, transformer: sequential());
    on<SubmitMorsePattern>(_onSubmitMorsePattern, transformer: sequential());
    on<NextCharacter>(_onNextCharacter, transformer: sequential());
    on<PlayCurrentCharacter>(_onPlayCurrentCharacter, transformer: sequential());
    on<CompleteOnboarding>(_onCompleteOnboarding, transformer: sequential());
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<PracticeSessionState> emit,
  ) async {
    final progress = await _userProgressRepository.getUserProgress();
    await _userProgressRepository.updateUserProgress(
      progress.copyWith(
        hasCompletedOnboarding: true,
        skipIntroOnboarding: event.skipIntro,
      ),
    );
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(PracticeSessionLoading());
    _currentLevel = event.level > 0 ? event.level : await _userProgressRepository.getCurrentLevel();

    final characters = await _kochService.getPracticeCharacters(_currentLevel);

    emit(PracticeSessionActive(
      characters: characters,
      currentIndex: 0,
      correctCount: 0,
      totalAnswered: 0,
      currentStreak: 0,
    ));
  }

  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<PracticeSessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PracticeSessionActive) return;

    final character = currentState.currentCharacter;
    if (character == null) return;

    final isCorrect = event.answer.toUpperCase() == character.symbol;

    await _kochService.recordAttempt(character.symbol, isCorrect);
    await _spacedRepetitionService.scheduleReview(character.symbol, isCorrect);

    if (isCorrect) {
      await _gamificationService.recordCorrectAnswer();
    } else {
      await _gamificationService.recordIncorrectAnswer();
    }

    final newCorrectCount = currentState.correctCount + (isCorrect ? 1 : 0);
    final newStreak = isCorrect ? currentState.currentStreak + 1 : 0;

    // Check if we should unlock next level
    bool unlockedNextLevel = false;
    if (currentState.isComplete) {
      final canAdvance = await _kochService.canAdvanceLevel(_currentLevel);
      if (canAdvance) {
        await _kochService.unlockNextCharacters(_currentLevel);
        unlockedNextLevel = true;
      }
    }

    emit(currentState.copyWith(
      correctCount: newCorrectCount,
      totalAnswered: currentState.totalAnswered + 1,
      currentStreak: newStreak,
      lastAnswerCorrect: isCorrect,
      showUnlockNotification: unlockedNextLevel,
    ));

    // Auto-advance to next character after correct answer
    if (isCorrect) {
      await Future.delayed(const Duration(milliseconds: 400));
      add(const NextCharacter());
    }
  }

  Future<void> _onSubmitMorsePattern(
    SubmitMorsePattern event,
    Emitter<PracticeSessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PracticeSessionActive) return;

    final character = currentState.currentCharacter;
    if (character == null) return;

    final expectedPattern = character.morsePattern.toUpperCase();
    final userPattern = event.morsePattern.toUpperCase();

    final isCorrect = userPattern == expectedPattern;

    await _kochService.recordAttempt(character.symbol, isCorrect);
    await _spacedRepetitionService.scheduleReview(character.symbol, isCorrect);

    if (isCorrect) {
      await _gamificationService.recordCorrectAnswer();
    } else {
      await _gamificationService.recordIncorrectAnswer();
    }

    final newCorrectCount = currentState.correctCount + (isCorrect ? 1 : 0);
    final newStreak = isCorrect ? currentState.currentStreak + 1 : 0;

    bool unlockedNextLevel = false;
    if (currentState.isComplete) {
      final canAdvance = await _kochService.canAdvanceLevel(_currentLevel);
      if (canAdvance) {
        await _kochService.unlockNextCharacters(_currentLevel);
        unlockedNextLevel = true;
      }
    }

    // Emit feedback state first
    emit(currentState.copyWith(
      correctCount: newCorrectCount,
      totalAnswered: currentState.totalAnswered + 1,
      currentStreak: newStreak,
      lastAnswerCorrect: isCorrect,
      isRetrying: false,
      showUnlockNotification: unlockedNextLevel,
    ));

    // Auto-advance or auto-retry with brief delay
    await Future.delayed(Duration(milliseconds: isCorrect ? 400 : 600));

    // Capture updated state after first emit so subsequent emits don't
    // double-count totalAnswered using the stale currentState.
    final afterFeedback = state as PracticeSessionActive;

    if (isCorrect) {
      final nextIndex = afterFeedback.currentIndex + 1;
      if (nextIndex >= afterFeedback.characters.length) {
        // Session complete
        await _gamificationService.completeSession();
        emit(PracticeSessionComplete(
          correctCount: afterFeedback.correctCount,
          totalQuestions: afterFeedback.totalAnswered,
          accuracy: afterFeedback.accuracy,
          unlockedNextLevel: afterFeedback.showUnlockNotification,
        ));
        return;
      }

      // Advance to next character
      emit(PracticeSessionActive(
        characters: afterFeedback.characters,
        currentIndex: nextIndex,
        correctCount: afterFeedback.correctCount,
        totalAnswered: afterFeedback.totalAnswered,
        currentStreak: afterFeedback.currentStreak,
        lastAnswerCorrect: null,
        isRetrying: false,
        showUnlockNotification: false,
      ));
    } else {
      // Wrong answer: set retry state, stay on same character
      emit(afterFeedback.copyWith(
        lastAnswerCorrect: false,
        isRetrying: true,
        showUnlockNotification: false,
      ));

      // Wait for retry window, then reset for retry input
      await Future.delayed(const Duration(milliseconds: 600));
      final afterRetry = state as PracticeSessionActive;
      emit(PracticeSessionActive(
        characters: afterRetry.characters,
        currentIndex: afterRetry.currentIndex,
        correctCount: afterRetry.correctCount,
        totalAnswered: afterRetry.totalAnswered,
        currentStreak: afterRetry.currentStreak,
        lastAnswerCorrect: null,
        isRetrying: false,
        showUnlockNotification: false,
      ));
    }
  }

  Future<void> _onPlayCurrentCharacter(
    PlayCurrentCharacter event,
    Emitter<PracticeSessionState> emit,
  ) async {
    // Handled by UI - this event is for triggering audio playback
  }

  Future<void> _onNextCharacter(
    NextCharacter event,
    Emitter<PracticeSessionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PracticeSessionActive) return;

    if (currentState.isComplete) {
      await _gamificationService.completeSession();
      emit(PracticeSessionComplete(
        correctCount: currentState.correctCount,
        totalQuestions: currentState.totalAnswered,
        accuracy: currentState.accuracy,
        unlockedNextLevel: currentState.showUnlockNotification,
      ));
      return;
    }

    emit(PracticeSessionActive(
      characters: currentState.characters,
      currentIndex: currentState.currentIndex + 1,
      correctCount: currentState.correctCount,
      totalAnswered: currentState.totalAnswered,
      currentStreak: currentState.currentStreak,
      lastAnswerCorrect: null,
      isRetrying: false,
      showUnlockNotification: false,
    ));
  }
}
