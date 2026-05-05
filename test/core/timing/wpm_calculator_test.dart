import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/timing/wpm_calculator.dart';

void main() {
  group('dotDurationMs', () {
    test('10 WPM = 120 ms', () {
      expect(WpmCalculator.dotDurationMs(10), 120);
    });

    test('20 WPM = 60 ms', () {
      expect(WpmCalculator.dotDurationMs(20), 60);
    });

    test('5 WPM = 240 ms', () {
      expect(WpmCalculator.dotDurationMs(5), 240);
    });

    test('40 WPM = 30 ms', () {
      expect(WpmCalculator.dotDurationMs(40), 30);
    });
  });

  group('dashDurationMs', () {
    test('is 3x dot duration', () {
      expect(WpmCalculator.dashDurationMs(10), 360);
      expect(WpmCalculator.dashDurationMs(20), 180);
    });
  });

  group('symbolSpaceMs', () {
    test('equals dot duration', () {
      expect(WpmCalculator.symbolSpaceMs(10), 120);
    });
  });

  group('letterSpaceMs', () {
    test('is 3x dot duration', () {
      expect(WpmCalculator.letterSpaceMs(10), 360);
    });
  });

  group('wordSpaceMs', () {
    test('is 7x dot duration', () {
      expect(WpmCalculator.wordSpaceMs(10), 840);
    });
  });

  group('wpmFromDuration', () {
    test('returns 0 for zero duration', () {
      expect(WpmCalculator.wpmFromDuration(0, 10), 0);
    });

    test('returns 0 for zero dotsAndDashes', () {
      expect(WpmCalculator.wpmFromDuration(100, 0), 0);
    });

    test('returns 0 for negative duration', () {
      expect(WpmCalculator.wpmFromDuration(-10, 10), 0);
    });

    test('calculates WPM from known duration', () {
      // At 10 WPM, 1 PARIS word (50 units) = 6000 ms
      // 10 words = 60000 ms = 60 seconds
      // Using 50 dotsAndDashes (1 PARIS word worth of elements)
      // durationMs = 6000, dotsAndDashes = 50
      // wpm = (50 * 60 * 1000) / (6000 * 50) = 3000000 / 300000 = 10
      final wpm = WpmCalculator.wpmFromDuration(6000, 50);
      expect(wpm, closeTo(10.0, 0.01));
    });
  });

  group('characterDurationMs', () {
    test('single dot at 10 WPM', () {
      expect(WpmCalculator.characterDurationMs('.', 10), 120);
    });

    test('single dash at 10 WPM', () {
      expect(WpmCalculator.characterDurationMs('-', 10), 360);
    });

    test('dot-dash (A) at 10 WPM = dot + space + dash', () {
      // . = 120, space = 120, - = 360 => 600
      expect(WpmCalculator.characterDurationMs('.-', 10), 600);
    });

    test('dash-dash-dot (G) at 20 WPM', () {
      // - = 180, space = 60, - = 180, space = 60, . = 60 => 540
      expect(WpmCalculator.characterDurationMs('--.', 20), 540);
    });

    test('empty pattern returns 0', () {
      expect(WpmCalculator.characterDurationMs('', 10), 0);
    });

    test('scales inversely with WPM', () {
      final at10 = WpmCalculator.characterDurationMs('.-', 10);
      final at20 = WpmCalculator.characterDurationMs('.-', 20);
      expect(at10, at20 * 2);
    });
  });
}
