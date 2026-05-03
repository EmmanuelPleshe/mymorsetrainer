class PointsCalculator {
  static const int _basePoints = 10;
  static const double _difficultyMultiplier = 1.5;
  static const double _streakMultiplier = 0.1;

  static const Map<int, int> _streakMilestones = {
    5: 25,
    10: 50,
    25: 100,
    50: 250,
    100: 500,
  };

  static int calculatePoints({
    required bool isCorrect,
    required int currentStreak,
    required int characterDifficulty,
  }) {
    if (!isCorrect) return 0;

    int points = _basePoints;

    // Difficulty multiplier (1-5 scale)
    points = (points * (_difficultyMultiplier * characterDifficulty)).round();

    // Streak bonus (compounds up to 5x)
    final streakBonus = 1.0 + (currentStreak * _streakMultiplier);
    points = (points * streakBonus).round();

    return points;
  }

  static int? getStreakBonus(int streak) {
    if (_streakMilestones.containsKey(streak)) {
      return _streakMilestones[streak];
    }

    // Check if we've crossed a milestone
    for (final milestone in _streakMilestones.keys) {
      if (streak >= milestone) {
        final nextMilestones = _streakMilestones.keys.where((m) => m > streak).toList();
        if (nextMilestones.isNotEmpty && streak >= (nextMilestones.first - 5)) {
          return _streakMilestones[milestone];
        }
      }
    }
    return null;
  }

  static String? getStreakMilestoneMessage(int streak) {
    if (streak >= 100) return 'LEGENDARY STREAK! +500 bonus';
    if (streak >= 50) return 'AMAZING STREAK! +250 bonus';
    if (streak >= 25) return 'GREAT STREAK! +100 bonus';
    if (streak >= 10) return 'NICE STREAK! +50 bonus';
    if (streak >= 5) return 'GOOD START! +25 bonus';
    return null;
  }

  static int calculateSessionBonus(int correctCount, int totalCount) {
    if (correctCount == 0) return 0;

    final accuracy = correctCount / totalCount;
    if (accuracy >= 0.9) return 100;
    if (accuracy >= 0.8) return 50;
    if (accuracy >= 0.7) return 25;
    return 0;
  }
}