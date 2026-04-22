import '../database/database_helper.dart';
import '../models/user_progress.dart';

class UserProgressRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<UserProgress> getUserProgress() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'user_progress',
      where: 'id = ?',
      whereArgs: ['current'],
    );
    if (maps.isEmpty) {
      final defaultProgress = UserProgress();
      await db.insert('user_progress', defaultProgress.toMap());
      return defaultProgress;
    }
    return UserProgress.fromMap(maps.first);
  }

  Future<void> updateUserProgress(UserProgress progress) async {
    final db = await _dbHelper.database;
    await db.update(
      'user_progress',
      progress.toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  Future<void> addPoints(int points) async {
    final progress = await getUserProgress();
    await updateUserProgress(progress.copyWith(
      totalPoints: progress.totalPoints + points,
    ));
  }

  Future<void> incrementStreak() async {
    final progress = await getUserProgress();
    final newStreak = progress.currentStreak + 1;
    await updateUserProgress(progress.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
    ));
  }

  Future<void> resetStreak() async {
    final progress = await getUserProgress();
    await updateUserProgress(progress.copyWith(currentStreak: 0));
  }

  Future<void> incrementCharactersMastered() async {
    final progress = await getUserProgress();
    await updateUserProgress(progress.copyWith(
      charactersMastered: progress.charactersMastered + 1,
    ));
  }

  Future<void> completeSession() async {
    final progress = await getUserProgress();
    await updateUserProgress(progress.copyWith(
      totalSessionsCompleted: progress.totalSessionsCompleted + 1,
      lastSessionDate: DateTime.now(),
    ));
  }
}
