# Implementation Plan: Common Words Practice

**Branch**: `007-common-words-practice-v2` | **Date**: 2026-05-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-common-words-practice/spec.md`

**Summary**: Enhance the existing Word Practice screen to support Morse audio playback, keyer input with forgiving timing, feedback/replay, and familiarity tracking. Gate the mode behind Level 2.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.19+  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `audioplayers`  
**Storage**: `WordFamiliarity` table in existing SQLite DB  
**Testing**: `flutter_test`, `bloc_test`, `mocktail`  
**Target Platform**: Linux desktop, Android mobile  
**Project Type**: cross-platform mobile/desktop app  
**Performance Goals**: Audio latency < 50ms; navigation transition < 100ms  
**Constraints**: Must reuse existing `AudioPlaybackService`, `KeyboardKeyerHandler`, `PracticeSessionBloc` infrastructure  
**Scale/Scope**: Single-user offline app; ~100 common words

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Cross-Platform | PASS | Flutter handles both Linux and Android |
| II. Multi-Input | PASS | Keyboard keyer reused; touchscreen/gamepad already supported |
| III. Koch Method | PASS | Words build on character mastery |
| IV. Interactive Keying Loop | PASS | Keyer with forgiving thresholds |
| V. Spaced Repetition | PASS | Word Familiarity Score feeds into SRS |
| VI. Progressive Difficulty | PASS | Level 2 gate; adaptive scaffolding |
| VII. Gamification | PASS | Familiarity scores feed into existing stats |

**No violations. No complexity tracking needed.**

## Project Structure

### Documentation (this feature)

```text
specs/007-common-words-practice/
├── plan.md              # This file
├── data-model.md        # WordFamiliarity entity
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── data/
│   ├── models/
│   │   └── word_familiarity.dart        # NEW: per-word learning state
│   └── repositories/
│       └── word_familiarity_repository.dart  # NEW: CRUD + scoring
├── domain/
│   └── words/
│       └── word_practice_service.dart   # UPDATE: audio playback, scoring, queue
├── ui/
│   ├── bloc/
│   │   └── word_practice_bloc.dart      # NEW: manage word session state
│   └── screens/
│       └── word_practice_screen.dart    # UPDATE: Morse audio + keyer + feedback
```

## Architecture Decisions

### AD-001: Reuse `PracticeSessionBloc` Pattern
Create a `WordPracticeBloc` following the same event/state pattern as `PracticeSessionBloc`:
- Events: `StartWordSession`, `PlayWordAudio`, `SubmitWordPattern`, `NextWord`
- States: `WordPracticeInitial`, `WordPracticeActive` (listening/tapping/feedback), `WordPracticeComplete`

**Rationale**: Consistent with existing BLoC architecture; familiar patterns for maintenance.

### AD-002: Forgiving Keyer via Threshold Override
Add `interLetterThresholdMs` and `interWordThresholdMs` parameters to `KeyboardKeyerHandler`.
- Inter-letter: up to 3 dits (default same as intra-char)
- Inter-word: up to 9 dits (3 dashes)
- Word-level submission: compare accumulated pattern against target word's full Morse pattern

**Rationale**: Existing keyer already handles dot/dash classification and auto-submit timers. Just need to relax thresholds for word boundaries.

### AD-003: Familiarity Scoring
`WordFamiliarityRepository` tracks per-word scores (0-100%):
- Correct: +10%, capped at 100%
- Incorrect: -20%, floored at 0%
- New words start at 0%

**Rationale**: Simple linear scoring is predictable for learners and easy to test.

## Files to Modify

| File | Change |
|------|--------|
| `lib/ui/screens/word_practice_screen.dart` | Full rewrite: audio playback, keyer input, feedback, scaffolding |
| `lib/domain/koch/word_practice_service.dart` | Add word audio playback, familiarity-based queue, scoring |
| `lib/core/input/keyboard_input_handler.dart` | Add configurable inter-letter and inter-word thresholds |
| `lib/data/models/word_familiarity.dart` | **NEW** entity |
| `lib/data/repositories/word_familiarity_repository.dart` | **NEW** repository |
| `lib/ui/bloc/word_practice_bloc.dart` | **NEW** BLoC for word session |
| `lib/main.dart` | Register `WordPracticeBloc`, gate route behind Level 2 |
| `test/...` | BLoC tests, screen widget tests, keyer threshold tests |

## Success Criteria Mapping

| SC | How Verified |
|----|-------------|
| SC-001 | Integration test: complete 20-word session, verify < 5 min timing |
| SC-002 | Audio waveform test: verify inter-letter gaps = 3 dits |
| SC-003 | Unit test: submit pattern with varying pauses, verify acceptance |
| SC-004 | Unit test: familiarity score changes after correct/incorrect |
| SC-005 | Widget test: verify no text shown before audio for high familiarity |

## Risk & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Keyer threshold changes break character practice | Medium | High | Keep character defaults; only override for word mode |
| Audio latency makes word playback choppy | Low | Medium | Pre-generate tones; use `audioplayers` buffered playback |
| Word queue becomes repetitive | Medium | Medium | Shuffle + weighted by low familiarity |

## Next Steps

1. Run `/speckit.tasks` to generate task list
2. Implement `WordFamiliarity` model and repository
3. Update `KeyboardKeyerHandler` with configurable thresholds
4. Implement `WordPracticeBloc` and rewrite `WordPracticeScreen`
5. Write tests
