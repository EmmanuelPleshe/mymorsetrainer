import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/keyboard_input_handler.dart';

void main() {
  group('KeyboardKeyerHandler', () {
    late KeyboardKeyerHandler handler;
    String? capturedPattern;
    bool keyDownCalled = false;
    bool keyUpCalled = false;

    setUp(() {
      capturedPattern = null;
      keyDownCalled = false;
      keyUpCalled = false;
      handler = KeyboardKeyerHandler(
        dotDurationMs: 60, // 20 WPM
        dashDurationMs: 180,
        onPatternComplete: (pattern) => capturedPattern = pattern,
        onKeyDown: () => keyDownCalled = true,
        onKeyUp: () => keyUpCalled = true,
      );
    });

    tearDown(() {
      handler.dispose();
    });

    group('regression: premature auto-submit', () {
      test('should NOT auto-submit while user is still keying within 2 units', () async {
        // At 20 WPM: dotDurationMs = 60ms, auto-submit timeout = 180ms (3 units)
        // User keys: dot (60ms down) -> up -> wait 100ms -> dash (180ms down)
        // Total between key events: 160ms, still under 180ms timeout
        // Should NOT trigger auto-submit

        handler.handleKeyDown();
        expect(keyDownCalled, true);

        // Short press = dot
        handler.handleKeyUp(50); // 50ms < 120ms threshold = dot
        expect(keyUpCalled, true);

        // Wait but NOT long enough for auto-submit (100ms < 180ms)
        await Future.delayed(const Duration(milliseconds: 100));

        // Should still have pattern, not submitted yet
        expect(capturedPattern, isNull);
        expect(handler.currentPattern, '.');
      });

      test('should NOT auto-submit while user is still keying same character', () async {
        // User keys: dot-dot-dash (3 symbols for 'U' = '..-')
        // Each symbol within inter-character space - NO waiting between!

        handler.handleKeyDown();
        handler.handleKeyUp(50); // dot
        // Immediately key again - this cancels any pending auto-submit
        handler.handleKeyDown();
        handler.handleKeyUp(50); // dot
        handler.handleKeyDown();
        handler.handleKeyUp(200); // dash

        // Pattern should be complete '..-', not prematurely submitted as '..'
        expect(handler.currentPattern, '..-');
        // Wait for auto-submit to fire
        await Future.delayed(const Duration(milliseconds: 200));
        expect(capturedPattern, '..-');
      });

      test('should auto-submit after 3 units of silence', () async {
        // User keys: dot, then waits > 180ms (3 units)
        // Should auto-submit '.'
        handler.handleKeyDown();
        handler.handleKeyUp(50); // dot

        // Wait longer than auto-submit timeout
        await Future.delayed(const Duration(milliseconds: 200));

        expect(capturedPattern, '.');
      });
    });

    group('regression: double-processing race', () {
      test('should cancel previous timer when user keys again', () async {
        // User keys: dot, then immediately keys another (within timeout)
        // Should cancel first timer, not submit twice

        handler.handleKeyDown();
        handler.handleKeyUp(50); // dot

        // Immediately key again before timer fires
        handler.handleKeyDown();
        handler.handleKeyUp(50); // another dot

        // Should have both dots in pattern, not submitted as single dot
        expect(handler.currentPattern, '..');
        expect(capturedPattern, isNull); // No submit yet

        // Wait for timeout
        await Future.delayed(const Duration(milliseconds: 200));

        // Now should submit '..'
        expect(capturedPattern, '..');
      });
    });

    group('dot/dash classification', () {
      test('short press generates dot', () {
        handler.handleKeyDown();
        handler.handleKeyUp(50); // 50ms < 120ms threshold (2x dot at 20wpm)
        expect(handler.currentPattern, '.');
      });

      test('long press generates dash', () {
        handler.handleKeyDown();
        handler.handleKeyUp(200); // 200ms >= 120ms threshold
        expect(handler.currentPattern, '-');
      });
    });

    group('clearPattern', () {
      test('cancels timer and resets pattern', () async {
        handler.handleKeyDown();
        handler.handleKeyUp(50);

        handler.clearPattern();

        expect(handler.currentPattern, '');
        await Future.delayed(const Duration(milliseconds: 200));
        expect(capturedPattern, isNull); // Timer cancelled, no submit
      });
    });

    group('input blocking', () {
      test('blocks input when setAcceptInput(false)', () {
        handler.setAcceptInput(false);

        handler.handleKeyDown();

        expect(keyDownCalled, false);
        expect(handler.currentPattern, '');
      });

      test('allows input when setAcceptInput(true)', () {
        handler.setAcceptInput(true);

        handler.handleKeyDown();

        expect(keyDownCalled, true);
      });
    });
  });
}