# Morse Code UI Control Design

> **Goal:** Allow morse code keying to control UI buttons on non-active practice screens.

**Architecture:** A new `MorseCommandHandler` accumulates decoded letters into words. When a word gap fires, the full word is checked against a command map and the matching action executes. The handler is only active when `PracticeScreen` is not in `PracticeSessionActive` state.

**Tech Stack:** Flutter, Dart, existing `KeyboardKeyerHandler` + `MorseTimingEngine`.

---

## Problem

The spacebar keyer decoder is always running in `PracticeScreen`, but during level select and completion screens, keyed patterns are ignored. The user wants to control buttons by keying morse commands.

## Constraints

- Must not affect active practice session keyer behavior (real-time single-character decoding)
- Must use existing `KeyboardKeyerHandler` and `MorseTimingEngine`
- Must be testable

## Design

### Component: `MorseCommandHandler`

A wrapper around `KeyboardKeyerHandler` that:

1. Listens for `onPatternComplete` (single letter decoded after word gap)
2. If letter gap fires (key up after ~3 dits): decodes pattern, appends to `_wordBuffer`
3. If word gap fires (key up after ~9 dits): submits `_wordBuffer` to `onCommand` callback
4. Resets buffer on submit

Key insight: `KeyboardKeyerHandler` already auto-submits after word gap. To distinguish **letter** vs **word** boundaries, `MorseCommandHandler` tracks timing between `onPatternComplete` calls.

**Letter accumulation rule:**
- If time since last `onPatternComplete` < `keyerInterWordThresholdMs` → same word, append letter
- If time >= `keyerInterWordThresholdMs` → new word, submit previous buffer first, then start new word

### Command Map

| Screen | Word | Action |
|--------|------|--------|
| Level select | `sp` | Start practice (current level) |
| Level select | `up` | Increment level |
| Level select | `do` | Decrement level |
| Completion | `re` | Repeat session |
| Completion | `ne` | Next level |
| Completion | `ex` | Exit to level select |

### Integration in `PracticeScreen`

- `_initKeyer()` creates both `KeyboardKeyerHandler` (for active session) and `MorseCommandHandler` (for UI control)
- `_handleKeyEvent` routes key events:
  - If `PracticeSessionActive`: to active keyer
  - Else: to command handler
- `MorseCommandHandler` receives `BuildContext` to dispatch bloc events / call `setState`
- On state change to `PracticeSessionActive`: flush command buffer, switch to active keyer
- On state change to `PracticeSessionComplete` / `PracticeSessionInitial`: switch to command handler

### State Machine

```
[Initial/Complete] -- key events --> MorseCommandHandler -- word decoded --> command action
[Active] -- key events --> KeyboardKeyerHandler -- pattern --> SubmitMorsePattern
```

### Testing

1. **Unit test:** `MorseCommandHandler` accumulates letters, fires command on word gap
2. **Unit test:** Unknown word does nothing
3. **Widget test:** Key `sp` on level select dispatches `StartSession`
4. **Widget test:** Key `ex` on completion dispatches `EndSession`
5. **Widget test:** Active session still uses raw keyer (no command interference)

## Files

- **Create:** `lib/core/input/morse_command_handler.dart`
- **Modify:** `lib/ui/screens/practice_screen.dart` (routing logic)
- **Test:** `test/core/input/morse_command_handler_test.dart`
- **Test:** `test/ui/screens/practice_screen_test.dart` (add command tests)

## Risks

- **Accidental commands:** User might key letters naturally and trigger commands. Mitigation: commands are two-letter words; single letters do nothing.
- **Timing confusion:** Active session keyer uses same timing engine. No risk since only one handler active at a time.
