class Character {
  final String id;
  final String symbol;
  final String morsePattern;
  final int masteryLevel;
  final double accuracyPercentage;
  final int totalAttempts;
  final int correctAttempts;
  final DateTime? lastPracticed;
  final DateTime? nextReviewDate;
  final bool isUnlocked;
  final int kochOrder;

  Character({
    required this.id,
    required this.symbol,
    required this.morsePattern,
    this.masteryLevel = 0,
    this.accuracyPercentage = 0.0,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.lastPracticed,
    this.nextReviewDate,
    this.isUnlocked = false,
    required this.kochOrder,
  });

  Character copyWith({
    String? id,
    String? symbol,
    String? morsePattern,
    int? masteryLevel,
    double? accuracyPercentage,
    int? totalAttempts,
    int? correctAttempts,
    DateTime? lastPracticed,
    DateTime? nextReviewDate,
    bool? isUnlocked,
    int? kochOrder,
  }) {
    return Character(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      morsePattern: morsePattern ?? this.morsePattern,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      accuracyPercentage: accuracyPercentage ?? this.accuracyPercentage,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      kochOrder: kochOrder ?? this.kochOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'morsePattern': morsePattern,
      'masteryLevel': masteryLevel,
      'accuracyPercentage': accuracyPercentage,
      'totalAttempts': totalAttempts,
      'correctAttempts': correctAttempts,
      'lastPracticed': lastPracticed?.toIso8601String(),
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'isUnlocked': isUnlocked ? 1 : 0,
      'kochOrder': kochOrder,
    };
  }

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as String,
      symbol: map['symbol'] as String,
      morsePattern: map['morsePattern'] as String,
      masteryLevel: map['masteryLevel'] as int? ?? 0,
      accuracyPercentage: map['accuracyPercentage'] as double? ?? 0.0,
      totalAttempts: map['totalAttempts'] as int? ?? 0,
      correctAttempts: map['correctAttempts'] as int? ?? 0,
      lastPracticed: map['lastPracticed'] != null
          ? DateTime.parse(map['lastPracticed'] as String)
          : null,
      nextReviewDate: map['nextReviewDate'] != null
          ? DateTime.parse(map['nextReviewDate'] as String)
          : null,
      isUnlocked: map['isUnlocked'] == 1,
      kochOrder: map['kochOrder'] as int,
    );
  }
}
