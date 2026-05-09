# Quickstart: Settings Persistence

## Prerequisites

- Flutter SDK installed
- `flutter pub get` already run (dependencies in pubspec.yaml)

## Run the App

```bash
cd /home/eman/github/mymorsetrainer
flutter run
```

## Verify the Feature

1. Open **Settings** tab (bottom nav)
2. Adjust **Speed (WPM)** to 25
3. Adjust **Tone Frequency** to 700 Hz
4. Adjust **Volume** to 30%
5. Go to **Practice** tab and start playback — confirm new tone/speed/volume
6. Close app (`Ctrl+C` or window close)
7. Re-run `flutter run`
8. Open **Settings** tab — confirm values restored to 25 WPM, 700 Hz, 30% volume
9. Start playback — confirm restored settings applied immediately

## Run Tests

```bash
flutter test
```

Expected: all settings persistence tests pass.

## Test Individual Components

### SettingsBloc unit tests
```bash
flutter test test/unit/settings_bloc_test.dart
```

### SettingsRepository unit tests
```bash
flutter test test/unit/settings_repository_test.dart
```

### Integration test (cold start)
```bash
flutter test test/integration/settings_startup_test.dart
```
