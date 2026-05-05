import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/audio_input_handler.dart';

void main() {
  group('AudioKeyerHandler', () {
    late AudioKeyerHandler handler;
    String? capturedPattern;
    bool keyDownCalled = false;
    bool keyUpCalled = false;

    setUp(() {
      capturedPattern = null;
      keyDownCalled = false;
      keyUpCalled = false;
      handler = AudioKeyerHandler(
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
      test('short tone generates dot', () {
        handler.handleToneDetected();
        handler.handleToneStopped();
        expect(handler.currentPattern, '.');
        expect(keyDownCalled, true);
        expect(keyUpCalled, true);
      });

      test('long tone generates dash', () async {
        handler.handleToneDetected();
        await Future.delayed(const Duration(milliseconds: 200));
        handler.handleToneStopped();
        expect(handler.currentPattern, '-');
      });
    });

    group('auto-submit', () {
      test('auto-submits valid pattern after idle timeout', () async {
        handler.handleToneDetected();
        handler.handleToneStopped(); // dot

        expect(handler.currentPattern, '.');

        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, '.');
        expect(handler.currentPattern, '');
      });

      test('does not submit unknown pattern', () async {
        // Build unknown pattern '......' (6 dots)
        for (int i = 0; i < 6; i++) {
          handler.handleToneDetected();
          handler.handleToneStopped(); // dot
        }

        expect(handler.currentPattern, '......');
        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, isNull);
      });

      test('cancelled when new tone arrives', () async {
        handler.handleToneDetected();
        handler.handleToneStopped(); // dot

        // Wait 800ms (not long enough for 1500ms timeout)
        await Future.delayed(const Duration(milliseconds: 800));

        // New tone resets timer
        handler.handleToneDetected();
        handler.handleToneStopped(); // dot

        await Future.delayed(const Duration(milliseconds: 800));
        // Total since first tone: 1600ms, but timer was reset
        expect(capturedPattern, isNull);
        expect(handler.currentPattern, '..');

        // Now wait full timeout from last tone
        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, '..');
      });
    });

    group('submitNow', () {
      test('immediately submits valid pattern', () async {
        handler.handleToneDetected();
        handler.handleToneStopped(); // dot
        handler.handleToneDetected();
        handler.handleToneStopped(); // dot
        handler.handleToneDetected();
        await Future.delayed(const Duration(milliseconds: 200));
        handler.handleToneStopped(); // dash

        expect(handler.currentPattern, '..-');
        handler.submitNow();
        expect(capturedPattern, '..-');
        expect(handler.currentPattern, '');
      });

      test('does not submit unknown pattern', () async {
        // Build unknown pattern '......' (6 dots)
        for (int i = 0; i < 6; i++) {
          handler.handleToneDetected();
          handler.handleToneStopped(); // dot
        }

        expect(handler.currentPattern, '......');
        handler.submitNow();
        expect(capturedPattern, isNull);
      });
    });

    group('double-tone protection', () {
      test('ignores second tone detected while already active', () async {
        handler.handleToneDetected();
        expect(keyDownCalled, true);

        // Second tone while first still active
        keyDownCalled = false;
        handler.handleToneDetected();
        expect(keyDownCalled, false); // not called again

        await Future.delayed(const Duration(milliseconds: 200));
        handler.handleToneStopped();
        expect(handler.currentPattern, '-');
      });
    });

    group('clearPattern', () {
      test('cancels timer and resets pattern', () async {
        handler.handleToneDetected();
        handler.handleToneStopped(); // dot

        handler.clearPattern();

        expect(handler.currentPattern, '');
        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, isNull);
      });
    });

    group('dispose', () {
      test('cancels pending timer', () async {
        handler.handleToneDetected();
        handler.handleToneStopped(); // dot
        handler.dispose();

        await Future.delayed(const Duration(milliseconds: 1600));
        expect(capturedPattern, isNull);
      });
    });
  });
}
