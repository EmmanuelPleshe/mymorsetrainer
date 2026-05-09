import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/keyboard_input_handler.dart';

void main() {
  group('KeyboardKeyerHandler', () {
    late String submittedPattern;
    late KeyboardKeyerHandler handler;

    setUp(() {
      submittedPattern = '';
      handler = KeyboardKeyerHandler(
        dotDurationMs: 60,   // 20 WPM
        dashDurationMs: 180,
        onPatternComplete: (pattern) {
          submittedPattern = pattern;
        },
      );
    });

    tearDown(() {
      handler.dispose();
    });

    test('short press generates dot', () {
      handler.handleKeyDown();
      handler.handleKeyUp(50);
      expect(handler.currentPattern, '.');
    });

    test('casual tap (150ms) generates dot at 20 WPM', () {
      // Threshold at 20 WPM = 3 × 60 = 180ms
      // Casual spacebar taps are ~100-150ms — must register as dots
      handler.handleKeyDown();
      handler.handleKeyUp(150);
      expect(handler.currentPattern, '.');
    });

    test('long press generates dash', () {
      handler.handleKeyDown();
      handler.handleKeyUp(200);
      expect(handler.currentPattern, '-');
    });

    test('regression: can complete K (-.-) before auto-submit timeout', () async {
      // K = dash-dot-dash
      // Simulate realistic keying with normal pauses between symbols
      handler.handleKeyDown();
      handler.handleKeyUp(180); // dash

      await Future.delayed(const Duration(milliseconds: 80)); // inter-symbol pause

      handler.handleKeyDown();
      handler.handleKeyUp(60); // dot

      await Future.delayed(const Duration(milliseconds: 80)); // inter-symbol pause

      handler.handleKeyDown();
      handler.handleKeyUp(180); // dash

      // Pattern should be complete but not yet submitted
      expect(handler.currentPattern, '-.-');
      expect(submittedPattern, '');

      // Wait for auto-submit timeout (400ms) to fire
      await Future.delayed(const Duration(milliseconds: 500));
      expect(submittedPattern, '-.-');
    });

    test('regression: auto-submit does not fire too quickly between symbols', () async {
      // Simulate a slow keyer: 250ms pause between symbols
      handler.handleKeyDown();
      handler.handleKeyUp(180); // dash

      await Future.delayed(const Duration(milliseconds: 250));

      // With buggy 180ms timeout, auto-submit would have fired by now
      // With fixed 400ms timeout, pattern should still be pending
      expect(handler.currentPattern, '-');
      expect(submittedPattern, '');
    });

    test('clearPattern resets state', () {
      handler.handleKeyDown();
      handler.handleKeyUp(60);
      expect(handler.currentPattern, '.');

      handler.clearPattern();
      expect(handler.currentPattern, '');
    });
  });
}
