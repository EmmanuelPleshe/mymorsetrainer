import 'dart:async';
import 'package:flutter/material.dart';

enum TouchEventType { down, up }

class TouchEvent {
  final TouchEventType type;
  final DateTime timestamp;

  TouchEvent(this.type, this.timestamp);
}

class TouchscreenInputHandler {
  final Function(String) onMorseInput;
  final VoidCallback? onError;

  DateTime? _touchStartTime;
  final List<Duration> _dotsAndDashes = [];
  Timer? _timeoutTimer;
  static const Duration _dotThreshold = Duration(milliseconds: 200);
  static const Duration _letterTimeout = Duration(milliseconds: 1000);

  TouchscreenInputHandler({
    required this.onMorseInput,
    this.onError,
  });

  void onTouchDown() {
    _touchStartTime = DateTime.now();
    _timeoutTimer?.cancel();
  }

  void onTouchUp() {
    if (_touchStartTime == null) return;

    final duration = DateTime.now().difference(_touchStartTime!);
    _dotsAndDashes.add(duration);
    _touchStartTime = null;

    // Start timeout for letter completion
    _timeoutTimer = Timer(_letterTimeout, () {
      _processInput();
    });
  }

  void _processInput() {
    if (_dotsAndDashes.isEmpty) return;

    final morsePattern = _dotsAndDashes.map((duration) {
      return duration < _dotThreshold ? '.' : '-';
    }).join();

    // Convert morse pattern to character
    final character = _morseToCharacter(morsePattern);
    if (character != null) {
      onMorseInput(character);
    } else {
      onError?.call();
    }

    _dotsAndDashes.clear();
  }

  String? _morseToCharacter(String pattern) {
    final morseMap = {
      '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
      '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
      '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
      '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
      '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
      '--..': 'Z',
    };
    return morseMap[pattern];
  }

  void dispose() {
    _timeoutTimer?.cancel();
  }
}
