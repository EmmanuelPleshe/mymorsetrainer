import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/input/morse_command_handler.dart';
import 'package:morse_trainer/core/timing/morse_timing_engine.dart';

void main() {
  group('MorseCommandHandler', () {
    test('accumulates two letters and fires command on word gap', () async {
      String? receivedCommand;
      final handler = MorseCommandHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onCommand: (cmd) => receivedCommand = cmd,
      );

      // Key 's' = '...'
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60)); // dot
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60)); // dot
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60)); // dot
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);

      // Letter gap (60ms < word gap ~540ms)
      await Future.delayed(const Duration(milliseconds: 150));

      // Key 'p' = '.--.'
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60)); // dot
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60)); // dash
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 180));
      handler.handleKeyUp(180);
      await Future.delayed(const Duration(milliseconds: 60)); // dash
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 180));
      handler.handleKeyUp(180);
      await Future.delayed(const Duration(milliseconds: 60)); // dot
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);

      // Word gap
      await Future.delayed(const Duration(milliseconds: 600));

      expect(receivedCommand, 'sp');
    });

    test('single letter does not fire command', () async {
      String? receivedCommand;
      final handler = MorseCommandHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onCommand: (cmd) => receivedCommand = cmd,
      );

      // Key 'x' = '-..-'
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 180));
      handler.handleKeyUp(180);
      await Future.delayed(const Duration(milliseconds: 600));

      // Letter gap passes, word gap fires
      await Future.delayed(const Duration(milliseconds: 600));

      expect(receivedCommand, null);
    });

    test('flush submits current buffer', () async {
      String? receivedCommand;
      final handler = MorseCommandHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onCommand: (cmd) => receivedCommand = cmd,
      );

      // Key 's' = '...'
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);

      // Letter gap
      await Future.delayed(const Duration(milliseconds: 150));

      // Key 'p' = '.--.'
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 180));
      handler.handleKeyUp(180);
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 180));
      handler.handleKeyUp(180);
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);

      // Flush before word gap
      handler.flush();

      expect(receivedCommand, 'sp');
    });

    test('dispose cancels timers', () async {
      String? receivedCommand;
      final handler = MorseCommandHandler(
        timingEngine: MorseTimingEngine(wpm: 20, effWpm: 20),
        onCommand: (cmd) => receivedCommand = cmd,
      );

      // Key 's' = '...'
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyDown();
      await Future.delayed(const Duration(milliseconds: 60));
      handler.handleKeyUp(60);

      // Dispose before word gap
      handler.dispose();

      // Wait for original word gap
      await Future.delayed(const Duration(milliseconds: 700));

      expect(receivedCommand, null);
    });
  });
}
