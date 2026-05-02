import 'dart:async';
import 'package:flutter/services.dart';

typedef KeyerCallback = void Function(String morsePattern);

class KeyboardKeyerHandler {
  final KeyerCallback onPatternComplete;
  final VoidCallback? onKeyDown;
  final VoidCallback? onKeyUp;
  final int dotDurationMs;
  final int dashDurationMs;

  String _pattern = '';
  Timer? _autoSubmitTimer;

  static final Map<String, String> _morseToChar = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z', '-----': '0', '.----': '1', '..---': '2', '...--': '3',
    '....-': '4', '.....': '5', '-....': '6', '--...': '7', '---..': '8',
    '----.': '9', '.-.-.-': '.', '--..--': ',', '..--..': '?', '-..-.': '/',
  };

  KeyboardKeyerHandler({
    required this.onPatternComplete,
    this.onKeyDown,
    this.onKeyUp,
    required this.dotDurationMs,
    required this.dashDurationMs,
  });

  void handleKeyDown() {
    onKeyDown?.call();
  }

  void handleKeyUp(int durationMs) {
    onKeyUp?.call();

    // Threshold = 2x dot duration (midpoint between dot=dash*1 and dash=dash*3)
    final threshold = dotDurationMs * 2;
    final symbol = durationMs >= threshold ? '-' : '.';
    _pattern += symbol;

    print('HANDLER: Pattern now: "$_pattern"');

    // Try to submit - but do it via timer to allow UI to show pattern first
    _scheduleAutoSubmit();
  }

  void _scheduleAutoSubmit() {
    _autoSubmitTimer?.cancel();
    // Wait 1500ms after each symbol - time for multi-element chars
    _autoSubmitTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
        final pattern = _pattern;
        final char = _morseToChar[pattern] ?? '?';
        print('HANDLER: Auto-submitting pattern "$pattern" -> "$char"');

        // Pass pattern FIRST, then clear
        onPatternComplete(pattern);
        _pattern = '';
      }
    });
  }

  // Manual submit (called when user explicitly submits)
  void submitNow() {
    _autoSubmitTimer?.cancel();
    if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
      final pattern = _pattern;
      final char = _morseToChar[pattern] ?? '?';
      print('HANDLER: Manual submit pattern "$pattern" -> "$char"');
      onPatternComplete(pattern);
      _pattern = '';
    }
  }

  String get currentPattern => _pattern;

  void clearPattern() {
    print('HANDLER: clearPattern called, clearing "$_pattern"');
    _autoSubmitTimer?.cancel();
    _pattern = '';
    print('HANDLER: Pattern after clear: "$_pattern"');
  }

  void dispose() {
    _autoSubmitTimer?.cancel();
  }
}