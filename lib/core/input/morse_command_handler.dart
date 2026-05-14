import 'dart:async';
import 'keyboard_input_handler.dart';
import '../timing/morse_timing_engine.dart';

/// Wraps [KeyboardKeyerHandler] to accumulate decoded letters into words.
/// When a word boundary is detected, the full word is submitted to [onCommand].
class MorseCommandHandler {
  final MorseTimingEngine timingEngine;
  final void Function(String command) onCommand;
  String _wordBuffer = '';
  bool _manualSubmit = false;
  DateTime? _lastKeyUpTime;
  Timer? _wordGapTimer;
  KeyboardKeyerHandler? _keyer;

  MorseCommandHandler({
    required this.timingEngine,
    required this.onCommand,
  }) {
    _keyer = KeyboardKeyerHandler(
      timingEngine: timingEngine,
      onPatternComplete: (pattern) {
        final char = _decodePattern(pattern);
        _wordBuffer += char;
        if (!_manualSubmit && _wordBuffer.length >= 2) {
          onCommand(_wordBuffer.toLowerCase());
          _wordBuffer = '';
        }
        _resetWordGapTimer();
      },
    );
  }

  void _resetWordGapTimer() {
    _wordGapTimer?.cancel();
    _wordGapTimer = Timer(
      Duration(milliseconds: timingEngine.keyerInterWordThresholdMs + 50),
      () {
        if (_wordBuffer.length >= 2) {
          onCommand(_wordBuffer.toLowerCase());
          _wordBuffer = '';
        }
      },
    );
  }

  void handleKeyDown() {
    final now = DateTime.now();
    if (_lastKeyUpTime != null) {
      final gap = now.difference(_lastKeyUpTime!).inMilliseconds;
      if (gap >= timingEngine.dotDurationMs * 2) {
        try {
          _manualSubmit = true;
          _keyer?.submitNow();
        } finally {
          _manualSubmit = false;
        }
      }
    }
    _wordGapTimer?.cancel();
    _keyer?.handleKeyDown();
  }

  void handleKeyUp(int durationMs) {
    _keyer?.handleKeyUp(durationMs);
    _lastKeyUpTime = DateTime.now();
  }

  String _decodePattern(String pattern) {
    const map = {
      '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
      '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
      '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
      '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
      '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
      '--..': 'Z',
    };
    return map[pattern] ?? '?';
  }

  void flush() {
    _wordGapTimer?.cancel();
    if (_wordBuffer.isNotEmpty) {
      onCommand(_wordBuffer.toLowerCase());
      _wordBuffer = '';
    }
    _lastKeyUpTime = null;
  }

  void dispose() {
    _wordGapTimer?.cancel();
    _keyer?.dispose();
  }
}
