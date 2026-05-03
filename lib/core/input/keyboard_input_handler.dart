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

  // Adaptive threshold: learns from user's keying speed
  final List<int> _recentDurations = [];
  static const int _historySize = 20;  // Keep last 20 key presses
  int _adaptiveThreshold = 0;  // 0 = use default, otherwise learned

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

    // Update adaptive threshold from user's keying
    _updateAdaptiveThreshold(durationMs);

    // Use adaptive threshold if learned, otherwise default
    final threshold = _adaptiveThreshold > 0 ? _adaptiveThreshold : dotDurationMs * 2;
    final symbol = durationMs >= threshold ? '-' : '.';
    _pattern += symbol;

    print('HANDLER: Key up after $durationMs ms, threshold=$threshold, symbol=$symbol');

    // Try to submit - but do it via timer to allow UI to show pattern first
    _scheduleAutoSubmit();
  }

  void _updateAdaptiveThreshold(int durationMs) {
    // Add to history
    _recentDurations.add(durationMs);
    if (_recentDurations.length > _historySize) {
      _recentDurations.removeAt(0);
    }

    // Estimate dot duration from short presses (bottom 30% of durations)
    if (_recentDurations.length >= 5) {
      final sorted = List<int>.from(_recentDurations)..sort();
      final shortPresses = sorted.take((sorted.length * 0.3).ceil()).toList();
      final avgShort = shortPresses.reduce((a, b) => a + b) ~/ shortPresses.length;

      // Threshold = 2x estimated dot duration
      _adaptiveThreshold = avgShort * 2;
      print('HANDLER: Adaptive threshold updated to $_adaptiveThreshold ms (from $shortPresses)');
    }
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