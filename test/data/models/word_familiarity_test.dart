import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/data/models/word_familiarity.dart';

void main() {
  group('WordFamiliarity', () {
    test('default constructor uses correct defaults', () {
      final wf = WordFamiliarity(wordText: 'CQ');
      expect(wf.wordText, 'CQ');
      expect(wf.familiarityScore, 0.0);
      expect(wf.totalAttempts, 0);
      expect(wf.correctCount, 0);
      expect(wf.lastReviewed, isNull);
      expect(wf.nextReviewDue, isNull);
    });

    test('copyWith overrides only provided fields', () {
      final wf = WordFamiliarity(
        wordText: 'CQ',
        familiarityScore: 50.0,
        totalAttempts: 5,
      );
      final wf2 = wf.copyWith(correctCount: 3);

      expect(wf2.wordText, 'CQ');
      expect(wf2.familiarityScore, 50.0);
      expect(wf2.totalAttempts, 5);
      expect(wf2.correctCount, 3);
      expect(wf2.lastReviewed, isNull);
    });

    test('toMap serializes all fields', () {
      final wf = WordFamiliarity(
        wordText: 'DE',
        familiarityScore: 75.0,
        totalAttempts: 10,
        correctCount: 8,
        lastReviewed: DateTime(2026, 5, 10),
        nextReviewDue: DateTime(2026, 5, 11),
      );
      final map = wf.toMap();

      expect(map['wordText'], 'DE');
      expect(map['familiarityScore'], 75.0);
      expect(map['totalAttempts'], 10);
      expect(map['correctCount'], 8);
      expect(map['lastReviewed'], '2026-05-10T00:00:00.000');
      expect(map['nextReviewDue'], '2026-05-11T00:00:00.000');
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'wordText': 'QTH',
        'familiarityScore': 30.0,
        'totalAttempts': 3,
        'correctCount': 1,
        'lastReviewed': '2026-05-10T00:00:00.000',
        'nextReviewDue': '2026-05-11T00:00:00.000',
      };
      final wf = WordFamiliarity.fromMap(map);

      expect(wf.wordText, 'QTH');
      expect(wf.familiarityScore, 30.0);
      expect(wf.totalAttempts, 3);
      expect(wf.correctCount, 1);
      expect(wf.lastReviewed, DateTime(2026, 5, 10));
      expect(wf.nextReviewDue, DateTime(2026, 5, 11));
    });

    test('fromMap uses defaults for missing/null fields', () {
      final wf = WordFamiliarity.fromMap({'wordText': 'TU'});

      expect(wf.wordText, 'TU');
      expect(wf.familiarityScore, 0.0);
      expect(wf.totalAttempts, 0);
      expect(wf.correctCount, 0);
      expect(wf.lastReviewed, isNull);
      expect(wf.nextReviewDue, isNull);
    });
  });
}
