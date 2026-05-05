import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/audio/morse_code_service.dart';

void main() {
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

      test('playCorrectFeedback recreates its own file', () async {
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
    });
  });
}
