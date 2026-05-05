# Implementation Plan: Debug Logging System

**Branch**: `006-debug-logging-system` | **Date**: 2026-05-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/006-debug-logging-system/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Implement cross-platform debug logging system for Flutter desktop app that writes logs to user-accessible files, captures UI interactions/audio state/settings changes/errors, includes automatic log rotation (5MB max), and provides Send Logs button in Settings for beta testers to email log files.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.24.0  
**Primary Dependencies**: path_provider (cross-platform paths), url_launcher (open email client)  
**Storage**: File-based logs in platform-specific directories  
**Testing**: flutter test  
**Target Platform**: Linux, Windows, macOS, Android (desktop)  
**Project Type**: Flutter desktop-app  
**Performance Goals**: Logs written within 100ms of event  
**Constraints**: Max 5MB per log file, retain 7 days or 5 rotation cycles  
**Scale/Scope**: Single logging service, integrated into ~5 screens

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Cross-platform target | PASS | Logging works on all target platforms via path_provider |
| Multi-input support | N/A | Logging feature, not input-related |
| Koch method learning | N/A | Logging feature, not learning-related |
| Interactive keying loop | N/A | Logging feature, not keying-related |
| Spaced repetition | N/A | Logging feature, not SR-related |
| Progressive difficulty | N/A | Logging feature, not difficulty-related |
| Gamification | N/A | Logging feature, not gamification-related |

**Result**: PASS - No constitution violations. Logging is a developer tool that supports all core principles.

## Project Structure

### Documentation (this feature)

```text
specs/006-debug-logging-system/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (not applicable - internal feature)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── logging/         # NEW - Logger service
│       ├── logger.dart           # Main logger class
│       ├── log_entry.dart        # LogEntry model
│       ├── log_rotator.dart      # Rotation logic
│       └── log_constants.dart    # Categories, levels, config
├── data/
│   └── repositories/   # May add log repository for persistence
├── domain/
├── ui/
│   ├── screens/
│   │   └── settings_screen.dart  # ADD Send Logs button
│   └── bloc/
│       └── settings_bloc.dart    # ADD logging of settings changes
└── main.dart           # ADD logger initialization
```

**Structure Decision**: Add logging under lib/core/logging/ following existing project architecture. Logger is a core service accessed throughout the app.

## Complexity Tracking

No complexity violations - single feature with clear scope.

## Phase 0: Research

**Research needed**:
1. Best practices for file-based logging in Flutter desktop apps
2. Cross-platform path handling (path_provider behavior on each platform)
3. Email attachment via url_launcher or share_plus

**No NEEDS CLARIFICATION markers** - technical details can be determined through research.

## Phase 1: Design

**Entities from spec**:
- LogEntry: timestamp, level, category, message
- LogFile: active log file with platform path
- LogRotator: handles rotation at 5MB threshold

**No external contracts** - this is an internal debugging feature.

**Quickstart**: Basic logger initialization in main.dart, integrate logging calls in key services.

## Next Steps

- Phase 0: Research logging best practices for Flutter
- Phase 1: Create data-model.md, implement logger service
- /speckit.tasks: Generate implementation tasks