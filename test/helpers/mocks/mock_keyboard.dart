import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

class MockHardwareKeyboard extends Mock implements HardwareKeyboard {}

class FakeKeyEvent extends Fake implements KeyEvent {}

/// Test utilities for simulating keyboard events
class KeyboardTestUtils {
  static KeyDownEvent keyDown({PhysicalKeyboardKey? key}) {
    return KeyDownEvent(
      logicalKey: key?.logicalKey ?? LogicalKeyboardKey.space,
      physicalKey: key ?? PhysicalKeyboardKey.space,
      timeStamp: Duration.zero,
    );
  }

  static KeyUpEvent keyUp({PhysicalKeyboardKey? key, Duration downDuration = const Duration(milliseconds: 100)}) {
    return KeyUpEvent(
      logicalKey: key?.logicalKey ?? LogicalKeyboardKey.space,
      physicalKey: key ?? PhysicalKeyboardKey.space,
      timeStamp: downDuration,
    );
  }

  static KeyRepeatEvent keyRepeat({PhysicalKeyboardKey? key}) {
    return KeyRepeatEvent(
      logicalKey: key?.logicalKey ?? LogicalKeyboardKey.space,
      physicalKey: key ?? PhysicalKeyboardKey.space,
      timeStamp: Duration.zero,
    );
  }
}