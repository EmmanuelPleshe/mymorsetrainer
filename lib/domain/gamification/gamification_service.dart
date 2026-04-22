import '../../data/models/user_progress.dart';
import '../../data/repositories/user_progress_repository.dart';

class GamificationService {
  final UserProgressRepository _userProgressRepository;

  GamificationService(this._userProgressRepository);

  Future<UserProgress> getProgress() async {
    return await _userProgressRepository.getUserProgress();
  }

  Future<void> awardPointsForCorrectAnswer({int difficulty = 1}) async {
    final points = 10 * difficulty;
    await _userProgressRepository.addPoints(points);
  }

  Future<void> awardStreakBonus(int streak) async {
    if (streak < 5) return;

    int bonus = 0;
    if (streak >= 50) {
      bonus = 500;
    } else if (streak >= 25) {
      bonus = 250;
    } else if (streak >= 10) {
      bonus = 100;
    } else if (streak >= 5) {
      bonus = 50;
    }

    if (bonus > 0) {
      await _userProgressRepository.addPoints(bonus);
    }
  }

  Future<void> recordCorrectAnswer() async {
    await _userProgressRepository.incrementStreak();
    final progress = await _userProgressRepository.getUserProgress();
    await awardStreakBonus(progress.currentStreak);
    await awardPointsForCorrectAnswer();
  }

  Future<void> recordIncorrectAnswer() async {
    await _userProgressRepository.resetStreak();
  }

  Future<void> completeSession() async {
    await _userProgressRepository.completeSession();
  }

  Future<void> levelUp() async {
    final progress = await _userProgressRepository.getUserProgress();
    await _userProgressRepository.updateUserProgress(
      progress.copyWith(currentLevel: progress.currentLevel + 1),
    );
  }

  Future<Map<String, dynamic>> getStats() async {
    final progress = await _userProgressRepository.getUserProgress();
    return {
      'totalPoints': progress.totalPoints,
      'currentStreak': progress.currentStreak,
      'longestStreak': progress.longestStreak,
      'currentLevel': progress.currentLevel,
      'charactersMastered': progress.charactersMastered,
      'totalSessionsCompleted': progress.totalSessionsCompleted,
    };
  }
}
