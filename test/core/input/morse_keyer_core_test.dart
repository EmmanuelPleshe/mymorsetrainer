import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/morse_keyer_core.dart';
import 'package:morse_trainer/core/timing/morse_timing_engine.dart';

void main() {
  group('MorseKeyerCore', () {
    test('classifies dot when duration < threshold', () {
      final symbols = <String>[];
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onSymbol: symbols.add,
      );
      addTearDown(core.dispose);

      core.handleKeyUp(50); // 50ms < 180ms threshold

      expect(symbols, ['.']);
    });

    test('classifies dash when duration >= threshold', () {
      final symbols = <String>[];
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onSymbol: symbols.add,
      );
      addTearDown(core.dispose);

      core.handleKeyUp(180); // 180ms >= 180ms threshold

      expect(symbols, ['-']);
    });

    test('emits letter complete after inter-letter timeout', () async {
      String? capturedChar;
      String? capturedPattern;
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onLetterComplete: (char, pattern) {
          capturedChar = char;
          capturedPattern = pattern;
        },
      );
      addTearDown(core.dispose);

      core.handleKeyUp(50); // dot
      await Future.delayed(const Duration(milliseconds: 200)); // > 180ms

      expect(capturedChar, 'E');
      expect(capturedPattern, '.');
    });

    test('emits unknown pattern when not in lookup', () async {
      String? capturedPattern;
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onUnknownPattern: (pattern) => capturedPattern = pattern,
      );
      addTearDown(core.dispose);

      core.handleKeyUp(50); // dot
      core.handleKeyUp(50); // dot
      core.handleKeyUp(50); // dot
      core.handleKeyUp(50); // dot
      core.handleKeyUp(50); // dot
      core.handleKeyUp(50); // dot — '......' not in lookup

      await Future.delayed(const Duration(milliseconds: 200)); // > 180ms

      expect(capturedPattern, '......');
    });

    test('emits word boundary after inter-word timeout', () async {
      bool wordBoundaryCalled = false;
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onWordBoundary: () => wordBoundaryCalled = true,
      );
      addTearDown(core.dispose);

      core.handleKeyUp(50); // dot → 'E'
      await Future.delayed(const Duration(milliseconds: 200)); // letter timeout (180ms)
      await Future.delayed(const Duration(milliseconds: 600)); // word timeout (540ms)

      expect(wordBoundaryCalled, true);
    });

    test('submitNow emits immediately', () {
      String? capturedChar;
      String? capturedPattern;
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onLetterComplete: (char, pattern) {
          capturedChar = char;
          capturedPattern = pattern;
        },
      );
      addTearDown(core.dispose);

      core.handleKeyUp(50); // dot
      core.submitNow();

      expect(capturedChar, 'E');
      expect(capturedPattern, '.');
      expect(core.currentPattern, '');
    });

    test('clear cancels timers and resets pattern', () async {
      String? capturedPattern;
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onLetterComplete: (char, pattern) => capturedPattern = pattern,
      );
      addTearDown(core.dispose);

      core.handleKeyUp(50); // dot
      core.clear();

      expect(core.currentPattern, '');
      await Future.delayed(const Duration(milliseconds: 200));
      expect(capturedPattern, isNull);
    });

    test('new key down cancels letter timer', () async {
      String? capturedChar;
      String? capturedPattern;
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onLetterComplete: (char, pattern) {
          capturedChar = char;
          capturedPattern = pattern;
        },
      );
      addTearDown(core.dispose);

      core.handleKeyUp(50); // dot
      await Future.delayed(const Duration(milliseconds: 100)); // < 180ms
      core.handleKeyDown(); // cancels letter timer
      await Future.delayed(const Duration(milliseconds: 150)); // total 250ms > 180ms, but timer was cancelled

      expect(capturedChar, isNull); // not finalized yet

      core.handleKeyUp(50); // another dot
      await Future.delayed(const Duration(milliseconds: 200)); // > 180ms from second key up

      expect(capturedChar, 'I');
      expect(capturedPattern, '..');
    });

    test('dispose cancels all timers', () async {
      bool letterCompleteCalled = false;
      bool wordBoundaryCalled = false;
      final core = MorseKeyerCore(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onLetterComplete: (_, __) => letterCompleteCalled = true,
        onWordBoundary: () => wordBoundaryCalled = true,
      );

      core.handleKeyUp(50); // dot
      core.dispose();

      await Future.delayed(const Duration(milliseconds: 800)); // long enough for both timers

      expect(letterCompleteCalled, false);
      expect(wordBoundaryCalled, false);
    });
  });
}
