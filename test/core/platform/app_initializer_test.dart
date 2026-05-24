import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/platform/app_initializer.dart';

void main() {
  group('AppInitializer', () {
    test('does not call desktop-only APIs on mobile platforms', () async {
      bool windowManagerCalled = false;
      bool sqfliteFfiCalled = false;

      final initializer = AppInitializer(
        initializeWindowManager: () async => windowManagerCalled = true,
        initializeSqfliteFfi: () => sqfliteFfiCalled = true,
        initializeLogger: () async {},
        initializeCharacterRepo: () async {},
        isDesktop: false,
      );

      await initializer.initialize();

      expect(windowManagerCalled, isFalse,
          reason: 'windowManager should not be initialized on mobile');
      expect(sqfliteFfiCalled, isFalse,
          reason: 'sqflite FFI should not be initialized on mobile');
    });

    test('calls desktop-only APIs on desktop platforms', () async {
      bool windowManagerCalled = false;
      bool sqfliteFfiCalled = false;

      final initializer = AppInitializer(
        initializeWindowManager: () async => windowManagerCalled = true,
        initializeSqfliteFfi: () => sqfliteFfiCalled = true,
        initializeLogger: () async {},
        initializeCharacterRepo: () async {},
        isDesktop: true,
      );

      await initializer.initialize();

      expect(windowManagerCalled, isTrue,
          reason: 'windowManager should be initialized on desktop');
      expect(sqfliteFfiCalled, isTrue,
          reason: 'sqflite FFI should be initialized on desktop');
    });
  });
}
