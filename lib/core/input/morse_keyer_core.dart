import 'dart:async';
import 'package:flutter/foundation.dart';
import '../timing/morse_timing_engine.dart';

typedef SymbolCallback = void Function(String symbol);
typedef LetterCallback = void Function(String character, String pattern);
typedef UnknownPatternCallback = void Function(String pattern);
typedef WordBoundaryCallback = void Function();

class MorseKeyerCore {
  final MorseTimingEngine timingEngine;
  final SymbolCallback? onSymbol;
  final LetterCallback? onLetterComplete;
  final UnknownPatternCallback? onUnknownPattern;
  final WordBoundaryCallback? onWordBoundary;
  final VoidCallback? onKeyDown;
  final VoidCallback? onKeyUp;

  String _pattern = '';
  Timer? _letterTimer;
  Timer? _wordTimer;

  MorseKeyerCore({
    required this.timingEngine,
    this.onSymbol,
    this.onLetterComplete,
    this.onUnknownPattern,
    this.onWordBoundary,
    this.onKeyDown,
    this.onKeyUp,
  });

  void handleKeyDown() {
    _letterTimer?.cancel();
    _wordTimer?.cancel();
    onKeyDown?.call();
  }

  void handleKeyUp(int durationMs) {
    onKeyUp?.call();
    final symbol = durationMs < timingEngine.keyerDotDashThresholdMs ? '.' : '-';
    _pattern += symbol;
    onSymbol?.call(symbol);
    _startLetterTimer();
  }

  void _startLetterTimer() {
    _letterTimer?.cancel();
    _letterTimer = Timer(
      Duration(milliseconds: timingEngine.keyerInterLetterThresholdMs),
      _finalizeLetter,
    );
  }

  void _finalizeLetter() {
    if (_pattern.isEmpty) return;
    final pattern = _pattern;
    _pattern = '';
    final char = _morseToChar[pattern];
    if (char != null) {
      onLetterComplete?.call(char, pattern);
    } else {
      onUnknownPattern?.call(pattern);
    }
    _startWordTimer();
  }

  void _startWordTimer() {
    _wordTimer?.cancel();
    _wordTimer = Timer(
      Duration(milliseconds: timingEngine.keyerInterWordThresholdMs),
      () => onWordBoundary?.call(),
    );
  }

  void submitNow() {
    _letterTimer?.cancel();
    _wordTimer?.cancel();
    if (_pattern.isNotEmpty) {
      _finalizeLetterNow();
    }
  }

  void _finalizeLetterNow() {
    final pattern = _pattern;
    _pattern = '';
    final char = _morseToChar[pattern];
    if (char != null) {
      onLetterComplete?.call(char, pattern);
    } else {
      onUnknownPattern?.call(pattern);
    }
  }

  void clear() {
    _letterTimer?.cancel();
    _wordTimer?.cancel();
    _pattern = '';
  }

  void dispose() {
    _letterTimer?.cancel();
    _wordTimer?.cancel();
  }

  String get currentPattern => _pattern;

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
}
