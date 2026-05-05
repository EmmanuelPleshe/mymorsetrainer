import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

class MockHardwareKeyboard extends Mock implements HardwareKeyboard {}

/// Test utilities for simulating keyboard events.
/// Note: Flutter requires both logicalKey and physicalKey as separate
/// arguments; they are no longer linked on PhysicalKeyboardKey.
class KeyboardTestUtils {
  static KeyDownEvent keyDown({
    LogicalKeyboardKey logicalKey = LogicalKeyboardKey.space,
    PhysicalKeyboardKey physicalKey = PhysicalKeyboardKey.space,
  }) {
    return KeyDownEvent(
      logicalKey: logicalKey,
      physicalKey: physicalKey,
      timeStamp: Duration.zero,
    );
  }

  static KeyUpEvent keyUp({
    LogicalKeyboardKey logicalKey = LogicalKeyboardKey.space,
    PhysicalKeyboardKey physicalKey = PhysicalKeyboardKey.space,
    Duration downDuration = const Duration(milliseconds: 100),
  }) {
    return KeyUpEvent(
      logicalKey: logicalKey,
      physicalKey: physicalKey,
      timeStamp: downDuration,
    );
  }

  static KeyRepeatEvent keyRepeat({
    LogicalKeyboardKey logicalKey = LogicalKeyboardKey.space,
    PhysicalKeyboardKey physicalKey = PhysicalKeyboardKey.space,
  }) {
    return KeyRepeatEvent(
      logicalKey: logicalKey,
      physicalKey: physicalKey,
      timeStamp: Duration.zero,
    );
  }
}
