# Task List: Common Words Practice

**Feature**: 007-common-words-practice
**Branch**: `007-common-words-practice-v2`
**Generated**: 2026-05-10
**Total Tasks**: 14

---

## Phase 1: Setup

No new dependencies. Reuse existing Flutter/Bloc/sqflite infrastructure.

- [x] T001 Verify project builds cleanly on current branch (`flutter build linux`)

---

## Phase 2: Foundational — Audio & Keyer

**Goal**: Add word-level audio playback and forgiving keyer thresholds.

**Independent Test**: Unit test `playWord` generates correct timing; keyer accepts pauses up to thresholds.

- [x] T002 [P] Update `lib/core/audio/audio_service.dart` — add `playWord(String word)` to interface
- [x] T003 Update `lib/core/audio/morse_code_service.dart` — add `getWordMorsePattern(String word)`
- [x] T004 Update `lib/core/input/keyboard_input_handler.dart` — add `interLetterThresholdMs` and `interWordThresholdMs` parameters
- [x] T005 Update `lib/core/input/keyboard_input_handler.dart` — add `submitNow()` manual submit support
- [x] T006 Add unit test `test/core/input/keyboard_input_handler_test.dart` — verify word-level thresholds accept pauses up to 9 dits

---

## Phase 3: User Story 1 — Unified Word Playback (P1)

**Goal**: WordPracticeScreen plays complete word audio with no letters shown.

**Independent Test**: Widget test: verify "Listen..." indicator visible during playback, no text shown.

- [x] T007 [US1] Update `lib/domain/koch/word_practice_service.dart` — add `getWordsForLevel(int level)` and word queue
- [x] T008 [US1] Update `lib/ui/screens/word_practice_screen.dart` — rewrite: listen phase with audio playback + pulse indicator
- [x] T009 [US1] Update `lib/ui/screens/word_practice_screen.dart` — block input during audio playback
- [x] T010 [P] [US1] Add widget test `test/ui/screens/word_practice_screen_test.dart` — verify listen phase UI

---

## Phase 4: User Story 2 — Forgiving Tap-Back Input (P1)

**Goal**: Learner keys entire word pattern; forgiving timing; raw accumulation indicator.

**Independent Test**: Widget test: key pattern, submit, verify match.

- [x] T011 [US2] Update `lib/ui/screens/word_practice_screen.dart` — keying phase with `KeyboardKeyerHandler`
- [x] T012 [US2] Update `lib/ui/screens/word_practice_screen.dart` — raw pattern display (dots/dashes) + submit button
- [x] T013 [P] [US2] Add widget test `test/ui/screens/word_practice_screen_test.dart` — verify keying and submission

---

## Phase 5: User Story 3 — Feedback & Smart Repetition (P2)

**Goal**: Show correct/incorrect feedback, replay audio, track familiarity.

**Independent Test**: Integration test: submit correct/incorrect, verify feedback and score changes.

- [x] T014 [US3] Update `lib/ui/screens/word_practice_screen.dart` — feedback phase with correct/incorrect display + replay

---

## Phase 6: Polish & Cross-Cutting

- [x] T015 Update `lib/main.dart` — add `/word-practice` route, gate behind Level 2
- [x] T016 Run full test suite (`flutter test`) and verify all pass

---

## Dependencies

```text
T002 → T003 → T007
T004 → T005 → T011
T007 → T008
T008 → T009 → T011
T011 → T012 → T014
T014 → T015
```

## Parallel Execution Examples

**Audio + Keyer parallel**: T002, T003, T004, T005 can run together.

## Implementation Strategy

1. **MVP**: T002-T005 (audio/keyer foundation) → T007-T010 (listen phase) → T011-T013 (keying phase)
2. **Full feature**: T014 (feedback)
3. **Polish**: T015-T016 (routing + tests)

## Suggested Next Command

`/speckit.implement --from T001`
