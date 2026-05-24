# Test Coverage Audit

## Current State

| Layer | Files | Test Coverage |
|-------|-------|----------------|
| Domain | 5 services | 2 tests (PointsCalculator) |
| Data | 4 repositories | 0 tests |
| Core/Audio | 1 service | 1 test (partial - timing only) |
| Core/Input | 1 handler | 0 tests |
| Core/Logging | 2 files | 0 tests |
| BLoC | 1 bloc | 0 tests |
| UI | 1 screen | 1 smoke test |
| **Total** | ~18 files | **4 passing tests** |

---

## Testable Units by Layer

### Domain Layer

| File | Class/Methods | Risk | Priority |
|------|----------------|------|----------|
| `koch_progression_service.dart` | `getPracticeCharacters()`, `recordAttempt()`, `canAdvanceLevel()`, `unlockNextCharacters()` | HIGH | P1 |
| `spaced_repetition_service.dart` | `scheduleReview()`, SM-2 algorithm | HIGH | P1 |
| `gamification_service.dart` | `recordCorrectAnswer()`, `recordIncorrectAnswer()`, `completeSession()` | MED | P2 |
| `qso_service.dart` | QSO call sign generation | LOW | P3 |
| `word_practice_service.dart` | Word generation from characters | LOW | P3 |

### Data Layer

| File | Class/Methods | Risk | Priority |
|------|----------------|------|----------|
| `user_progress_repository.dart` | `getUserProgress()`, `updateUserProgress()`, `getCurrentLevel()` | HIGH | P1 |
| `settings_repository.dart` | `getSettings()`, `saveSettings()` | MED | P2 |
| `character_repository.dart` | Character CRUD | LOW | P3 |
| `backup_repository.dart` | Export/import | LOW | P3 |

### Core Layer

| File | Class/Methods | Risk | Priority |
|------|----------------|------|----------|
| `keyboard_input_handler.dart` | `handleKeyDown()`, `handleKeyUp()`, `_scheduleAutoSubmit()`, `clearPattern()`, `currentPattern` | CRITICAL | P0 |
| `morse_code_service.dart` | `AudioPlaybackService` - all timing + playback methods | HIGH | P1 |
| `logger.dart` | `initialize()`, `log()`, `debug/info/warning/error()`, `sendLogs()`, `getLogDirectory()` | HIGH | P1 |
| `log_entry.dart` | `toLogLine()` | MED | P2 |

### BLoC Layer

| File | Class/Methods | Risk | Priority |
|------|----------------|------|----------|
| `practice_session_bloc.dart` | All event handlers: `_onStartSession`, `_onSubmitMorsePattern`, `_onNextCharacter`, `_onPlayCurrentCharacter`, `_onCompleteOnboarding` | CRITICAL | P0 |

### UI Layer

| File | Class/Methods | Risk | Priority |
|------|----------------|------|----------|
| `practice_screen.dart` | `_handleKeyEvent`, `_playCharacterAudio`, `_initKeyer`, listener logic | HIGH | P1 |
| `settings_screen.dart` | Settings UI | MED | P2 |
| `onboarding_screen.dart` | Onboarding flow | LOW | P3 |

---

## Risk Assessment

### CRITICAL (Must Test Now)
1. **KeyboardKeyerHandler auto-submit timing** — Current bug: premature submit
2. **PracticeSessionBloc retry state** — Current bug: stuck after wrong answer
3. **Race condition: timer vs BLoC** — Key events during state transitions

### HIGH (Next Sprint)
1. SM-2 algorithm correctness
2. Koch progression unlock logic
3. Audio timing calculations (Farnsworth)
4. Log file rotation

### MEDIUM
1. Settings persistence
2. Points calculation
3. UI state transitions

### LOW
1. QSO call signs
2. Word generation
3. Backup/restore

---

## Test Infrastructure

### Missing Dependencies (add to pubspec.yaml)
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7       # MISSING
  mocktail: ^1.0.4        # MISSING - preferred over mockito
  fake_async: ^1.3.2      # MISSING - built into flutter_test
```

### Directory Structure
```
test/
├── helpers/
│   ├── mocks/           # Manual mocks for external deps
│   │   ├── mock_audio_service.dart
│   │   ├── mock_file_system.dart
│   │   └── mock_keyboard.dart
│   └── test_helpers.dart
├── core/
│   ├── input/
│   │   └── keyboard_input_handler_test.dart
│   ├── logging/
│   │   ├── logger_test.dart
│   │   └── log_entry_test.dart
│   └── audio/
│       └── morse_code_service_test.dart
├── domain/
│   ├── koch/
│   │   └── koch_progression_service_test.dart
│   ├── spaced_repetition/
│   │   └── spaced_repetition_service_test.dart
│   └── gamification/
│       └── gamification_service_test.dart
├── data/
│   └── repositories/
│       └── user_progress_repository_test.dart
├── bloc/
│   └── practice_session_bloc_test.dart
├── ui/
│   └── screens/
│       └── practice_screen_test.dart
└── widget_test.dart
```

---

## Game Loop Regression Tests (Priority 0)

These tests MUST be written BEFORE fixing the bugs:

### Test 1: Premature Auto-Submit
```dart
test('regression: does not auto-submit while user is still keying', () {
  // Key down, wait 2 units (not 3), key up
  // Should NOT trigger auto-submit
});
```

### Test 2: Stuck Retry State
```dart
test('regression: allows retry after wrong answer', () {
  // Submit wrong pattern
  // Wait for feedback
  // Verify state allows new input
  // Verify audio does NOT replay during retry window
});
```

### Test 3: Double-Processing Race
```dart
test('regression: rapid key events do not double-process', () {
  // Key pattern, wait 100ms, key another pattern
  // Only first pattern should be processed
});
```

### Test 4: Full Game Loop Integration
```dart
test('integration: full key → submit → wrong → retry → correct → advance', () {
  // Key K pattern
  // Submit (wrong)
  // See feedback
  // Retry with correct pattern
  // Verify advance to next character
});
```

---

## Next Steps

1. Add missing test dependencies to pubspec.yaml
2. Create `test/helpers/` with mocks
3. Write CRITICAL regression tests (P0)
4. Run `flutter test` to verify infrastructure
5. Fix game loop bugs (now backed by tests)
6. Expand to HIGH priority layer