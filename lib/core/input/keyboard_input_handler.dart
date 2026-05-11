import 'dart:async';
import 'package:flutter/services.dart';
import '../logging/logger.dart';
import '../logging/log_constants.dart';

typedef KeyerCallback = void Function(String morsePattern);

class KeyboardKeyerHandler {
  final KeyerCallback onPatternComplete;
  final VoidCallback? onKeyDown;
  final VoidCallback? onKeyUp;
  final int dotDurationMs;
  final int dashDurationMs;
  final int interLetterThresholdMs;
  final int interWordThresholdMs;

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
    required this.dotDurationMs,
    required this.dashDurationMs,
    int? interLetterThresholdMs,
    int? interWordThresholdMs,
  })  : interLetterThresholdMs = interLetterThresholdMs ?? dotDurationMs * 3,
        interWordThresholdMs = interWordThresholdMs ?? 400;

  void handleKeyDown() {
    if (!_acceptInput) return;
    // Cancel any pending auto-submit - user is continuing to key
    _autoSubmitTimer?.cancel();
    onKeyDown?.call();
  }

  void handleKeyUp(int durationMs) {
    onKeyUp?.call();

    // Use fixed WPM-based threshold: 3× dot duration
    // At 20 WPM: 3×60ms = 180ms threshold
    final threshold = dotDurationMs * 3;
    final symbol = durationMs >= threshold ? '-' : '.';
    _pattern += symbol;

    Logger().debug(LogCategory.ui, 'Key up after $durationMs ms, threshold=$threshold, symbol=$symbol');

    // Try to submit - but do it via timer to allow UI to show pattern first
    _scheduleAutoSubmit();
  }

  void _scheduleAutoSubmit() {
    _autoSubmitTimer?.cancel();

    _autoSubmitTimer = Timer(Duration(milliseconds: interWordThresholdMs), () {
      if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
        final pattern = _pattern;
        final char = _morseToChar[pattern] ?? '?';
        Logger().debug(LogCategory.ui, 'Auto-submitting pattern "$pattern" -> "$char" after ${interWordThresholdMs}ms');
        onPatternComplete(pattern);
        _pattern = '';
      } else if (_pattern.isNotEmpty) {
        // Pattern incomplete (not in lookup) - treat as wrong char, submit anyway
        Logger().debug(LogCategory.ui, 'Incomplete pattern "$_pattern" - submitting anyway');
        onPatternComplete(_pattern);
        _pattern = '';
      }
    });
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