class UserProgress {
  final String id;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int currentLevel;
  final int charactersMastered;
  final int totalSessionsCompleted;
  final DateTime? lastSessionDate;

  UserProgress({
    this.id = 'current',
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.currentLevel = 1,
    this.charactersMastered = 0,
    this.totalSessionsCompleted = 0,
    this.lastSessionDate,
  });

  UserProgress copyWith({
    String? id,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? currentLevel,
    int? charactersMastered,
    int? totalSessionsCompleted,
    DateTime? lastSessionDate,
  }) {
    return UserProgress(
      id: id ?? this.id,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      currentLevel: currentLevel ?? this.currentLevel,
      charactersMastered: charactersMastered ?? this.charactersMastered,
      totalSessionsCompleted: totalSessionsCompleted ?? this.totalSessionsCompleted,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'currentLevel': currentLevel,
      'charactersMastered': charactersMastered,
      'totalSessionsCompleted': totalSessionsCompleted,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'] as String? ?? 'current',
      totalPoints: map['totalPoints'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      currentLevel: map['currentLevel'] as int? ?? 1,
      charactersMastered: map['charactersMastered'] as int? ?? 0,
      totalSessionsCompleted: map['totalSessionsCompleted'] as int? ?? 0,
      lastSessionDate: map['lastSessionDate'] != null
          ? DateTime.parse(map['lastSessionDate'] as String)
          : null,
    );
  }
}
