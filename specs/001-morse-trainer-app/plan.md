# Implementation Plan: Morse Trainer App

**Branch**: `001-morse-trainer-app` | **Date**: 2026-04-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-morse-trainer-app/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Cross-platform morse code training application implementing the Koch method for progressive learning. Users start with K and M characters, achieve 90% accuracy to unlock subsequent letters. Supports multiple input methods (keyboard, touchscreen, game controller), adjustable tone/speed, spaced repetition for memory reinforcement, and gamification elements. Audio input (microphone/line-in) deferred to post-MVP. Target platforms: Linux desktop and Android mobile.

## Technical Context

**Language/Version**: Flutter 3.x / Dart 3.x  
**Primary Dependencies**: 
- `audioplayers` - Audio playback for morse code tones
- `game_controller` - Game controller input handling
- `sqflite` - Local SQLite storage for progress and settings
- `flutter_bloc` - State management
**Storage**: Local SQLite database (sqflite) for user progress and settings (offline-first design)  
**Testing**: flutter_test, mocktail for unit tests  
**Target Platform**: Linux desktop, Android mobile  
**Project Type**: Cross-platform mobile + desktop application  
**Performance Goals**: Audio latency <50ms, input recognition accuracy >95%  
**Constraints**: Offline-capable  
**Scale/Scope**: Single-user app, ~50 UI screens/flows estimated from feature set

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Cross-Platform Target | ✅ PASS | Flutter targets Linux and Android |
| II. Multi-Input Support | ✅ PASS | Flutter packages available: keyboard (native), touchscreen (gestures), controller (game_controller package). Audio input deferred to post-MVP. |
| III. Koch Method Learning | ✅ PASS | Core learning logic follows Koch method |
| IV. Interactive Keying Loop | ✅ PASS | Audio playback → input capture → verify → feedback flow |
| V. Spaced Repetition | ✅ PASS | SM-2 algorithm variant with 2/7/30/90 day intervals |
| VI. Progressive Difficulty | ✅ PASS | Level system from 2 chars → full alphabet → words → phrases |
| VII. Gamification | ✅ PASS | Points, streaks, and progress tracking |

**Research Complete**: All unknowns resolved via Flutter ecosystem analysis.

## Project Structure

### Documentation (this feature)

```
specs/001-morse-trainer-app/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── audio/           # Morse code tone generation and playback
│   ├── input/           # Input handlers (keyboard, touchscreen, controller). Audio deferred to post-MVP.
│   └── timing/          # WPM timing calculations, dot/dash detection
├── data/
│   ├── models/          # Entity data models
│   ├── repositories/    # Data access layer
│   └── database/        # SQLite schema and migrations
├── domain/
│   ├── koch/            # Koch method progression logic
│   ├── spaced_repetition/ # Review scheduling algorithm
│   └── gamification/    # Points, streaks, achievements
└── ui/
    ├── screens/         # App screens (practice, settings, progress)
    ├── widgets/         # Reusable UI components
    └── themes/          # Theme configuration

test/
├── unit/
├── integration/
└── contract/
```

**Structure Decision**: Using Flutter with Clean Architecture (core/data/domain/ui layers). Flutter provides excellent cross-platform support for both Android and Linux, with mature audio and input handling packages.

---

## Phase 0: Research - RESOLVED

Research completed with the following decisions:

1. **Flutter audio capabilities**: Using `audioplayers` for playback (proven <50ms latency). For tone generation, will use low-level platform channels with native audio APIs (Oboe on Android, PulseAudio on Linux).

2. **Audio input decoding**: ~~Will implement via platform channels - Kotlin/Swift code for Android/iOS, C++ for Linux. Use Goertzel algorithm for tone detection, simple threshold for straight key.~~ *Deferred to post-MVP (FR-002-A). DSP research required.*

3. **Game controller input**: Using `game_controller` package or SDL2 via FFI for broader controller support.

4. **SQLite in Flutter**: Using `sqflite` with `drift` ORM for type-safe queries and migrations.

---

## Phase 1: Design Artifacts

*To be generated after Phase 0 research completes*

- **data-model.md**: Entity definitions (Character, UserProgress, Session, Settings)
- **contracts/**: UI contract specifications, audio API contracts
- **quickstart.md**: Development setup guide

---

**Status**: Phase 0 complete. Ready for task generation via `/speckit-tasks`