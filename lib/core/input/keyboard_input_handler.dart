import 'dart:async';
import 'package:flutter/services.dart';
import '../logging/logger.dart';
import '../logging/log_constants.dart';
import '../timing/morse_timing_engine.dart';

typedef KeyerCallback = void Function(String morsePattern);

class KeyboardKeyerHandler {
  final KeyerCallback onPatternComplete;
  final VoidCallback? onKeyDown;
  final VoidCallback? onKeyUp;
  final MorseTimingEngine timingEngine;

  String _pattern = '';
  Timer? _autoSubmitTimer;
  bool _acceptInput = true;

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
    required this.timingEngine,
  });

  void handleKeyDown() {
    if (!_acceptInput) return;
    // Cancel any pending auto-submit - user is continuing to key
    _autoSubmitTimer?.cancel();
    onKeyDown?.call();
  }

  void handleKeyUp(int durationMs) {
    onKeyUp?.call();

    final threshold = timingEngine.keyerDotDashThresholdMs;
    final symbol = durationMs >= threshold ? '-' : '.';
    _pattern += symbol;

    Logger().debug(LogCategory.ui, 'Key up after $durationMs ms, threshold=$threshold, symbol=$symbol');

    _scheduleAutoSubmit();
  }

  void _scheduleAutoSubmit() {
    _autoSubmitTimer?.cancel();

    _autoSubmitTimer = Timer(
      Duration(milliseconds: timingEngine.keyerInterWordThresholdMs),
      () {
        if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
          final pattern = _pattern;
          final char = _morseToChar[pattern] ?? '?';
          Logger().debug(LogCategory.ui, 'Auto-submitting pattern "$pattern" -> "$char" after ${timingEngine.keyerInterWordThresholdMs}ms');
          onPatternComplete(pattern);
          _pattern = '';
        } else if (_pattern.isNotEmpty) {
          Logger().debug(LogCategory.ui, 'Incomplete pattern "$_pattern" - submitting anyway');
          onPatternComplete(_pattern);
          _pattern = '';
        }
      },
    );
  }

  // Manual submit (called when user explicitly submits)
  void submitNow() {
    _autoSubmitTimer?.cancel();
    if (_pattern.isNotEmpty) {
      final pattern = _pattern;
      Logger().debug(LogCategory.ui, 'Manual submit pattern "$pattern"');
      onPatternComplete(pattern);
      _pattern = '';
    }
  }

  String get currentPattern => _pattern;

  void clearPattern() {
    Logger().debug(LogCategory.ui, 'clearPattern called, clearing "$_pattern"');
    _autoSubmitTimer?.cancel();
    _pattern = '';
    Logger().debug(LogCategory.ui, 'Pattern after clear: "$_pattern"');
  }

  void setAcceptInput(bool accept) {
    _acceptInput = accept;
    if (!accept) {
      _autoSubmitTimer?.cancel();
    }
  }

  void dispose() {
    _autoSubmitTimer?.cancel();
  }
}