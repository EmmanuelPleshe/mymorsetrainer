# Task List: Common Words Practice — P2 (Smart Repetition + Scaffolding + Expansion)

**Feature**: 007-common-words-practice
**Branch**: `007-common-words-practice-v2`
**Date**: 2026-05-10

---

## Phase 7: Smart Repetition Engine

**Goal**: Track per-word familiarity scores and requeue words.

**Independent Test**: Unit test: correct answer +10%, incorrect -20%, bounded.

- [x] T017 [P] Create `lib/data/models/word_familiarity.dart` — entity with wordText, familiarityScore, totalAttempts, correctCount
- [x] T018 [P] Create `lib/data/repositories/word_familiarity_repository.dart` — CRUD + scoring logic
- [x] T019 Update `lib/data/database/database_helper.dart` — add `word_familiarity` table schema + migration
- [x] T020 Add unit test `test/data/models/word_familiarity_test.dart` — entity defaults, score bounds
- [x] T021 Add unit test `test/data/repositories/word_familiarity_repository_test.dart` — correct/incorrect score changes

---

## Phase 8: Word List Expansion

**Goal**: Expand from 20 to 100 common words.

**Independent Test**: WordPracticeService returns 100+ words.

- [x] T022 Update `lib/domain/koch/word_practice_service.dart` — expand `_commonWords` to 100 entries (numbers, QSO terms, common English)

---

## Phase 9: Adaptive Scaffolding

**Goal**: Show text preview for low-familiarity words.

**Independent Test**: Widget test: verify text shown before audio when familiarity < 20%, hidden when >= 60%.

- [x] T023 Update `lib/domain/koch/word_practice_service.dart` — integrate WordFamiliarityRepository for weighted queue + scaffolding decisions
- [x] T024 Update `lib/ui/screens/word_practice_screen.dart` — listen phase shows word text for 2s when familiarity < 20%
- [x] T025 Update `lib/ui/screens/word_practice_screen.dart` — store familiarity on feedback (correct/incorrect)
- [x] T026 Add widget test `test/ui/screens/word_practice_screen_test.dart` — verify scaffolding behavior

---

## Phase 10: Integration & Polish

- [x] T027 Run full test suite (`flutter test`) and verify all pass

---

## Dependencies

```text
T017 → T018 → T019 → T021
T022 → T023
T019 → T023
T021 → T023
T023 → T024 → T025 → T026
T026 → T027
```

## Implementation Strategy

1. **Data layer**: T017-T021 (model + repository + migration + tests)
2. **Expansion**: T022 (word list)
3. **Scaffolding**: T023-T026 (integrate familiarity into screen)
4. **Polish**: T027 (full test suite)
