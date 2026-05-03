import 'dart:async';
import 'package:flutter/services.dart';

typedef KeyerCallback = void Function(String morsePattern);

class GameControllerKeyerHandler {
  final KeyerCallback onPatternComplete;
  final VoidCallback? onKeyDown;
  final VoidCallback? onKeyUp;
  final int dotDurationMs;
  final int dashDurationMs;

  String _pattern = '';
  Timer? _autoSubmitTimer;
  bool _isPressed = false;

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

  GameControllerKeyerHandler({
    required this.onPatternComplete,
    this.onKeyDown,
    this.onKeyUp,
    required this.dotDurationMs,
    required this.dashDurationMs,
  });

  void handleButtonDown() {
    if (_isPressed) return;
    _isPressed = true;
    onKeyDown?.call();
  }

  void handleButtonUp(int durationMs) {
    if (!_isPressed) return;
    _isPressed = false;
    onKeyUp?.call();

    final threshold = dotDurationMs * 2;
    final symbol = durationMs >= threshold ? '-' : '.';
    _pattern += symbol;

    _scheduleAutoSubmit();
  }

  void _scheduleAutoSubmit() {
    _autoSubmitTimer?.cancel();
    _autoSubmitTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
        final pattern = _pattern;
        onPatternComplete(pattern);
        _pattern = '';
      }
    });
  }

  void submitNow() {
    _autoSubmitTimer?.cancel();
    if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
      final pattern = _pattern;
      onPatternComplete(pattern);
      _pattern = '';
    }
  }

  String get currentPattern => _pattern;

  void clearPattern() {
    _autoSubmitTimer?.cancel();
    _pattern = '';
    _isPressed = false;
  }

  void dispose() {
    _autoSubmitTimer?.cancel();
  }
}