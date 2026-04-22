import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/character.dart';
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

class NextCharacter extends PracticeSessionEvent {
  const NextCharacter();
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
  final bool showUnlockNotification;

  const PracticeSessionActive({
    required this.characters,
    required this.currentIndex,
    required this.correctCount,
    required this.totalAnswered,
    required this.currentStreak,
    this.lastAnswerCorrect,
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
    bool? showUnlockNotification,
  }) {
    return PracticeSessionActive(
      characters: characters ?? this.characters,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      currentStreak: currentStreak ?? this.currentStreak,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
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

  PracticeSessionBloc({
    required KochProgressionService kochService,
    required GamificationService gamificationService,
    required SpacedRepetitionService spacedRepetitionService,
  })  : _kochService = kochService,
        _gamificationService = gamificationService,
        _spacedRepetitionService = spacedRepetitionService,
        super(PracticeSessionInitial()) {
    on<StartSession>(_onStartSession);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<NextCharacter>(_onNextCharacter);
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<PracticeSessionState> emit,
  ) async {
    emit(PracticeSessionLoading());

    final characters = await _kochService.getPracticeCharacters(event.level);

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
      final canAdvance = await _kochService.canAdvanceLevel(1); // TODO: Get actual level
      if (canAdvance) {
        await _kochService.unlockNextCharacters(1);
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

    emit(currentState.copyWith(
      currentIndex: currentState.currentIndex + 1,
      lastAnswerCorrect: null,
      showUnlockNotification: false,
    ));
  }
}
