import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:morse_trainer/data/database/database_helper.dart';
import 'package:morse_trainer/data/models/user_progress.dart';
import 'package:morse_trainer/data/repositories/user_progress_repository.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockDatabase extends Mock implements Database {}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;
  late UserProgressRepository repo;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();
    repo = UserProgressRepository(dbHelper: mockDbHelper);

    when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);
    when(() => mockDb.insert(any(), any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
        .thenAnswer((_) async => 1);
    when(() => mockDb.update(any(), any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
        .thenAnswer((_) async => 1);
  });

  group('getUserProgress', () {
    test('returns default progress when no record exists', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => []);

      final result = await repo.getUserProgress();

      expect(result.id, 'current');
      expect(result.totalPoints, 0);
      expect(result.currentLevel, 1);
      verify(() => mockDb.insert('user_progress', any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
          .called(1);
    });

    test('returns existing progress from database', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 100,
                  'currentStreak': 5,
                  'longestStreak': 10,
                  'currentLevel': 3,
                  'charactersMastered': 8,
                  'totalSessionsCompleted': 20,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      final result = await repo.getUserProgress();

      expect(result.totalPoints, 100);
      expect(result.currentStreak, 5);
      expect(result.longestStreak, 10);
      expect(result.currentLevel, 3);
      expect(result.charactersMastered, 8);
      expect(result.totalSessionsCompleted, 20);
      verifyNever(() => mockDb.insert('user_progress', any(), conflictAlgorithm: any(named: 'conflictAlgorithm')));
    });
  });

  group('updateUserProgress', () {
    test('calls update with correct where clause', () async {
      final progress = UserProgress(
        id: 'current',
        totalPoints: 50,
        currentStreak: 2,
        currentLevel: 2,
      );

      await repo.updateUserProgress(progress);

      final captured = verify(() => mockDb.update(
            'user_progress',
            captureAny(),
            where: captureAny(named: 'where'),
            whereArgs: captureAny(named: 'whereArgs'),
          )).captured;

      expect(captured[1], 'id = ?'); // where
      expect(captured[2], ['current']); // whereArgs
    });
  });

  group('addPoints', () {
    test('increments totalPoints by given amount', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 10,
                  'currentStreak': 0,
                  'longestStreak': 0,
                  'currentLevel': 1,
                  'charactersMastered': 0,
                  'totalSessionsCompleted': 0,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      await repo.addPoints(25);

      final captured = verify(() => mockDb.update('user_progress', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['totalPoints'], 35);
    });
  });

  group('streak management', () {
    test('incrementStreak increases current and longest streak', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 0,
                  'currentStreak': 3,
                  'longestStreak': 5,
                  'currentLevel': 1,
                  'charactersMastered': 0,
                  'totalSessionsCompleted': 0,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      await repo.incrementStreak();

      final captured = verify(() => mockDb.update('user_progress', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['currentStreak'], 4);
      expect(map['longestStreak'], 5); // unchanged, 4 < 5
    });

    test('incrementStreak updates longestStreak when new streak exceeds it', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 0,
                  'currentStreak': 5,
                  'longestStreak': 5,
                  'currentLevel': 1,
                  'charactersMastered': 0,
                  'totalSessionsCompleted': 0,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      await repo.incrementStreak();

      final captured = verify(() => mockDb.update('user_progress', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['currentStreak'], 6);
      expect(map['longestStreak'], 6);
    });

    test('resetStreak sets currentStreak to 0', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 0,
                  'currentStreak': 7,
                  'longestStreak': 10,
                  'currentLevel': 1,
                  'charactersMastered': 0,
                  'totalSessionsCompleted': 0,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      await repo.resetStreak();

      final captured = verify(() => mockDb.update('user_progress', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['currentStreak'], 0);
      expect(map['longestStreak'], 10); // unchanged
    });
  });

  group('completeSession', () {
    test('increments totalSessionsCompleted and sets lastSessionDate', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 0,
                  'currentStreak': 0,
                  'longestStreak': 0,
                  'currentLevel': 1,
                  'charactersMastered': 0,
                  'totalSessionsCompleted': 5,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      await repo.completeSession();

      final captured = verify(() => mockDb.update('user_progress', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['totalSessionsCompleted'], 6);
      expect(map['lastSessionDate'], isNotNull);
    });
  });

  group('level management', () {
    test('setCurrentLevel updates currentLevel', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 0,
                  'currentStreak': 0,
                  'longestStreak': 0,
                  'currentLevel': 1,
                  'charactersMastered': 0,
                  'totalSessionsCompleted': 0,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      await repo.setCurrentLevel(5);

      final captured = verify(() => mockDb.update('user_progress', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['currentLevel'], 5);
    });

    test('getCurrentLevel returns currentLevel from database', () async {
      when(() => mockDb.query('user_progress', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'totalPoints': 0,
                  'currentStreak': 0,
                  'longestStreak': 0,
                  'currentLevel': 7,
                  'charactersMastered': 0,
                  'totalSessionsCompleted': 0,
                  'lastSessionDate': null,
                  'hasCompletedOnboarding': 0,
                  'skipIntroOnboarding': 0,
                }
              ]);

      final result = await repo.getCurrentLevel();
      expect(result, 7);
    });
  });
}
