import 'package:flutter/services.dart';

class KeyboardInputHandler {
  final Function(String) onCharacterInput;
  final VoidCallback? onBackspace;

  KeyboardInputHandler({
    required this.onCharacterInput,
    this.onBackspace,
  });

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final character = event.character;
      if (character != null && character.isNotEmpty) {
        onCharacterInput(character.toUpperCase());
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        onBackspace?.call();
      }
    }
  }
}
