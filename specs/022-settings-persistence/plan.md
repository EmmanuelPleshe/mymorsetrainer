# Implementation Plan: Settings Persistence

**Branch**: `022-settings-persistence` | **Date**: 2026-05-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/022-settings-persistence/spec.md`

## Summary

Settings persistence infrastructure already exists (sqflite-backed `SettingsRepository`, `SettingsBloc`, `AppSettings` model). Gap: audio playback does not react to setting changes. Plan wires `AudioPlaybackService` into `SettingsBloc` so WPM, effWPM, tone, and volume apply immediately and persist across sessions.

## Technical Context

**Language/Version**: Dart 3.5+ / Flutter 3.24+ (from pubspec `sdk: ^3.5.0`)  
**Primary Dependencies**: `flutter_bloc` (state management), `sqflite` + `sqflite_common_ffi` (local persistence), `audioplayers` (audio playback)  
**Storage**: SQLite via `DatabaseHelper` (existing)  
**Testing**: `flutter_test` (existing), plus `sqflite_common_ffi` for integration-style repository tests  
**Target Platform**: Linux desktop + Android (per constitution)  
**Project Type**: mobile-app / desktop-app (Flutter cross-platform)  
**Performance Goals**: Settings load < 2s on cold start; setting change applied within 1s  
**Constraints**: Audio pre-generates WAV files to `/tmp/` — tone/volume changes require WAV regeneration. Must avoid segfault on window close (existing `dispose()` logic).  
**Scale/Scope**: Single-user local app; no cloud sync.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Notes |
|-----------|-------|-------|
| I. Cross-Platform | Pass | Flutter + sqflite_ffi already builds Linux + Android |
| II. Multi-Input | Pass | No change to input handling |
| III. Koch Method | Pass | No change to learning flow |
| IV. Interactive Keying Loop | Pass | No change to core loop |
| V. Spaced Repetition | Pass | No change to scheduling |
| VI. Progressive Difficulty | Pass | No change to level progression |
| VII. Gamification | Pass | No change to points/streaks |

No violations.

## Project Structure

### Documentation (this feature)

```text
specs/022-settings-persistence/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── data/
│   ├── database/
│   │   └── database_helper.dart      # existing — version bump if schema changes
│   ├── models/
│   │   └── settings.dart             # existing — default value alignment
│   └── repositories/
│       └── settings_repository.dart  # existing — add validation helpers
├── core/
│   └── audio/
│       └── morse_code_service.dart   # existing — AudioPlaybackService already has setters
├── ui/
│   ├── bloc/
│   │   └── settings_bloc.dart        # existing — inject AudioPlaybackService, emit on change
│   └── screens/
│       └── settings_screen.dart      # existing — sliders already wired to BLoC events
test/
├── unit/
│   └── settings_bloc_test.dart       # new — BLoC state transitions + audio sync
├── unit/
│   └── settings_repository_test.dart # new — persistence round-trip + defaults
└── integration/
    └── settings_startup_test.dart    # new — cold-start load + audio initialization
```

## Complexity Tracking

No constitution violations. No complexity to justify.

## Research & Decisions

### Phase 0: Outline & Research

**Unknowns resolved:**

| Unknown | Decision | Rationale |
|---------|----------|-----------|
| How does audio service consume settings? | Inject `AudioPlaybackService` into `SettingsBloc`; call setters on every successful settings update | BLoC already handles all setting changes; audio service is singleton with existing setters |
| Where to clamp invalid values? | Clamp in `AudioPlaybackService` setters (already done) + validate in `SettingsBloc` before DB write | Audio service clamps defensively; BLoC validates to prevent bad data in DB |
| Default values mismatch? | Align `AppSettings` constructor, `fromMap`, and DB schema defaults to: WPM 20, effWPM 20, tone 600 Hz, volume 1.0 | Spec says WPM 20, effWPM 20, tone 600, volume 50%. Current code: constructor WPM 15/effWPM 10, DB WPM 20/effWPM 10, `fromMap` WPM 20/effWPM 20. Align all to spec defaults. |
| When to regenerate audio WAVs? | Regenerate inside `AudioPlaybackService` setters for tone/volume; WPM/effWPM are timing-only, no WAV regeneration needed | Tone/volume change the sine wave amplitude/frequency; WPM/effWPM only change delays between playing pre-generated files |
| How to test persistence without real DB? | Use `sqflite_common_ffi` with in-memory DB for unit tests; set `DatabaseHelper.setTestDbPath(':memory:')` | Project already uses sqflite_ffi for desktop; in-memory DB is fast and isolated |

**Alternatives considered:**

- **Alternative**: Use `SharedPreferences` instead of sqflite for settings. Rejected: Project already has sqflite schema and repository pattern; adding another storage layer adds complexity without benefit.
- **Alternative**: Stream settings changes via `StreamController` instead of direct injection. Rejected: BLoC already provides reactive state; over-engineering for a single consumer (audio service).

## Design

### Phase 1: Data Model

Entity: `AppSettings` (already exists)

| Field | Type | Constraints | Default |
|-------|------|-------------|---------|
| id | String | PK, always `'current'` | `'current'` |
| toneFrequency | double | 300–2000 Hz | 600.0 |
| wpm | double | 5–40 WPM | 20.0 |
| effWpm | double | 5–40 WPM | 20.0 |
| extraWordSpace | double | 0–5 s | 0.0 |
| volume | double | 0.0–1.0 | 1.0 |
| inputMethod | int (enum index) | 0–3 | 0 (keyboard) |
| enableGamification | int (bool) | 0 or 1 | 1 |
| enableSoundEffects | int (bool) | 0 or 1 | 0 |
| enableScreenFlash | int (bool) | 0 or 1 | 0 |

**Validation rules** (FR-008):
- WPM: clamp 5.0–40.0
- effWPM: clamp 5.0–40.0
- toneFrequency: clamp 300.0–2000.0
- volume: clamp 0.0–1.0
- extraWordSpace: clamp 0.0–5.0

**State transitions**:
```
SettingsInitial → SettingsLoading (on LoadSettings)
SettingsLoading → SettingsLoaded (on success)
SettingsLoading → SettingsError (on failure)
SettingsLoaded → SettingsLoading → SettingsLoaded (on any update event)
```

### Contracts

No external interfaces. Internal contract: `SettingsBloc` must call `AudioPlaybackService` setters after successful DB write.

### Quickstart

1. Ensure `flutter pub get` has run (dependencies already declared).
2. Run tests: `flutter test`
3. Launch app: `flutter run`
4. Change WPM/tone/volume in Settings screen → hear change on next playback.
5. Close app → reopen → settings restored.

## Implementation Tasks Preview

- T1: Align default values across `AppSettings`, `fromMap`, DB schema, and `AudioPlaybackService`
- T2: Inject `AudioPlaybackService` into `SettingsBloc`; call setters on every successful update
- T3: Add validation in `SettingsBloc` event handlers before DB write
- T4: Ensure startup `LoadSettings` propagates loaded values to `AudioPlaybackService`
- T5: Add unit tests for `SettingsBloc` state transitions and audio sync
- T6: Add unit tests for `SettingsRepository` persistence round-trip
- T7: Add integration test for cold-start settings load
- T8: Run `flutter run` and verify immediate application + persistence
