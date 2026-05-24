import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/data/models/user_progress.dart';

void main() {
  group('UserProgress', () {
    test('default constructor uses correct defaults', () {
      final p = UserProgress();
      expect(p.id, 'current');
      expect(p.totalPoints, 0);
      expect(p.currentStreak, 0);
      expect(p.longestStreak, 0);
      expect(p.currentLevel, 1);
      expect(p.charactersMastered, 0);
      expect(p.totalSessionsCompleted, 0);
      expect(p.lastSessionDate, isNull);
      expect(p.hasCompletedOnboarding, false);
      expect(p.skipIntroOnboarding, false);
    });

    test('copyWith overrides only provided fields', () {
      final p = UserProgress(totalPoints: 100, currentStreak: 5);
      final p2 = p.copyWith(currentLevel: 3);

      expect(p2.totalPoints, 100);
      expect(p2.currentStreak, 5);
      expect(p2.currentLevel, 3);
      expect(p2.longestStreak, 0);
    });

    test('toMap serializes all fields', () {
      final p = UserProgress(
        id: 'test',
        totalPoints: 150,
        currentStreak: 7,
        longestStreak: 15,
        currentLevel: 5,
        charactersMastered: 10,
        totalSessionsCompleted: 42,
        lastSessionDate: DateTime(2026, 5, 5, 10, 30),
        hasCompletedOnboarding: true,
        skipIntroOnboarding: true,
      );
      final map = p.toMap();

      expect(map['id'], 'test');
      expect(map['totalPoints'], 150);
      expect(map['currentStreak'], 7);
      expect(map['longestStreak'], 15);
      expect(map['currentLevel'], 5);
      expect(map['charactersMastered'], 10);
      expect(map['totalSessionsCompleted'], 42);
      expect(map['lastSessionDate'], '2026-05-05T10:30:00.000');
      expect(map['hasCompletedOnboarding'], 1);
      expect(map['skipIntroOnboarding'], 1);
    });

    test('toMap handles null lastSessionDate', () {
      final p = UserProgress(lastSessionDate: null);
      expect(p.toMap()['lastSessionDate'], isNull);
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'id': 'test',
        'totalPoints': 150,
        'currentStreak': 7,
        'longestStreak': 15,
        'currentLevel': 5,
        'charactersMastered': 10,
        'totalSessionsCompleted': 42,
        'lastSessionDate': '2026-05-05T10:30:00.000',
        'hasCompletedOnboarding': 1,
        'skipIntroOnboarding': 1,
      };
      final p = UserProgress.fromMap(map);

      expect(p.id, 'test');
      expect(p.totalPoints, 150);
      expect(p.currentStreak, 7);
      expect(p.longestStreak, 15);
      expect(p.currentLevel, 5);
      expect(p.charactersMastered, 10);
      expect(p.totalSessionsCompleted, 42);
      expect(p.lastSessionDate, DateTime(2026, 5, 5, 10, 30));
      expect(p.hasCompletedOnboarding, true);
      expect(p.skipIntroOnboarding, true);
    });

    test('fromMap uses defaults for missing fields', () {
      final p = UserProgress.fromMap({});
      expect(p.id, 'current');
      expect(p.totalPoints, 0);
      expect(p.currentStreak, 0);
      expect(p.longestStreak, 0);
      expect(p.currentLevel, 1);
      expect(p.charactersMastered, 0);
      expect(p.totalSessionsCompleted, 0);
      expect(p.lastSessionDate, isNull);
      expect(p.hasCompletedOnboarding, false);
      expect(p.skipIntroOnboarding, false);
    });

    test('fromMap bool deserialization handles 1 and 0', () {
      final on = UserProgress.fromMap({'hasCompletedOnboarding': 1, 'skipIntroOnboarding': 1});
      expect(on.hasCompletedOnboarding, true);
      expect(on.skipIntroOnboarding, true);

      final off = UserProgress.fromMap({'hasCompletedOnboarding': 0, 'skipIntroOnboarding': 0});
      expect(off.hasCompletedOnboarding, false);
      expect(off.skipIntroOnboarding, false);
    });
  });
}
