import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/user_progress.dart';
import 'package:morse_trainer/data/repositories/user_progress_repository.dart';
import 'package:morse_trainer/domain/gamification/gamification_service.dart';

class MockUserProgressRepository extends Mock implements UserProgressRepository {}

class FakeUserProgress extends Fake implements UserProgress {}

void main() {
  late MockUserProgressRepository mockRepo;
  late GamificationService service;

  setUpAll(() {
    registerFallbackValue(FakeUserProgress());
  });

  setUp(() {
    mockRepo = MockUserProgressRepository();
    service = GamificationService(mockRepo);
  });

  group('recordCorrectAnswer', () {
    test('increments streak and awards points', () async {
      when(() => mockRepo.incrementStreak()).thenAnswer((_) async {});
      when(() => mockRepo.getUserProgress()).thenAnswer((_) async => _progress(currentStreak: 3));
      when(() => mockRepo.addPoints(any())).thenAnswer((_) async {});

      await service.recordCorrectAnswer();

      verify(() => mockRepo.incrementStreak()).called(1);
      verify(() => mockRepo.addPoints(10)).called(1); // base points
    });

    test('awards streak bonus at milestone', () async {
      when(() => mockRepo.incrementStreak()).thenAnswer((_) async {});
      when(() => mockRepo.getUserProgress()).thenAnswer((_) async => _progress(currentStreak: 10));
      when(() => mockRepo.addPoints(any())).thenAnswer((_) async {});

      await service.recordCorrectAnswer();

      verify(() => mockRepo.addPoints(10)).called(1); // base
      verify(() => mockRepo.addPoints(100)).called(1); // streak bonus
    });

    test('no streak bonus below 5', () async {
      when(() => mockRepo.incrementStreak()).thenAnswer((_) async {});
      when(() => mockRepo.getUserProgress()).thenAnswer((_) async => _progress(currentStreak: 2));
      when(() => mockRepo.addPoints(any())).thenAnswer((_) async {});

      await service.recordCorrectAnswer();

      verify(() => mockRepo.addPoints(10)).called(1);
      verifyNever(() => mockRepo.addPoints(50));
    });
  });

  group('recordIncorrectAnswer', () {
    test('resets streak', () async {
      when(() => mockRepo.resetStreak()).thenAnswer((_) async {});

      await service.recordIncorrectAnswer();

      verify(() => mockRepo.resetStreak()).called(1);
    });
  });

  group('completeSession', () {
    test('increments completed sessions', () async {
      when(() => mockRepo.completeSession()).thenAnswer((_) async {});

      await service.completeSession();

      verify(() => mockRepo.completeSession()).called(1);
    });
  });

  group('levelUp', () {
    test('increments current level', () async {
      when(() => mockRepo.getUserProgress()).thenAnswer((_) async => _progress(currentLevel: 3));
      when(() => mockRepo.updateUserProgress(any())).thenAnswer((_) async {});

      await service.levelUp();

      final captured = verify(() => mockRepo.updateUserProgress(captureAny())).captured.single as UserProgress;
      expect(captured.currentLevel, 4);
    });
  });

  group('getStats', () {
    test('returns progress as map', () async {
      when(() => mockRepo.getUserProgress()).thenAnswer(
        (_) async => _progress(
          totalPoints: 100,
          currentStreak: 5,
          longestStreak: 10,
          currentLevel: 3,
          charactersMastered: 8,
          totalSessionsCompleted: 20,
        ),
      );

      final stats = await service.getStats();

      expect(stats['totalPoints'], 100);
      expect(stats['currentStreak'], 5);
      expect(stats['longestStreak'], 10);
      expect(stats['currentLevel'], 3);
      expect(stats['charactersMastered'], 8);
      expect(stats['totalSessionsCompleted'], 20);
    });
  });

  group('awardPointsForCorrectAnswer', () {
    test('awards base points with default difficulty', () async {
      when(() => mockRepo.addPoints(10)).thenAnswer((_) async {});

      await service.awardPointsForCorrectAnswer();

      verify(() => mockRepo.addPoints(10)).called(1);
    });

    test('awards scaled points with difficulty', () async {
      when(() => mockRepo.addPoints(30)).thenAnswer((_) async {});

      await service.awardPointsForCorrectAnswer(difficulty: 3);

      verify(() => mockRepo.addPoints(30)).called(1);
    });
  });

  group('awardStreakBonus', () {
    test('no bonus below 5', () async {
      when(() => mockRepo.addPoints(any())).thenAnswer((_) async {});

      await service.awardStreakBonus(4);

      verifyNever(() => mockRepo.addPoints(any()));
    });

    test('50 bonus at 5 streak', () async {
      when(() => mockRepo.addPoints(50)).thenAnswer((_) async {});

      await service.awardStreakBonus(5);

      verify(() => mockRepo.addPoints(50)).called(1);
    });

    test('500 bonus at 50+ streak', () async {
      when(() => mockRepo.addPoints(500)).thenAnswer((_) async {});

      await service.awardStreakBonus(50);

      verify(() => mockRepo.addPoints(500)).called(1);
    });
  });
}

UserProgress _progress({
  int totalPoints = 0,
  int currentStreak = 0,
  int longestStreak = 0,
  int currentLevel = 1,
  int charactersMastered = 0,
  int totalSessionsCompleted = 0,
}) {
  return UserProgress(
    totalPoints: totalPoints,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    currentLevel: currentLevel,
    charactersMastered: charactersMastered,
    totalSessionsCompleted: totalSessionsCompleted,
  );
}
