import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/keyboard_input_handler.dart';
import 'package:morse_trainer/core/timing/morse_timing_engine.dart';

void main() {
  group('KeyboardKeyerHandler - Input Recognition', () {
    test('short press (< threshold) generates dot', () {
      final handler = KeyboardKeyerHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onPatternComplete: (_) {},
      );
      handler.handleKeyDown();
      handler.handleKeyUp(50);
      expect(handler.currentPattern, '.');
      handler.dispose();
    });

    test('long press (>= threshold) generates dash', () {
      final handler = KeyboardKeyerHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onPatternComplete: (_) {},
      );
      handler.handleKeyDown();
      handler.handleKeyUp(200);
      expect(handler.currentPattern, '-');
      handler.dispose();
    });

    test('handles slow keying (newbie)', () {
      final handler = KeyboardKeyerHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onPatternComplete: (_) {},
      );
      handler.handleKeyDown();
      handler.handleKeyUp(250); // slow dash
      expect(handler.currentPattern, '-');
      handler.dispose();
    });

    test('handles fast keying (experienced)', () {
      final handler = KeyboardKeyerHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onPatternComplete: (_) {},
      );
      handler.handleKeyDown();
      handler.handleKeyUp(120); // fast dot at 20 WPM (threshold 180ms)
      expect(handler.currentPattern, '.');
      handler.dispose();
    });
  });
}
