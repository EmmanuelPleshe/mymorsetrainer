---

description: "Task list for Morse Trainer App feature implementation"
---

# Tasks: Morse Trainer App

**Input**: Design documents from `/specs/001-morse-trainer-app/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Flutter project structure per implementation plan (lib/core/, lib/data/, lib/domain/, lib/ui/, test/)
- [x] T002 Initialize Flutter project with pubspec.yaml including dependencies: audioplayers, sqflite, flutter_bloc, path_provider
- [x] T003 [P] Configure flutter_lint and formatting tools in analysis_options.yaml
- [x] T004 [P] Setup CI/CD configuration for Linux and Android builds

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Create database schema with SQLite for Character, UserProgress, Session, Settings entities
- [x] T006 [P] Implement Character repository in lib/data/repositories/character_repository.dart
- [x] T007 [P] Implement UserProgress repository in lib/data/repositories/user_progress_repository.dart
- [x] T008 Implement Settings repository in lib/data/repositories/settings_repository.dart
- [x] T009 Create MorseCode service in lib/core/audio/morse_code_service.dart (maps letters to dots/dashes)
- [x] T010 Create Audio playback service in lib/core/audio/audio_playback_service.dart
- [x] T011 [P] Setup BLoC infrastructure with flutter_bloc in lib/ui/bloc/
- [x] T012 Configure error handling and logging infrastructure

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Learn First Characters with Koch Method (Priority: P1) 🎯 MVP

**Goal**: Users can learn K and M characters using Koch method, achieving 90% accuracy to unlock next character

**Independent Test**: Complete Koch level 1 with 2 characters (K, M) and verify next character (R) is unlocked after 90% accuracy

### Implementation for User Story 1

- [x] T013 [P] [US1] Create Character model in lib/data/models/character.dart with morse pattern, mastery level, next review date
- [x] T014 [P] [US1] Create KochLevel entity in lib/domain/koch/koch_level.dart
- [x] T015 [US1] Implement KochProgressionService in lib/domain/koch/koch_progression_service.dart
- [x] T016 [US1] Create PracticeSessionBloc in lib/ui/bloc/practice_session_bloc.dart
- [x] T017 [US1] Implement PracticeScreen in lib/ui/screens/practice_screen.dart
- [x] T018 [US1] Add character playback and input verification in AudioVerificationService
- [x] T019 [US1] Implement accuracy tracking and 90% threshold logic in practice session
- [x] T020 [US1] Add character unlock notification when threshold reached

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Practice with Multiple Input Methods (Priority: P1)

**Goal**: Users can use keyboard, touchscreen, or game controller to key in morse code. Audio input deferred to post-MVP.

**Independent Test**: Each input method can independently trigger morse code input without affecting other functionality

### Implementation for User Story 2

- [x] T021 [P] [US2] Create KeyboardInputHandler in lib/core/input/keyboard_input_handler.dart
- [x] T022 [P] [US2] Create TouchscreenInputHandler in lib/core/input/touchscreen_input_handler.dart
- [x] T023 [P] [US2] Create GameControllerInputHandler in lib/core/input/game_controller_input_handler.dart
- [ ] ~~T024 [P] [US2] Create AudioInputHandler in lib/core/input/audio_input_handler.dart~~ *Deferred to post-MVP (FR-002-A)*
- [x] T025 [US2] Create unified InputService in lib/core/input/input_service.dart (handlers work independently, no unified service needed)
- [x] T026 [US2] Implement InputMethod selection UI in Settings screen
- [x] T027 [US2] Add input calibration for timing thresholds (dot/dash distinction)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Adjust Tone and Speed (Priority: P2)

**Goal**: Users can adjust audio tone frequency (300-2000Hz, default 600Hz) and speed (5-40 WPM, default 20 WPM)

**Independent Test**: Change tone to 800Hz and speed to 25 WPM, verify audio output matches settings

### Implementation for User Story 3

- [x] T028 [P] [US3] Create Settings model in lib/data/models/settings.dart
- [x] T029 [P] [US3] Implement WPM to millisecond conversion in lib/core/timing/wpm_calculator.dart
- [x] T030 [US3] Create SettingsBloc in lib/ui/bloc/settings_bloc.dart
- [x] T031 [US3] Implement SettingsScreen in lib/ui/screens/settings_screen.dart
- [x] T032 [US3] Add tone frequency adjustment to AudioPlaybackService
- [x] T033 [US3] Add WPM speed adjustment to AudioPlaybackService
- [x] T034 [US3] Add volume control to audio settings

---

## Phase 6: User Story 4 - Spaced Repetition Review (Priority: P2)

**Goal**: Characters with lower mastery appear more frequently; mastered characters review less often (2→7→30→90 day intervals)

**Independent Test**: Verify K appears more frequently than R after multiple sessions with 90%+ accuracy on R

### Implementation for User Story 4

- [x] T035 [P] [US4] Create SpacedRepetitionService in lib/domain/spaced_repetition/spaced_repetition_service.dart
- [x] T036 [P] [US4] Implement SM-2 algorithm variant in lib/domain/spaced_repetition/sm2_algorithm.dart
- [x] T037 [US4] Add review scheduling to Character model and repository
- [x] T038 [US4] Integrate spaced repetition with PracticeSessionBloc
- [x] T039 [US4] Add "review due" indicators in progress UI

---

## Phase 7: User Story 5 - Progress to Words and QSO Phrases (Priority: P3)

**Goal**: After completing alphabet, users can practice common ham radio words and QSO phrases

**Independent Test**: Complete alphabet level, then word practice mode plays "CQ" and user keys it correctly

### Implementation for User Story 5

- [x] T040 [P] [US5] Create WordPracticeService in lib/domain/koch/word_practice_service.dart
- [x] T041 [P] [US5] Create QSOService in lib/domain/koch/qso_service.dart
- [x] T042 [US5] Add Word model in lib/data/models/word.dart
- [x] T043 [US5] Create WordPracticeScreen in lib/ui/screens/word_practice_screen.dart
- [x] T044 [US5] Create QSOLogScreen in lib/ui/screens/qso_practice_screen.dart
- [x] T045 [US5] Add word/phrase library with common ham radio terms

---

## Phase 8: User Story 6 - Gamification and Progress Tracking (Priority: P3)

**Goal**: Users earn points, maintain streaks, and see visual progress indicators

**Independent Test**: Answer 5 correct in a row, verify streak milestone triggers bonus points

### Implementation for User Story 6

- [x] T046 [P] [US6] Create GamificationService in lib/domain/gamification/gamification_service.dart
- [x] T047 [P] [US6] Create PointsCalculator in lib/domain/gamification/points_calculator.dart
- [x] T048 [US6] Add streak tracking to UserProgress model
- [x] T049 [US6] Implement ProgressScreen in lib/ui/screens/progress_screen.dart
- [x] T050 [US6] Add achievement/level progression UI
- [x] T051 [US6] Add streak milestone notifications (5, 10, 25, 50)

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T052 [P] Add comprehensive unit tests in test/unit/
- [x] T053 [P] Add integration tests in test/integration/
- [x] T054 Polish UI themes and visual consistency (added countdown indicator, screen flash)
- [ ] T055 [US3] Measure and optimize audio latency to meet SC-005 (<50ms from key press to sound output)
- [ ] T056 Add onboarding flow for new users
- [ ] T057 Add data export/backup functionality
- [ ] T059 [US2] Add integration tests to verify keyboard/touchscreen/controller input recognition meets SC-006 (95% accuracy)
- [ ] ~~T060 [US2] Add integration tests to verify audio input decoding meets SC-007 (90% accuracy with proper key/interface)~~ *Deferred to post-MVP (FR-002-A)*
- [x] T058 Accessibility - added screen flash for deaf/hard-of-hearing users

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can proceed in parallel after Phase 2
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Independent from US1 but integrates with audio verification
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 4 (P2)**: Depends on US1 and US3 completion - requires character tracking and settings
- **User Story 5 (P3)**: Depends on US1 completion - requires character mastery
- **User Story 6 (P3)**: Can start after Foundational (Phase 2) - No hard dependencies

### Within Each User Story

- Models before services
- Services before UI
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel
- Once Foundational phase completes, US1, US2, US3 can start in parallel
- Models within a story marked [P] can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all models for User Story 1 together:
Task: "Create Character model in lib/data/models/character.dart"
Task: "Create KochLevel entity in lib/domain/koch/koch_level.dart"

# Launch services after models:
Task: "Implement KochProgressionService in lib/domain/koch/koch_progression_service.dart"
Task: "Create AudioPlaybackService in lib/core/audio/audio_playback_service.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence