import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/domain/gamification/points_calculator.dart';

void main() {
  group('calculatePoints', () {
    test('returns 0 for wrong answer', () {
      expect(
        PointsCalculator.calculatePoints(isCorrect: false, currentStreak: 5, characterDifficulty: 3),
        0,
      );
    });

    test('base points with difficulty 1 and no streak', () {
      final points = PointsCalculator.calculatePoints(
        isCorrect: true,
        currentStreak: 0,
        characterDifficulty: 1,
      );
      expect(points, 15); // 10 * 1.5 * 1.0
    });

    test('difficulty multiplier scales points', () {
      final d1 = PointsCalculator.calculatePoints(
        isCorrect: true, currentStreak: 0, characterDifficulty: 1,
      );
      final d3 = PointsCalculator.calculatePoints(
        isCorrect: true, currentStreak: 0, characterDifficulty: 3,
      );
      expect(d3 > d1, true);
      expect(d3, 45); // 10 * 1.5 * 3 * 1.0
    });

    test('streak bonus compounds points', () {
      final noStreak = PointsCalculator.calculatePoints(
        isCorrect: true, currentStreak: 0, characterDifficulty: 1,
      );
      final streak10 = PointsCalculator.calculatePoints(
        isCorrect: true, currentStreak: 10, characterDifficulty: 1,
      );
      expect(streak10 > noStreak, true);
      expect(streak10, 30); // 15 * (1 + 10 * 0.1) = 15 * 2.0
    });

    test('high difficulty + high streak gives high points', () {
      final points = PointsCalculator.calculatePoints(
        isCorrect: true, currentStreak: 20, characterDifficulty: 5,
      );
      expect(points, 225); // 10 * 1.5 * 5 * (1 + 20 * 0.1) = 75 * 3.0
    });
  });

  group('getStreakBonus', () {
    test('returns null for streak below 5', () {
      expect(PointsCalculator.getStreakBonus(0), null);
      expect(PointsCalculator.getStreakBonus(4), null);
    });

    test('returns bonus at milestone streaks', () {
      expect(PointsCalculator.getStreakBonus(5), 25);
      expect(PointsCalculator.getStreakBonus(10), 50);
      expect(PointsCalculator.getStreakBonus(25), 100);
      expect(PointsCalculator.getStreakBonus(50), 250);
      expect(PointsCalculator.getStreakBonus(100), 500);
    });

    test('returns bonus when near next milestone', () {
      // Within 5 of next milestone returns previous milestone bonus
      expect(PointsCalculator.getStreakBonus(7), 25); // near 10
    });

    test('returns null when not near any milestone', () {
      expect(PointsCalculator.getStreakBonus(3), null);
      expect(PointsCalculator.getStreakBonus(16), null);
    });
  });

  group('getStreakMilestoneMessage', () {
    test('returns null for streak below 5', () {
      expect(PointsCalculator.getStreakMilestoneMessage(0), null);
      expect(PointsCalculator.getStreakMilestoneMessage(4), null);
    });

    test('returns correct message at each tier', () {
      expect(PointsCalculator.getStreakMilestoneMessage(5), 'GOOD START! +25 bonus');
      expect(PointsCalculator.getStreakMilestoneMessage(10), 'NICE STREAK! +50 bonus');
      expect(PointsCalculator.getStreakMilestoneMessage(25), 'GREAT STREAK! +100 bonus');
      expect(PointsCalculator.getStreakMilestoneMessage(50), 'AMAZING STREAK! +250 bonus');
      expect(PointsCalculator.getStreakMilestoneMessage(100), 'LEGENDARY STREAK! +500 bonus');
    });

    test('highest tier message for very large streaks', () {
      expect(PointsCalculator.getStreakMilestoneMessage(200), 'LEGENDARY STREAK! +500 bonus');
    });
  });

  group('calculateSessionBonus', () {
    test('returns 0 when no correct answers', () {
      expect(PointsCalculator.calculateSessionBonus(0, 10), 0);
    });

    test('returns 100 for 90%+ accuracy', () {
      expect(PointsCalculator.calculateSessionBonus(9, 10), 100);
      expect(PointsCalculator.calculateSessionBonus(10, 10), 100);
    });

    test('returns 50 for 80-89% accuracy', () {
      expect(PointsCalculator.calculateSessionBonus(8, 10), 50);
      expect(PointsCalculator.calculateSessionBonus(85, 100), 50);
    });

    test('returns 25 for 70-79% accuracy', () {
      expect(PointsCalculator.calculateSessionBonus(7, 10), 25);
      expect(PointsCalculator.calculateSessionBonus(75, 100), 25);
    });

    test('returns 0 for below 70% accuracy', () {
      expect(PointsCalculator.calculateSessionBonus(6, 10), 0);
      expect(PointsCalculator.calculateSessionBonus(1, 10), 0);
    });
  });
}
