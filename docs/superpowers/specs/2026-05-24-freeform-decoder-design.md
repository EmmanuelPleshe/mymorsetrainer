# Design: Freeform Decoder with MorseKeyerCore Extraction

**Date**: 2026-05-24  
**Feature Branch**: `008-freeform-decoder`  
**Status**: Approved  

---

## Summary

Implement a Freeform Decoder mode where users tap Morse code freely via keyboard or touchscreen and see it decoded into text in real time. The decoder provides sidetone audio feedback, generous letter/word timing thresholds, and a clean text-only output.

This feature serves as the **forcing function to extract `MorseKeyerCore`** — a shared, timing-aware Morse keying engine that eliminates duplicated logic across all input methods (keyboard, touch, future gamepad/audio).

---

## Goals

1. Extract `MorseKeyerCore` from `KeyboardKeyerHandler` so all input methods share one Morse semantic processor.
2. Refactor `KeyboardKeyerHandler` and `TouchscreenInputHandler` into thin input adapters.
3. Add a `DecoderScreen` that uses the core in "letter-mode" for live text decoding.
4. Add a mode selector on `PracticeScreen` so users choose between "Koch Letters" and "Freeform Decoder".
5. Preserve all existing behavior in `PracticeScreen` (Koch letters, Common Words at L2+) with zero regressions.

---

## Architecture

### Components

| Component | Responsibility | Status |
|-----------|---------------|--------|
| `MorseKeyerCore` | Shared brain: accumulate symbols, classify dot/dash via `MorseTimingEngine`, pattern-to-char lookup, letter/word boundary timers, emit events | **New** |
| `KeyboardKeyerHandler` (refactored) | Detect hardware key events (spacebar), translate to `core.handleKeyDown()` / `core.handleKeyUp(durationMs)` | **Update** |
| `TouchscreenInputHandler` (refactored) | Detect touch events on screen/button, translate to core methods | **Update** |
| `MorseCommandHandler` (updated) | Wrap `KeyboardKeyerHandler`, accumulate `onLetterComplete` into words, fire commands on `onWordBoundary` | **Update** |
| `DecoderScreen` | Full-screen decoder UI: text field, keyer button, sidetone, clear, copy | **New** |
| `PracticeScreen` (updated) | Mode selector: two cards "Koch Letters" / "Freeform Decoder" before session starts | **Update** |

### MorseKeyerCore Event Contract

```dart
typedef SymbolCallback = void Function(String symbol);      // '.' or '-'
typedef LetterCallback = void Function(String char, String pattern);
typedef WordBoundaryCallback = void Function();
typedef UnknownPatternCallback = void Function(String pattern);
```

Events are emitted in this order for a complete letter:
1. `onSymbol('.')` — on each key-up
2. `onLetterComplete('A', '.-')` — after inter-letter threshold or manual submit
3. `onWordBoundary()` — after inter-word threshold following a completed letter

### Phases

```
KeyboardKeyerHandler ──▶ MorseKeyerCore ──▶ onLetterComplete → MorseCommandHandler → command
TouchscreenInputHandler ──▶ MorseKeyerCore ──▶ onLetterComplete → DecoderScreen → text field
```

---

## Design Decisions

### Why `MorseKeyerCore` instead of mode flags in `KeyboardKeyerHandler`

The existing `KeyboardKeyerHandler` is tightly coupled to word-level auto-submission (used by `MorseCommandHandler` for command parsing). The decoder needs letter-level auto-submission. Extracting a shared core avoids branching logic inside a single class and directly resolves issue #15, making every future input method (gamepad, audio keying, etc.) a thin adapter.

### Why `DecoderScreen` is a standalone screen, not a BLoC

The decoder is pure state machine with no persistence, no gamification, and no session history. A `StatefulWidget` with a `MorseKeyerCore` instance is sufficient. Adding a BLoC would be over-engineering. If complexity grows later (save sessions, export decoded text), we can introduce one then.

### Why only finalized letters in the text field

Per user preference: the text field shows only completed characters. No live pattern preview. This keeps the UI clean and avoids visual noise while the user is mid-key. Screen flash and sidetone provide real-time physical feedback instead.

### Why the decoder uses the same `AudioPlaybackService.keyerDown/Up` as practice mode

The practice screen already uses these hooks for real-time keyer audio. Reusing them gives the decoder the same feel: the user hears their own keyed tone at the configured frequency and volume. Settings changes (tone, volume) propagate automatically via the existing `SettingsBloc` → `AudioPlaybackService` pipeline.

---

## Data Flow

### Tapping a single letter ("S" = `...`)

1. User taps keyer button → `TouchscreenInputHandler.onTouchDown()`
2. Handler calls `AudioPlaybackService.keyerDown()` for sidetone + screen flash
3. User releases after short duration → handler calls `core.handleKeyUp(80ms)`
4. Core classifies 80ms < threshold → symbol = `.`, emits `onSymbol('.')`, appends to `_pattern`
5. Core starts inter-letter timer (3 dits)
6. Steps 1–5 repeat two more times for the remaining dots
7. After third dot, user pauses > inter-letter threshold
8. Core finalizes: `_pattern = "..."`, looks up `'S'`, emits `onLetterComplete('S', '...')`
9. Core starts inter-word timer (7 dits)
10. `DecoderScreen` receives event, appends `'S'` to text field
11. If user pauses > inter-word threshold → core emits `onWordBoundary()`
12. `DecoderScreen` inserts space after `'S'`

### Tapping an unknown pattern

1. User keys pattern `.-.-.`
2. Inter-letter threshold expires
3. Core emits `onUnknownPattern('.-.-.')`
4. `DecoderScreen` receives event, appends `'?'` to text field, continues accepting input

---

## UI Design

### PracticeScreen — Mode Selector

Before starting a session, the practice screen shows two cards stacked vertically:

- **Card 1: Koch Letters** — icon `Icons.school`, current level picker below it, "Start Practice" button
- **Card 2: Freeform Decoder** — icon `Icons.keyboard`, subtitle "Tap Morse freely", button navigates to `DecoderScreen`

The existing "Common Words" button (unlocks at L2+) remains below the cards.

### DecoderScreen

**Top half:**
- Scrollable `TextField` (read-only, multi-line) showing decoded text
- Controls row: `IconButton(Icons.delete)` for Clear, `IconButton(Icons.copy)` for Copy

**Bottom half:**
- Large `GestureDetector` filling remaining space, colored like the practice circle (blue when idle, white flash on key-down)
- Label: "Tap and hold to key" when idle
- During key-down: label shows "..." or nothing, screen flashes white, sidetone active

**No bottom navigation** — full-screen immersive experience. Back button returns to PracticeScreen.

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Unknown Morse pattern | Append `?` to text field, continue |
| App backgrounded mid-key | On resume, check elapsed time since last key-up; if inter-letter threshold exceeded, finalize letter; if inter-word exceeded, insert space |
| Screen rotated | `DecoderScreen` state preserved via `AutomaticKeepAliveClientMixin` or `PageStorageKey` on text controller |
| Text field overflows | `TextField` scrolls vertically; decoder continues appending |
| Audio service not initialized | Sidetone is best-effort; visual flash always works |
| Core disposed mid-tap | Timers cancelled, pattern cleared, no crash |

---

## Testing

### `MorseKeyerCore` unit tests (new file: `test/unit/morse_keyer_core_test.dart`)

- `test('classifies dot when duration < threshold')`
- `test('classifies dash when duration >= threshold')`
- `test('emits letter complete after inter-letter timeout')`
- `test('emits word boundary after inter-word timeout')`
- `test('manual submitNow emits immediately')`
- `test('unknown pattern emits onUnknownPattern')`
- `test('clear resets pattern and cancels timers')`
- `test('app backgrounding then resuming finalizes if threshold exceeded')`

### `KeyboardKeyerHandler` unit tests (update existing)

- Verify all existing tests still pass after refactoring
- Verify `onKeyDown` / `onKeyUp` callbacks still fire

### `TouchscreenInputHandler` unit tests (new file: `test/unit/touchscreen_input_handler_test.dart`)

- `test('reports down/up durations to core')`

### `DecoderScreen` widget tests (new file: `test/widget/decoder_screen_test.dart`)

- `testWidgets('tapping dot-dash pattern shows letter')`
- `testWidgets('long gap between letters inserts space')`
- `testWidgets('unknown pattern shows question mark')`
- `testWidgets('clear button empties text field')`
- `testWidgets('copy button copies text to clipboard')`

---

## Integration with Existing Code

### Files to modify

| File | Change |
|------|--------|
| `lib/core/input/keyboard_input_handler.dart` | Extract `MorseKeyerCore`, keep thin adapter |
| `lib/core/input/touchscreen_input_handler.dart` | Replace hardcoded logic with thin adapter to core |
| `lib/core/input/morse_command_handler.dart` | Update to consume core events instead of wrapping handler internals |
| `lib/ui/screens/practice_screen.dart` | Add mode selector UI, push `DecoderScreen` |
| `lib/ui/screens/decoder_screen.dart` | **New** — decoder UI and state management |
| `lib/main.dart` | Add `/decoder` route |
| `lib/ui/screens/help_screen.dart` | Add decoder help section |

### Files to create

| File | Purpose |
|------|---------|
| `lib/core/input/morse_keyer_core.dart` | Shared keying engine |
| `test/unit/morse_keyer_core_test.dart` | Core unit tests |
| `test/unit/touchscreen_input_handler_test.dart` | Touch handler unit tests |
| `test/widget/decoder_screen_test.dart` | Decoder widget tests |

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Refactoring breaks existing practice mode | Run full widget test suite before and after; compare behavior on both keyboard and touch input |
| `MorseCommandHandler` behavior changes | Write explicit tests for word-level command detection before refactoring |
| Timing thresholds feel wrong in decoder | Decoder uses same `MorseTimingEngine` as practice; generous by design (inter-letter = 3 dits) |
| Screen flash conflicts with practice screen flash | Use a local `ValueNotifier<bool>` in `DecoderScreen` instead of `PracticeSessionBloc` state |

---

## Success Criteria

- [ ] Users can tap any message of up to 20 words without timing errors or rejections
- [ ] 95% of Morse messages tapped with pauses within threshold decode correctly
- [ ] Decoder output appears in text field within 300 ms of inter-letter threshold
- [ ] Keyboard and touch input behave identically (same core, same thresholds)
- [ ] Existing practice mode passes all tests with zero regressions
- [ ] Issue #15 is resolved (no duplicated Morse logic across input handlers)
