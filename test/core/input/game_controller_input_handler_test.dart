import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/game_controller_input_handler.dart';

void main() {
  group('GameControllerKeyerHandler', () {
    late GameControllerKeyerHandler handler;
    String? capturedPattern;
    bool keyDownCalled = false;
    bool keyUpCalled = false;

    setUp(() {
      capturedPattern = null;
      keyDownCalled = false;
      keyUpCalled = false;
      handler = GameControllerKeyerHandler(
        dotDurationMs: 60,
        dashDurationMs: 180,
        onPatternComplete: (pattern) => capturedPattern = pattern,
        onKeyDown: () => keyDownCalled = true,
        onKeyUp: () => keyUpCalled = true,
      );
    });

    tearDown(() {
      handler.dispose();
    });

    group('dot/dash classification', () {
      test('short press generates dot', () {
        handler.handleButtonDown();
        handler.handleButtonUp(50); // 50ms < 120ms threshold
        expect(handler.currentPattern, '.');
        expect(keyDownCalled, true);
        expect(keyUpCalled, true);
      });

      test('long press generates dash', () {
        handler.handleButtonDown();
        handler.handleButtonUp(200); // 200ms >= 120ms threshold
        expect(handler.currentPattern, '-');
      });

      test('threshold is exactly 2x dotDurationMs', () {
        handler.handleButtonDown();
        handler.handleButtonUp(119); // just under 120ms
        expect(handler.currentPattern, '.');

        handler.clearPattern();

        handler.handleButtonDown();
        handler.handleButtonUp(120); // exactly at threshold
        expect(handler.currentPattern, '-');
      });
    });

    group('auto-submit', () {
      test('auto-submits valid pattern after idle timeout', () async {
        handler.handleButtonDown();
        handler.handleButtonUp(50); // dot

        expect(handler.currentPattern, '.');

        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, '.');
        expect(handler.currentPattern, '');
      });

      test('cancelled when new press arrives', () async {
        handler.handleButtonDown();
        handler.handleButtonUp(50); // dot

        // Wait 800ms
        await Future.delayed(const Duration(milliseconds: 800));

        // New press resets timer
        handler.handleButtonDown();
        handler.handleButtonUp(50); // dot

        await Future.delayed(const Duration(milliseconds: 800));
        expect(capturedPattern, isNull);
        expect(handler.currentPattern, '..');

        // Wait full timeout from last press
        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, '..');
      });
    });

    group('submitNow', () {
      test('immediately submits valid pattern', () {
        handler.handleButtonDown();
        handler.handleButtonUp(50); // dot
        handler.handleButtonDown();
        handler.handleButtonUp(50); // dot
        handler.handleButtonDown();
        handler.handleButtonUp(200); // dash

        expect(handler.currentPattern, '..-');
        handler.submitNow();
        expect(capturedPattern, '..-');
        expect(handler.currentPattern, '');
      });

      test('does not submit unknown pattern', () {
        // Build unknown pattern '......' (6 dots)
        for (int i = 0; i < 6; i++) {
          handler.handleButtonDown();
          handler.handleButtonUp(50); // dot
        }

        expect(handler.currentPattern, '......');
        handler.submitNow();
        expect(capturedPattern, isNull);
      });
    });

    group('double-press protection', () {
      test('ignores second button down while already pressed', () {
        handler.handleButtonDown();
        expect(keyDownCalled, true);

        keyDownCalled = false;
        handler.handleButtonDown();
        expect(keyDownCalled, false);

        handler.handleButtonUp(50);
        expect(handler.currentPattern, '.');
      });
    });

    group('clearPattern', () {
      test('cancels timer and resets pattern', () async {
        handler.handleButtonDown();
        handler.handleButtonUp(50); // dot

        handler.clearPattern();

        expect(handler.currentPattern, '');
        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, isNull);
      });
    });

    group('dispose', () {
      test('cancels pending timer', () async {
        handler.handleButtonDown();
        handler.handleButtonUp(50); // dot
        handler.dispose();

        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, isNull);
      });
    });
  });
}
