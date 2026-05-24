import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/data/models/character.dart';

void main() {
  group('Character', () {
    test('default constructor uses correct defaults', () {
      final c = Character(id: 'k', symbol: 'K', morsePattern: '-.-', kochOrder: 1);
      expect(c.id, 'k');
      expect(c.symbol, 'K');
      expect(c.morsePattern, '-.-');
      expect(c.masteryLevel, 0);
      expect(c.accuracyPercentage, 0.0);
      expect(c.totalAttempts, 0);
      expect(c.correctAttempts, 0);
      expect(c.lastPracticed, isNull);
      expect(c.nextReviewDate, isNull);
      expect(c.isUnlocked, false);
      expect(c.kochOrder, 1);
    });

    test('copyWith overrides only provided fields', () {
      final c = Character(
        id: 'k', symbol: 'K', morsePattern: '-.-', kochOrder: 1,
        masteryLevel: 2, totalAttempts: 10,
      );
      final c2 = c.copyWith(accuracyPercentage: 85.0);

      expect(c2.symbol, 'K');
      expect(c2.masteryLevel, 2);
      expect(c2.accuracyPercentage, 85.0);
      expect(c2.totalAttempts, 10);
    });

    test('toMap serializes all fields', () {
      final c = Character(
        id: 'k',
        symbol: 'K',
        morsePattern: '-.-',
        masteryLevel: 3,
        accuracyPercentage: 92.5,
        totalAttempts: 20,
        correctAttempts: 18,
        lastPracticed: DateTime(2026, 5, 5, 10, 30),
        nextReviewDate: DateTime(2026, 5, 7),
        isUnlocked: true,
        kochOrder: 1,
      );
      final map = c.toMap();

      expect(map['id'], 'k');
      expect(map['symbol'], 'K');
      expect(map['morsePattern'], '-.-');
      expect(map['masteryLevel'], 3);
      expect(map['accuracyPercentage'], 92.5);
      expect(map['totalAttempts'], 20);
      expect(map['correctAttempts'], 18);
      expect(map['lastPracticed'], '2026-05-05T10:30:00.000');
      expect(map['nextReviewDate'], '2026-05-07T00:00:00.000');
      expect(map['isUnlocked'], 1);
      expect(map['kochOrder'], 1);
    });

    test('toMap handles null dates', () {
      final c = Character(id: 'k', symbol: 'K', morsePattern: '-.-', kochOrder: 1);
      expect(c.toMap()['lastPracticed'], isNull);
      expect(c.toMap()['nextReviewDate'], isNull);
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'id': 'k',
        'symbol': 'K',
        'morsePattern': '-.-',
        'masteryLevel': 3,
        'accuracyPercentage': 92.5,
        'totalAttempts': 20,
        'correctAttempts': 18,
        'lastPracticed': '2026-05-05T10:30:00.000',
        'nextReviewDate': '2026-05-07T00:00:00.000',
        'isUnlocked': 1,
        'kochOrder': 1,
      };
      final c = Character.fromMap(map);

      expect(c.id, 'k');
      expect(c.symbol, 'K');
      expect(c.morsePattern, '-.-');
      expect(c.masteryLevel, 3);
      expect(c.accuracyPercentage, 92.5);
      expect(c.totalAttempts, 20);
      expect(c.correctAttempts, 18);
      expect(c.lastPracticed, DateTime(2026, 5, 5, 10, 30));
      expect(c.nextReviewDate, DateTime(2026, 5, 7));
      expect(c.isUnlocked, true);
      expect(c.kochOrder, 1);
    });

    test('fromMap uses defaults for missing fields', () {
      final map = {
        'id': 'k',
        'symbol': 'K',
        'morsePattern': '-.-',
        'kochOrder': 1,
      };
      final c = Character.fromMap(map);
      expect(c.masteryLevel, 0);
      expect(c.accuracyPercentage, 0.0);
      expect(c.totalAttempts, 0);
      expect(c.correctAttempts, 0);
      expect(c.lastPracticed, isNull);
      expect(c.nextReviewDate, isNull);
      expect(c.isUnlocked, false);
    });

    test('fromMap bool deserialization handles 1 and 0', () {
      final unlocked = Character.fromMap({
        'id': 'k', 'symbol': 'K', 'morsePattern': '-.-', 'kochOrder': 1, 'isUnlocked': 1,
      });
      expect(unlocked.isUnlocked, true);

      final locked = Character.fromMap({
        'id': 'k', 'symbol': 'K', 'morsePattern': '-.-', 'kochOrder': 1, 'isUnlocked': 0,
      });
      expect(locked.isUnlocked, false);
    });
  });
}
