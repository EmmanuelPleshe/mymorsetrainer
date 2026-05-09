# Research: Settings Persistence

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Storage layer | Keep existing sqflite | Already has schema, repository, migration path. SharedPreferences adds unnecessary second storage layer. |
| Audio sync mechanism | Inject `AudioPlaybackService` into `SettingsBloc` | BLoC handles all setting changes. Audio service is singleton with setters. Direct call is simplest and avoids streams/over-engineering. |
| Value clamping | `AudioPlaybackService` setters (existing) + `SettingsBloc` validation (new) | Audio service defensively clamps. BLoC validates before DB write so bad data never reaches storage. |
| Default values | Align all sources to spec: WPM 20, effWPM 20, tone 600 Hz, volume 1.0 | Current mismatches: `AppSettings` constructor (WPM 15, effWPM 10), DB schema (WPM 20, effWPM 10), `fromMap` (WPM 20, effWPM 20). Spec says WPM 20, effWPM 20, tone 600, volume 50%. Volume default in DB is already 1.0 (100%). Spec says volume 50% but current DB default is 1.0. Align to spec: volume 0.5. |
| WAV regeneration | Regenerate in `AudioPlaybackService.setToneFrequency()` and `setVolume()` | Tone/volume change sine wave params. WPM/effWPM only change delays, no regeneration needed. |
| Testing approach | `sqflite_common_ffi` with in-memory DB | Project already uses sqflite_ffi for desktop. Fast, isolated, no file cleanup. |

## Alternatives Rejected

- **SharedPreferences**: Would simplify schema but break existing migration path and repository pattern. Not worth it for 10 fields.
- **Stream-based sync**: Audio service could listen to a settings stream. Rejected: only one consumer, BLoC already reactive, adds complexity.
- **Repository emits stream**: `SettingsRepository` could expose a `Stream<AppSettings>`. Rejected: BLoC already provides state stream; repository streams add indirection.

## Gaps Identified

1. `AppSettings` constructor defaults ≠ DB defaults ≠ `fromMap` defaults
2. `SettingsBloc` does not validate values before DB write
3. `AudioPlaybackService` internal state drifts from persisted settings
4. No tests exist for settings persistence or audio sync
