# Task List: Universal Home Navigation

**Feature**: 009-universal-home-nav  
**Branch**: `009-universal-home-nav`  
**Generated**: 2026-05-09  
**Total Tasks**: 16  

---

## Phase 1: Setup

No new dependencies or project structure changes needed. This is a UI-only feature using existing Flutter/Bloc infrastructure.

- [x] T001 Verify project builds cleanly on current branch (`flutter build linux`)

---

## Phase 2: Foundational — Reusable Navigation Widget

**Goal**: Create a `HomeAppBar` widget that all non-home screens can reuse. It shows a home button on the left and optionally nav icons on the right. Hide bottom nav on full-screen practice modes.

**Independent Test**: Widget test can instantiate `HomeAppBar` in isolation and assert icon visibility.

- [x] T002 [P] Create `lib/ui/widgets/home_app_bar.dart` — reusable AppBar with home button + optional nav icons
- [x] T003 Add unit test `test/unit/home_app_bar_test.dart` — assert home button visible, nav icons visible when `showNavIcons=true`
- [x] T004 Add unit test `test/unit/home_app_bar_test.dart` — assert home button calls `onHomePressed` callback

---

## Phase 3: User Story 1 — Home Button on Non-Home Screens (P1)

**Goal**: Every non-home screen shows a "<- Home" button in the upper-left AppBar. Full-screen practice modes hide bottom nav and show Practice/Progress/Settings icons in upper-right.

**Independent Test**: Navigate to each non-home screen; verify home button is visible and tappable.

- [x] T005 [US1] Update `lib/ui/screens/practice_screen.dart` — replace existing AppBar with `HomeAppBar`, hide bottom nav via `Scaffold`
- [x] T006 [US1] Update `lib/ui/screens/progress_screen.dart` — add `HomeAppBar` with home button
- [x] T007 [US1] Update `lib/ui/screens/settings_screen.dart` — add `HomeAppBar` with home button
- [x] T008 [US1] Update `lib/ui/screens/word_practice_screen.dart` — add `HomeAppBar` with home + nav icons, hide bottom nav
- [x] T009 [US1] Update `lib/ui/screens/qso_practice_screen.dart` — add `HomeAppBar` with home + nav icons, hide bottom nav
- [x] T010 [P] [US1] Update `lib/main.dart` — add `/settings` route if missing; verify `MaterialApp` routes

---

## Phase 4: User Story 2 — No Home Button on Home Screen (P1)

**Goal**: Home screen does NOT show a home button. Bottom nav remains visible.

**Independent Test**: Verify home button is absent on home screen widget tree.

- [x] T011 [US2] Verify `lib/ui/screens/home_screen.dart` (or `main.dart` `HomeScreen`) does NOT show `HomeAppBar` home button

---

## Phase 5: User Story 3 — Clean State Reset on Navigation (P2)

**Goal**: Tapping home stops audio, clears keyer state, saves session progress, then navigates.

**Independent Test**: Integration test: start practice, key a partial pattern, tap home. Assert audio stopped, pattern cleared.

- [x] T012 [US3] Add cleanup logic to `HomeAppBar.onHomePressed` — call `AudioPlaybackService().keyerUp()`, `KeyboardKeyerHandler.clearPattern()`, session save
- [x] T013 [US3] Add integration test `test/integration/navigation_flow_test.dart` — audio stops within 200ms of home tap
- [x] T014 [US3] Add integration test `test/integration/navigation_flow_test.dart` — partial keyer pattern cleared on home tap
- [x] T015 [P] [US3] Add Android back button support in `lib/main.dart` — wrap with `PopScope` to intercept back gesture on non-home screens

---

## Phase 6: Polish & Cross-Cutting

- [x] T016 Run full test suite (`flutter test`) and verify all pass

---

## Dependencies

```text
T001 → T002
T002 → T005, T006, T007, T008, T009
T005 → T012
T012 → T013, T014
T015 can run in parallel with T005-T009
```

## Parallel Execution Examples

**Story 1 parallel**: T005, T006, T007, T008, T009, T010 can all run together once T002 is done.

## Implementation Strategy

1. **MVP**: T002 (widget) + T005-T007 (3 core screens) → testable nav flow
2. **Full practice modes**: T008-T009 (word/QSO screens) + T012 (cleanup)
3. **Polish**: T013-T015 (tests + Android back)

## Suggested Next Command

`/speckit.implement --from T001`
