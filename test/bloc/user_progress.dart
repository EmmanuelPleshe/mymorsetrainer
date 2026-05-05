// Minimal UserProgress for testing - mirrors data/repositories/user_progress_repository.dart
class UserProgress {
  final int currentLevel;
  final int totalSessions;
  final int totalCorrect;
  final int totalAttempts;
  final int currentStreak;
  final int longestStreak;
  final bool hasCompletedOnboarding;
  final bool skipIntroOnboarding;

  UserProgress({
    required this.currentLevel,
    required this.totalSessions,
    required this.totalCorrect,
    required this.totalAttempts,
    required this.currentStreak,
    required this.longestStreak,
    required this.hasCompletedOnboarding,
    this.skipIntroOnboarding = false,
  });

  UserProgress copyWith({
    int? currentLevel,
    int? totalSessions,
    int? totalCorrect,
    int? totalAttempts,
    int? currentStreak,
    int? longestStreak,
    bool? hasCompletedOnboarding,
    bool? skipIntroOnboarding,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      totalSessions: totalSessions ?? this.totalSessions,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      skipIntroOnboarding: skipIntroOnboarding ?? this.skipIntroOnboarding,
    );
  }
}