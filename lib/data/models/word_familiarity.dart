class WordFamiliarity {
  final String wordText;
  final double familiarityScore;
  final int totalAttempts;
  final int correctCount;
  final DateTime? lastReviewed;
  final DateTime? nextReviewDue;

  WordFamiliarity({
    required this.wordText,
    this.familiarityScore = 0.0,
    this.totalAttempts = 0,
    this.correctCount = 0,
    this.lastReviewed,
    this.nextReviewDue,
  });

  WordFamiliarity copyWith({
    String? wordText,
    double? familiarityScore,
    int? totalAttempts,
    int? correctCount,
    DateTime? lastReviewed,
    DateTime? nextReviewDue,
  }) {
    return WordFamiliarity(
      wordText: wordText ?? this.wordText,
      familiarityScore: familiarityScore ?? this.familiarityScore,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctCount: correctCount ?? this.correctCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReviewDue: nextReviewDue ?? this.nextReviewDue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wordText': wordText,
      'familiarityScore': familiarityScore,
      'totalAttempts': totalAttempts,
      'correctCount': correctCount,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextReviewDue': nextReviewDue?.toIso8601String(),
    };
  }

  factory WordFamiliarity.fromMap(Map<String, dynamic> map) {
    return WordFamiliarity(
      wordText: map['wordText'] as String,
      familiarityScore: (map['familiarityScore'] as num?)?.toDouble() ?? 0.0,
      totalAttempts: map['totalAttempts'] as int? ?? 0,
      correctCount: map['correctCount'] as int? ?? 0,
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.parse(map['lastReviewed'] as String)
          : null,
      nextReviewDue: map['nextReviewDue'] != null
          ? DateTime.parse(map['nextReviewDue'] as String)
          : null,
    );
  }
}
