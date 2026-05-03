import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/domain/gamification/points_calculator.dart';

void main() {
  group('Points Calculator', () {
    test('Streak milestone bonus at 5', () {
      expect(PointsCalculator.getStreakBonus(5), 25);
    });

    test('Streak milestone bonus at 10', () {
      expect(PointsCalculator.getStreakBonus(10), 50);
    });

    test('Points calculation with difficulty', () {
      final points = PointsCalculator.calculatePoints(
        isCorrect: true,
        currentStreak: 3,
        characterDifficulty: 3,
      );
      expect(points, greaterThan(10));
    });

    test('Session bonus for 90% accuracy', () {
      expect(PointsCalculator.calculateSessionBonus(18, 20), 100);
    });

    test('Streak milestone message at 5', () {
      expect(PointsCalculator.getStreakMilestoneMessage(5), contains('25'));
    });

    test('No streak message below 5', () {
      expect(PointsCalculator.getStreakMilestoneMessage(3), isNull);
    });
  });
}