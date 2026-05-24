# Feature Specification: Debug Logging System

**Feature Branch**: `006-debug-logging-system`  
**Created**: 2026-05-04  
**Status**: Draft  
**Input**: User description: "Implement a comprehensive logging system for My Morse Trainer that writes debug logs to a user-accessible file. The logger should capture UI interactions, navigation events, audio system state, settings changes, and errors. Include automatic log rotation, a 'Send Logs' button in the UI, and ensure logs are written cross-platform (Windows, macOS, Linux) to a consistent location like AppData/Local or ~/.config. I need this for local development and for beta testers to send me logs when they hit issues like missing audio in practice mode or settings buttons not responding."

## User Scenarios & Testing

### User Story 1 - Developer Debugging Local Issues (Priority: P1)

As a developer, I want debug logs written to a file so that I can diagnose issues that occur during development and testing.

**Why this priority**: Core functionality for the feature - without file-based logging, the entire system has no value.

**Independent Test**: Create a test build with logging enabled, trigger various app actions, then verify log file exists and contains expected entries.

**Acceptance Scenarios**:

1. **Given** the app is launched, **When** user performs actions, **Then** log entries are written to a file in the platform-appropriate directory
2. **Given** a settings change is made, **When** user modifies WPM or volume, **Then** the change is recorded in the log with timestamp and new value
3. **Given** an error occurs, **When** the app encounters an exception, **Then** the error details including stack trace are written to the log

---

### User Story 2 - Beta Tester Sends Logs (Priority: P1)

As a beta tester, I want to easily send logs to the developer so that they can diagnose issues I encounter.

**Why this priority**: Critical for gathering feedback from testers - the primary use case stated in the requirements.

**Independent Test**: Add the Send Logs button to Settings, tap it, verify email client opens with log file attached.

**Acceptance Scenarios**:

1. **Given** the Send Logs button exists in Settings, **When** user taps it, **Then** the default email app opens with the latest log file attached
2. **Given** no log file exists, **When** user taps Send Logs, **Then** a user-friendly message is shown explaining no logs are available

---

### User Story 3 - Automatic Log Rotation (Priority: P2)

As a user, I want logs to automatically rotate so that disk space is not consumed indefinitely.

**Why this priority**: Prevents storage issues on user devices over long-term usage.

**Independent Test**: Generate enough log entries to exceed rotation threshold, verify old logs are archived or deleted.

**Acceptance Scenarios**:

1. **Given** log file reaches maximum size, **When** new entry is written, **Then** oldest entries are removed or archived to keep file size manageable
2. **Given** rotated log archives exist, **When** user needs to send logs, **Then** the most recent log file is included in the email

---

### User Story 4 - Cross-Platform Log Location (Priority: P2)

As a user on any platform, I want logs in a consistent, accessible location so that I can find them easily.

**Why this priority**: Ensures all users can locate logs regardless of operating system.

**Independent Test**: Run app on Linux, Windows, and macOS, verify logs appear in the expected platform-specific directory.

**Acceptance Scenarios**:

1. **Given** user is on Linux, **When** app writes logs, **Then** logs appear in ~/.config/morse_trainer/
2. **Given** user is on Windows, **When** app writes logs, **Then** logs appear in %LOCALAPPDATA%/morse_trainer/
3. **Given** user is on macOS, **When** app writes logs, **Then** logs appear in ~/Library/Application Support/morse_trainer/

---

### Edge Cases

- What happens when disk is full and logs cannot be written?
- How does system handle when log directory does not have write permissions?
- What happens when email client is not configured on the user's system?
- How are log files named to distinguish between runs/dates?

## Requirements

### Functional Requirements

- **FR-001**: System MUST write debug logs to a file in the user's platform-appropriate config directory
- **FR-002**: System MUST log all UI interactions including button taps, navigation events, and screen transitions
- **FR-003**: System MUST log audio system state changes including playback start/stop, volume adjustments, and audio errors
- **FR-004**: System MUST log all settings changes with timestamp and old/new values
- **FR-005**: System MUST log all unhandled exceptions and errors with stack traces
- **FR-006**: Users MUST be able to access logs through a Send Logs button in the Settings screen
- **FR-007**: System MUST automatically rotate logs when file reaches maximum size (5MB default)
- **FR-008**: System MUST retain at least 7 days of log history or 5 rotation cycles
- **FR-009**: Log entries MUST include timestamp, log level, category, and message in human-readable format

### Key Entities

- **LogEntry**: Represents a single log event with timestamp, level (debug/info/warning/error), category (ui/audio/settings/error), and message
- **LogFile**: The active log file where entries are written, with path determined by platform
- **LogRotator**: Handles automatic rotation when size threshold is reached, manages archive files

## Success Criteria

### Measurable Outcomes

- **SC-001**: Logs are written within 100ms of the event occurring
- **SC-002**: Beta testers can successfully send logs via email attachment with at least 95% success rate on platforms with email client configured
- **SC-003**: Log file size never exceeds 5MB due to automatic rotation
- **SC-004**: All UI interactions, audio events, settings changes, and errors are captured in logs (100% coverage of specified categories)
- **SC-005**: Users on all three platforms (Windows, macOS, Linux) can locate logs in under 30 seconds

## Assumptions

- Users have a default email client configured for the Send Logs functionality to work
- Log rotation size of 5MB is sufficient for typical usage - beta testers generate moderate volume
- Email attachment is the preferred method for beta testers to submit logs (alternative: file sharing link)
- Existing print statements in code will be migrated to use the new logging system