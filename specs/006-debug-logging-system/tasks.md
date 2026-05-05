# Tasks: Debug Logging System

**Feature**: Debug Logging System  
**Branch**: `006-debug-logging-system`  
**Generated**: 2026-05-04

## Phase 1: Setup

- [X] T001 Add path_provider and url_launcher dependencies to pubspec.yaml

## Phase 2: Foundational

- [X] T002 [P] Create lib/core/logging/log_constants.dart with LogLevel and LogCategory enums
- [X] T003 [P] Create lib/core/logging/log_entry.dart with LogEntry data class
- [X] T004 Create lib/core/logging/log_config.dart with LogConfig class

## Phase 3: User Story 1 - Developer Debugging Local Issues (P1)

**Goal**: File-based logging to platform-appropriate directories
**Independent Test**: Trigger app actions, verify log entries appear in log file

**Implementation Tasks**:

- [X] T005 [P] [US1] Create lib/core/logging/logger.dart with Logger singleton class
- [X] T006 [P] [US1] Implement getLogDirectory() using path_provider in logger.dart
- [X] T007 [US1] Implement log() method to write formatted entries to file in logger.dart
- [X] T008 [US1] Initialize logger in lib/main.dart before runApp()
- [X] T009 [US1] Add debug() info() warning() error() helper methods to logger.dart

## Phase 4: User Story 2 - Beta Tester Sends Logs (P1)

**Goal**: Send Logs button in Settings screen
**Independent Test**: Tap button, verify email client opens with log path

**Implementation Tasks**:

- [X] T010 [P] [US2] Add currentLogPath getter to Logger in logger.dart
- [X] T011 [US2] Add sendLogs() method to Logger using url_launcher in logger.dart
- [X] T012 [US2] Add Send Logs button to lib/ui/screens/settings_screen.dart

## Phase 5: User Story 3 - Automatic Log Rotation (P2)

**Goal**: Rotate logs when file exceeds 5MB
**Independent Test**: Generate 5MB+ logs, verify rotation occurs

**Implementation Tasks**:

- [X] T013 [P] [US3] Create lib/core/logging/log_rotator.dart with rotation logic
- [X] T014 [US3] Check file size before each write in logger.dart, call rotator if needed
- [X] T015 [US3] Implement archive naming with timestamp in log_rotator.dart
- [X] T016 [US3] Implement retention cleanup (7 days / 5 archives) in log_rotator.dart

## Phase 6: User Story 4 - Cross-Platform Log Location (P2)

**Goal**: Logs in platform-appropriate directories
**Independent Test**: Run on Linux/Windows/macOS, verify logs in correct location

**Implementation Tasks**:

- [X] T017 [US4] Verify path_provider returns correct directory per platform
- [X] T018 [US4] Test log file created at ~/.config/morse_trainer/ on Linux

## Phase 7: Integration & Polish

- [X] T019 Add logging to audio service methods in lib/core/audio/
- [X] T020 Add logging to settings changes in lib/ui/bloc/settings_bloc.dart
- [X] T021 Add navigation logging in main.dart Navigator observer
- [X] T022 Replace print() statements throughout app with Logger calls

## Dependencies

```
T001 (Setup)
  │
  ├─► T002-T004 (Foundational)
  │     │
  │     ├─► T005-T009 (US1 - File Logging)
  │     │     │
  │     │     └─► T010-T012 (US2 - Send Logs Button)
  │     │
  │     ├─► T013-T016 (US3 - Log Rotation)
  │     │
  │     └─► T017-T018 (US4 - Cross-Platform)
  │
  └─► T019-T022 (Integration & Polish)
```

## Parallel Execution Opportunities

| Tasks | Reason |
|-------|--------|
| T002, T003, T004 | Independent enum/class creation |
| T005, T006, T007 | Logger implementation (sequential) |
| T010, T011 | Send Logs feature (sequential) |
| T013, T014, T015 | Rotation logic (sequential) |
| T019, T020, T021, T022 | Integration tasks (independent) |

## MVP Scope

**User Story 1 only**: File-based logging with basic logger
- Tasks: T001-T009
- Deliverable: Logs written to file, accessible for debugging

## Implementation Strategy

1. **MVP First**: Implement User Story 1 (file logging) - core value
2. **Increment 1**: Add User Story 2 (Send Logs button) - beta tester value
3. **Increment 2**: Add User Story 3 (rotation) - operational stability
4. **Increment 3**: Add User Story 4 (cross-platform) - full platform support
5. **Polish**: Integration and replace print() statements

Total: 22 tasks