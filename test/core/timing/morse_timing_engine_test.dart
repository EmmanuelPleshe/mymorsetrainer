import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/timing/morse_timing_engine.dart';

void main() {
  group('MorseTimingEngine', () {
    test('20 WPM standard timing', () {
      final engine = MorseTimingEngine(wpm: 20, effWpm: 20);
      expect(engine.dotDurationMs, 60);
      expect(engine.dashDurationMs, 180);
      expect(engine.intraCharacterSpaceMs, 60);
      expect(engine.interCharacterSpaceMs, 180);
      expect(engine.interWordSpaceMs, 420);
    });

    test('keyer thresholds at 20 WPM', () {
      final engine = MorseTimingEngine(wpm: 20, effWpm: 20);
      expect(engine.keyerDotDashThresholdMs, 180);
      expect(engine.keyerInterLetterThresholdMs, 180);
      expect(engine.keyerInterWordThresholdMs, 540);
    });

    test('Farnsworth expands inter-char and inter-word when effWpm < wpm', () {
      final engine = MorseTimingEngine(wpm: 20, effWpm: 10);
      expect(engine.dotDurationMs, 60); // character speed unchanged
      expect(engine.dashDurationMs, 180);
      expect(engine.interCharacterSpaceMs, 654); // Farnsworth total
      expect(engine.interWordSpaceMs, 1525); // Farnsworth total
    });

    test('dot/dash threshold scales with WPM', () {
      final engine20 = MorseTimingEngine(wpm: 20, effWpm: 20);
      final engine15 = MorseTimingEngine(wpm: 15, effWpm: 15);
      expect(engine15.dotDurationMs, 80);
      expect(engine15.keyerDotDashThresholdMs, 240); // 3x80
    });

    test('extraWordSpace added to interWordSpace', () {
      final base = MorseTimingEngine(wpm: 20, effWpm: 20);
      final withExtra = MorseTimingEngine(wpm: 20, effWpm: 20, extraWordSpace: 500);
      expect(withExtra.interWordSpaceMs, base.interWordSpaceMs + 500);
    });

    test('consistent values for identical inputs', () {
      final a = MorseTimingEngine(wpm: 15, effWpm: 10, extraWordSpace: 200);
      final b = MorseTimingEngine(wpm: 15, effWpm: 10, extraWordSpace: 200);
      expect(a.dotDurationMs, b.dotDurationMs);
      expect(a.interCharacterSpaceMs, b.interCharacterSpaceMs);
    });

    test('boundary effWpm equals wpm uses standard spacing', () {
      final engine = MorseTimingEngine(wpm: 20, effWpm: 20);
      expect(engine.interCharacterSpaceMs, 180); // 3 * 60
      expect(engine.interWordSpaceMs, 420); // 7 * 60
    });

    test('low WPM timing', () {
      final engine = MorseTimingEngine(wpm: 5, effWpm: 5);
      expect(engine.dotDurationMs, 240);
      expect(engine.dashDurationMs, 720);
      expect(engine.interCharacterSpaceMs, 720);
      expect(engine.interWordSpaceMs, 1680);
    });

    test('high WPM timing', () {
      final engine = MorseTimingEngine(wpm: 40, effWpm: 40);
      expect(engine.dotDurationMs, 30);
      expect(engine.dashDurationMs, 90);
      expect(engine.interCharacterSpaceMs, 90);
      expect(engine.interWordSpaceMs, 210);
    });

    test('asserts on zero wpm', () {
      expect(() => MorseTimingEngine(wpm: 0, effWpm: 20), throwsAssertionError);
    });

    test('asserts on zero effWpm', () {
      expect(() => MorseTimingEngine(wpm: 20, effWpm: 0), throwsAssertionError);
    });

    test('asserts on negative wpm', () {
      expect(() => MorseTimingEngine(wpm: -5, effWpm: 20), throwsAssertionError);
    });
  });
}
