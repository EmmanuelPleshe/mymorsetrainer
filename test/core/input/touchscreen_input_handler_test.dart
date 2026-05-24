import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/touchscreen_input_handler.dart';

void main() {
  group('TouchscreenInputHandler', () {
    late TouchscreenInputHandler handler;
    String? capturedInput;
    bool errorCalled = false;

    setUp(() {
      capturedInput = null;
      errorCalled = false;
      handler = TouchscreenInputHandler(
        onMorseInput: (character) => capturedInput = character,
        onError: () => errorCalled = true,
      );
    });

    tearDown(() {
      handler.dispose();
    });

    group('dot/dash classification', () {
      test('short touch generates dot', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();

        // Wait for letter timeout
        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'E'); // single dot = E
      });

      test('long touch generates dash', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 250));
        handler.onTouchUp();

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'T'); // single dash = T
      });

      test('exactly at 200ms threshold generates dash', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 200));
        handler.onTouchUp();

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'T');
      });

      test('just under 200ms threshold generates dot', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 150));
        handler.onTouchUp();

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'E');
      });
    });

    group('pattern accumulation', () {
      test('multi-symbol pattern converts to character', () async {
        // Dot-dash = A
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();

        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 250));
        handler.onTouchUp();

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'A');
      });

      test('dot-dot-dash = U', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();

        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();

        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 250));
        handler.onTouchUp();

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'U');
      });
    });

    group('letter timeout', () {
      test('processes after 1000ms of no new touch', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();

        // Wait for letter timeout
        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'E');
      });

      test('new touch resets letter timeout', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();

        // Wait 600ms (not enough for 1000ms timeout)
        await Future.delayed(const Duration(milliseconds: 600));

        // New touch resets timer
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();

        // Wait 600ms more - total since first: 1200ms, but timer was reset
        await Future.delayed(const Duration(milliseconds: 600));
        expect(capturedInput, isNull);

        // Wait full timeout from last touch
        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, 'I'); // dot-dot = I
      });
    });

    group('unknown pattern', () {
      test('calls onError for unmapped pattern', () async {
        // Build unknown pattern '.....' (5 dots)
        for (int i = 0; i < 5; i++) {
          handler.onTouchDown();
          await Future.delayed(const Duration(milliseconds: 100));
          handler.onTouchUp();
        }

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, isNull);
        expect(errorCalled, true);
      });
    });

    group('touch up without touch down', () {
      test('ignores orphan touch up', () async {
        handler.onTouchUp();
        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, isNull);
        expect(errorCalled, false);
      });
    });

    group('dispose', () {
      test('cancels pending timer', () async {
        handler.onTouchDown();
        await Future.delayed(const Duration(milliseconds: 100));
        handler.onTouchUp();
        handler.dispose();

        await Future.delayed(const Duration(milliseconds: 1100));
        expect(capturedInput, isNull);
      });
    });
  });
}
