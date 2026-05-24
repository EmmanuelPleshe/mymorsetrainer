import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/audio/morse_code_service.dart';

late bool _aplayAvailable;

void main() {
  try {
    final result = Process.runSync('which', ['aplay']);
    _aplayAvailable = result.exitCode == 0;
  } catch (_) {
    _aplayAvailable = false;
  }

  group('AudioPlaybackService', () {
    late AudioPlaybackService service;

    setUp(() {
      service = AudioPlaybackService();
    });

    tearDown(() async {
      // Clean up generated files so they don't leak between tests.
      for (final path in [
        '/tmp/morse_dot.wav',
        '/tmp/morse_dash.wav',
        '/tmp/morse_keyer.wav',
        '/tmp/morse_correct.wav',
      ]) {
        try {
          File(path).deleteSync();
        } catch (_) {}
      }
    });

    group('regression: missing audio files', () {
      test('initialize creates required wav files', () async {
        await service.initialize();

        expect(File('/tmp/morse_dot.wav').existsSync(), true);
        expect(File('/tmp/morse_dash.wav').existsSync(), true);
        expect(File('/tmp/morse_keyer.wav').existsSync(), true);
      });

      test(
        'keyerDown recreates missing keyer file instead of silently failing',
        skip: !_aplayAvailable,
        () async {
          await service.initialize();
          expect(File('/tmp/morse_keyer.wav').existsSync(), true);

          // Simulate file disappearance (e.g. /tmp cleaned or new computer)
          File('/tmp/morse_keyer.wav').deleteSync();
          expect(File('/tmp/morse_keyer.wav').existsSync(), false);

          await service.keyerDown();

          // Service must detect the missing file and regenerate it
          expect(File('/tmp/morse_keyer.wav').existsSync(), true);
        },
      );

      test(
        'playCharacter recreates missing dot/dash files instead of silently failing',
        skip: !_aplayAvailable,
        () async {
          await service.initialize();

          // Delete both playback files
          File('/tmp/morse_dot.wav').deleteSync();
          File('/tmp/morse_dash.wav').deleteSync();

          // Character 'A' = '.-' needs dot and dash
          await service.playCharacter('A');

          expect(File('/tmp/morse_dot.wav').existsSync(), true);
          expect(File('/tmp/morse_dash.wav').existsSync(), true);
        },
      );

      test('playCorrectFeedback recreates its own file',
        skip: !_aplayAvailable,
        () async {
        await service.initialize();

        // Delete the feedback file if it exists from a previous run
        try {
          File('/tmp/morse_correct.wav').deleteSync();
        } catch (_) {}

        await service.playCorrectFeedback();

        expect(File('/tmp/morse_correct.wav').existsSync(), true);
      });
    });

    group('timing', () {
      test('unit duration at 20 WPM is 60 ms', () {
        service.setWpm(20);
        expect(service.unitMs, 60);
        expect(service.dotDurationMs, 60);
        expect(service.dashDurationMs, 180);
      });

      test('unit duration at 10 WPM is 120 ms', () {
        service.setWpm(10);
        expect(service.unitMs, 120);
        expect(service.dotDurationMs, 120);
        expect(service.dashDurationMs, 360);
      });

      test('Farnsworth interCharSpace increases when effWpm < wpm', () {
        service.setWpm(20);
        service.setEffWpm(10);
        // Standard inter-char at 20 WPM = 180 ms
        // Farnsworth at 10/20 adds ~1443 ms extra
        expect(service.interCharacterSpaceMs, greaterThan(180));
      });

      test('Farnsworth interWordSpace increases when effWpm < wpm', () {
        service.setWpm(20);
        service.setEffWpm(10);
        // Standard inter-word at 20 WPM = 420 ms
        // Farnsworth at 10/20 adds ~3367 ms extra
        expect(service.interWordSpaceMs, greaterThan(420));
      });

      test('standard spacing when effWpm >= wpm', () {
        service.setWpm(15);
        service.setEffWpm(15);
        expect(service.interCharacterSpaceMs, 80 * 3);
        expect(service.interWordSpaceMs, 80 * 7);
      });

      test('extraWordSpace adds to interWordSpace when effWpm >= wpm', () {
        service.setWpm(20);
        service.setEffWpm(20);
        service.setExtraWordSpace(0.5);
        expect(service.interWordSpaceMs, (60 * 7) + 500);
      });

      test('extraWordSpace adds to Farnsworth interWordSpace', () {
        service.setWpm(20);
        service.setEffWpm(10);
        service.setExtraWordSpace(0.3);
        final base = service.interWordSpaceMs - 300;
        expect(service.interWordSpaceMs, base + 300);
      });

      test('timingEngine reflects current WPM settings', () {
        service.setWpm(15);
        service.setEffWpm(15);
        expect(service.timingEngine.dotDurationMs, 80);
        expect(service.timingEngine.keyerDotDashThresholdMs, 240);
      });
    });

    group('setters clamp values', () {
      test('setToneFrequency clamps to 300-2000', () {
        service.setToneFrequency(100);
        expect(service.toneFrequency, 300);
        service.setToneFrequency(2500);
        expect(service.toneFrequency, 2000);
        service.setToneFrequency(600);
        expect(service.toneFrequency, 600);
      });

      test('setWpm clamps to 5-40', () {
        service.setWpm(1);
        expect(service.wpm, 5);
        service.setWpm(50);
        expect(service.wpm, 40);
        service.setWpm(20);
        expect(service.wpm, 20);
      });

      test('setEffWpm clamps to 5-40', () {
        service.setEffWpm(1);
        expect(service.effWpm, 5);
        service.setEffWpm(50);
        expect(service.effWpm, 40);
        service.setEffWpm(10);
        expect(service.effWpm, 10);
      });

      test('setExtraWordSpace clamps to 0-5', () {
        service.setExtraWordSpace(-1);
        expect(service.extraWordSpace, 0);
        service.setExtraWordSpace(10);
        expect(service.extraWordSpace, 5);
        service.setExtraWordSpace(0.5);
        expect(service.extraWordSpace, 0.5);
      });

      test('setVolume clamps to 0-1', () {
        service.setVolume(-0.5);
        expect(service.volume, 0);
        service.setVolume(1.5);
        expect(service.volume, 1);
        service.setVolume(0.75);
        expect(service.volume, 0.75);
      });
    });

    group('dispose', () {
      test('dispose deletes generated files', () async {
        await service.initialize();
        expect(File('/tmp/morse_dot.wav').existsSync(), true);

        await service.dispose();

        expect(File('/tmp/morse_dot.wav').existsSync(), false);
        expect(File('/tmp/morse_dash.wav').existsSync(), false);
        expect(File('/tmp/morse_keyer.wav').existsSync(), false);
      });
    });
  });
}
