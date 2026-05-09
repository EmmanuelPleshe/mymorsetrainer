# Tasks: Settings Persistence

**Input**: Design documents from `specs/022-settings-persistence/`
**Prerequisites**: plan.md, spec.md, data-model.md, research.md, quickstart.md

**Tests**: TDD approach — tests written first, confirmed failing before implementation.

---

## Phase 1: Setup

**Purpose**: Ensure project is ready for development and testing.

- [ ] T001 Verify `flutter pub get` has run and all dependencies resolve
- [ ] T002 [P] Verify `flutter test` runs successfully with zero existing failures
- [ ] T003 [P] Verify `flutter run` launches the app on Linux desktop

---

## Phase 2: Foundational — Align Default Values

**Purpose**: Eliminate default value drift so persistence is trustworthy from first install.

**⚠️ CRITICAL**: All user stories depend on consistent defaults.

### Tests for Foundational (write first, confirm fail)

- [ ] T004 [P] Write failing test: AppSettings constructor defaults match spec (WPM 20, effWPM 20, tone 600, volume 0.5) in `test/unit/settings_model_test.dart`
- [ ] T005 [P] Write failing test: AppSettings.fromMap defaults match spec in `test/unit/settings_model_test.dart`

### Implementation for Foundational

- [ ] T006 Align `AppSettings` constructor defaults to spec in `lib/data/models/settings.dart`
- [ ] T007 Align `AppSettings.fromMap` defaults to spec in `lib/data/models/settings.dart`
- [ ] T008 Align DB `settings` table defaults in `_createDB` to spec in `lib/data/database/database_helper.dart`

**Checkpoint**: `flutter test` passes for model default tests. Constructor, fromMap, and DB schema defaults are identical.

---

## Phase 3: User Story 1 — Persist WPM and Effective WPM (Priority: P1) 🎯 MVP

**Goal**: WPM and effective WPM survive app restart.

**Independent Test**: Change WPM to 25 and effWPM to 18 in Settings. Close app. Reopen. Verify values restored. Start playback — confirm restored speed.

### Tests for User Story 1 (write first, confirm fail) ⚠️

- [ ] T009 [P] [US1] Write failing test: `SettingsRepository` round-trips WPM/effWPM via in-memory DB in `test/unit/settings_repository_test.dart`
- [ ] T010 [P] [US1] Write failing test: `SettingsBloc` calls `AudioPlaybackService.setWpm` on `LoadSettings` with persisted WPM in `test/unit/settings_bloc_test.dart`
- [ ] T011 [P] [US1] Write failing test: `SettingsBloc` calls `AudioPlaybackService.setEffWpm` on `LoadSettings` with persisted effWPM in `test/unit/settings_bloc_test.dart`

### Implementation for User Story 1

- [ ] T012 [US1] Add `AudioPlaybackService` parameter to `SettingsBloc` constructor in `lib/ui/bloc/settings_bloc.dart`
- [ ] T013 [US1] In `_onLoadSettings`, after emitting `SettingsLoaded`, call `AudioPlaybackService.setWpm` and `setEffWpm` with loaded values in `lib/ui/bloc/settings_bloc.dart`
- [ ] T014 [US1] In `_onUpdateWpm`, after successful DB write, call `AudioPlaybackService.setWpm` in `lib/ui/bloc/settings_bloc.dart`
- [ ] T015 [US1] In `_onUpdateEffWpm`, after successful DB write, call `AudioPlaybackService.setEffWpm` in `lib/ui/bloc/settings_bloc.dart`
- [ ] T016 [US1] Add WPM validation (clamp 5.0–40.0) in `_onUpdateWpm` before DB write in `lib/ui/bloc/settings_bloc.dart`
- [ ] T017 [US1] Add effWPM validation (clamp 5.0–40.0) in `_onUpdateEffWpm` before DB write in `lib/ui/bloc/settings_bloc.dart`
- [ ] T018 [P] [US1] Update `main.dart` to pass `AudioPlaybackService()` into `SettingsBloc` constructor in `lib/main.dart`

**Checkpoint**: `flutter test` passes all US1 tests. `flutter run` → change WPM → close → reopen → WPM restored.

---

## Phase 4: User Story 3 — Apply Settings Immediately (Priority: P1)

**Goal**: Any setting change affects the next symbol played without restart.

**Independent Test**: Start playback. Change WPM mid-playback. Next symbol plays at new speed.

### Tests for User Story 3 (write first, confirm fail) ⚠️

- [ ] T019 [P] [US3] Write failing test: `SettingsBloc` calls `AudioPlaybackService.setWpm` on `UpdateWpm` event in `test/unit/settings_bloc_test.dart`
- [ ] T020 [P] [US3] Write failing test: `SettingsBloc` calls `AudioPlaybackService.setToneFrequency` on `UpdateToneFrequency` event in `test/unit/settings_bloc_test.dart`
- [ ] T021 [P] [US3] Write failing test: `SettingsBloc` calls `AudioPlaybackService.setVolume` on `UpdateVolume` event in `test/unit/settings_bloc_test.dart`

### Implementation for User Story 3

- [ ] T022 [US3] Ensure `_onUpdateToneFrequency` calls `AudioPlaybackService.setToneFrequency` after DB write in `lib/ui/bloc/settings_bloc.dart`
- [ ] T023 [US3] Ensure `_onUpdateVolume` calls `AudioPlaybackService.setVolume` after DB write in `lib/ui/bloc/settings_bloc.dart`
- [ ] T024 [US3] Ensure `_onUpdateExtraWordSpace` calls `AudioPlaybackService.setExtraWordSpace` after DB write in `lib/ui/bloc/settings_bloc.dart`
- [ ] T025 [US3] Ensure `AudioPlaybackService` setters update internal state immediately (timing params for WPM/effWPM, WAV regeneration for tone/volume) in `lib/core/audio/morse_code_service.dart`

**Checkpoint**: `flutter test` passes all US3 tests. `flutter run` → start playback → change WPM → hear new speed on next symbol.

---

## Phase 5: User Story 2 — Persist Tone and Volume (Priority: P2)

**Goal**: Tone frequency and volume survive app restart.

**Independent Test**: Change tone to 700 Hz and volume to 30%. Close app. Reopen. Verify values restored. Start playback — confirm restored tone and volume.

### Tests for User Story 2 (write first, confirm fail) ⚠️

- [ ] T026 [P] [US2] Write failing test: `SettingsRepository` round-trips tone/volume via in-memory DB in `test/unit/settings_repository_test.dart`
- [ ] T027 [P] [US2] Write failing test: `SettingsBloc` calls `AudioPlaybackService.setToneFrequency` on `LoadSettings` in `test/unit/settings_bloc_test.dart`
- [ ] T028 [P] [US2] Write failing test: `SettingsBloc` calls `AudioPlaybackService.setVolume` on `LoadSettings` in `test/unit/settings_bloc_test.dart`

### Implementation for User Story 2

- [ ] T029 [US2] In `_onLoadSettings`, call `AudioPlaybackService.setToneFrequency` and `setVolume` with loaded values in `lib/ui/bloc/settings_bloc.dart`
- [ ] T030 [US2] Add tone frequency validation (clamp 300.0–2000.0) in `_onUpdateToneFrequency` before DB write in `lib/ui/bloc/settings_bloc.dart`
- [ ] T031 [US2] Add volume validation (clamp 0.0–1.0) in `_onUpdateVolume` before DB write in `lib/ui/bloc/settings_bloc.dart`

**Checkpoint**: `flutter test` passes all US2 tests. `flutter run` → change tone/volume → close → reopen → values restored.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Integration validation and cleanup.

- [ ] T032 [P] Write integration test: cold start loads persisted settings and initializes audio in `test/integration/settings_startup_test.dart`
- [ ] T033 [P] Run `flutter test` — all unit and integration tests pass
- [ ] T034 Run `flutter run` — manual verification per `quickstart.md`
- [ ] T035 [P] Update `CLAUDE.md` if implementation deviated from plan

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies
- **Phase 2 (Foundational)**: Depends on Setup; blocks all user stories
- **Phase 3 (US1)**: Depends on Phase 2
- **Phase 4 (US3)**: Depends on Phase 3 (needs WPM audio sync infrastructure)
- **Phase 5 (US2)**: Depends on Phase 4 (needs immediate application infrastructure)
- **Phase 6 (Polish)**: Depends on all user stories

### Within Each Phase

- Tests written first, run to confirm they fail
- Models/defaults before BLoC wiring
- BLoC wiring before integration
- One phase completes before next starts

### Parallel Opportunities

- All test files marked [P] can be written in parallel
- US1 and US2 repository tests are independent (different fields)
- US3 bloc tests can be written in parallel with US1/US2 repository tests
- Implementation tasks within a phase: validation and audio-sync calls are independent per field

---

## Implementation Strategy

### MVP First (US1 Only)

1. Phase 1: Setup
2. Phase 2: Foundational (align defaults)
3. Phase 3: US1 (WPM/effWPM persistence + audio sync)
4. **STOP and VALIDATE**: Test WPM persistence manually

### Incremental Delivery

1. Setup + Foundational → defaults aligned
2. US1 → WPM/effWPM persist and sync to audio
3. US3 → all settings apply immediately
4. US2 → tone/volume persist and sync to audio
5. Polish → integration tests + manual verification

---

## Notes

- `AudioPlaybackService` is a singleton via factory constructor. Pass it into `SettingsBloc` for testability.
- `DatabaseHelper` supports in-memory testing via `setTestDbPath(':memory:')`.
- All boolean fields in `toMap`/`fromMap` use `1/0` integer encoding. Verify consistency.
- `flutter run` required after each implementation phase per project feedback rules.
