<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan

## Active Plans

- **Debug Logging System** (006-debug-logging-system): `specs/006-debug-logging-system/plan.md`
  - Cross-platform file-based logging with rotation
  - Send Logs button in Settings for beta testers
<!-- SPECKIT END -->

# Morse Code Trainer — Claude Context

## Project
Flutter/Dart app for learning Morse code via the Koch method combined with
SM-2 spaced repetition. Uses BLoC pattern for state management, audio feedback
for character playback, and a keyboard keyer for dot/dash input.

---

## Morse Timing & Audio Settings

Morse code timing is based on the **PARIS standard** (50 timing units per word)
. All durations derive from a single **unit time** (dit length).

### Core Timing Formulas

```
unitDurationMs = 1200 / wpm
```

| Element | Duration (units) | At 10 WPM | At 20 WPM |
|---------|-----------------|-----------|-----------|
| Dit (dot) | 1 unit | 120 ms | 60 ms |
| Dah (dash) | 3 units | 360 ms | 180 ms |
| Intra-character space | 1 unit | 120 ms | 60 ms |
| Inter-character space | 3 units | 360 ms | 180 ms |
| Inter-word space | 7 units | 840 ms | 420 ms |

**Reference:** At 10 WPM, `unitDurationMs = 1200 / 10 = 120 ms` .

### Settings Screen Controls

The settings screen must expose these **two independent speed controls**:

1. **Character Speed (WPM)** — how fast individual dits/dahs play
   - Range: 5–40 WPM
   - Default: 20 WPM (recommended for Koch method to prevent "counting dits")
   - This directly controls `unitDurationMs = 1200 / wpm`

2. **Effective Speed (WPM)** — overall words-per-minute including spacing
   - Range: 5–40 WPM (must be ≤ character speed)
   - Default: 10 WPM
   - When effective speed == character speed, timing is standard (no extra spacing)
   - When effective speed < character speed, **Farnsworth spacing** is applied

### Farnsworth Spacing Calculation

When effective speed < character speed, extra delay is inserted between
characters and words while keeping character sounds at full speed .

Using the ARRL standard formulas :

```
// Given: characterSpeed = c WPM, effectiveSpeed = s WPM (s < c)

// Standard unit duration (for character sounds)
unitMs = 1200 / c

// Total extra delay per 50-unit word (seconds)
t_a = (60 * c - 37.2 * s) / (s * c)

// Extra delay per inter-character space (seconds)
t_c = (3 * t_a) / 19

// Extra delay per inter-word space (seconds)
t_w = (7 * t_a) / 19

// Final spacing values
interCharSpaceMs = (3 * unitMs) + (t_c * 1000)
interWordSpaceMs = (7 * unitMs) + (t_w * 1000)
```

**Example:** 10/20 Farnsworth (10 WPM effective, 20 WPM character speed):
- Character sounds: 60 ms unit, 180 ms dah
- Extra inter-char delay: ~1443 ms per space
- Extra inter-word delay: ~3367 ms per space
- Result: characters sound fast (20 WPM), but gaps are long (10 WPM overall) 

### Audio Service Interface

The audio service must accept these timing values and generate precisely timed
tones. Do NOT hardcode timing — always calculate from current settings.

```dart
class MorseTiming {
  final int wpm;              // character speed
  final int effectiveWpm;     // effective speed (for Farnsworth)
  final int toneFrequency;    // Hz, e.g. 600
  
  int get unitMs => (1200 / wpm).round();
  int get dotMs => unitMs;
  int get dashMs => unitMs * 3;
  int get intraCharSpaceMs => unitMs;
  int get interCharSpaceMs => /* standard or Farnsworth */;
  int get interWordSpaceMs => /* standard or Farnsworth */;
}
```

### Settings Persistence
- Save `wpm`, `effectiveWpm`, `toneFrequency`, `volume` to local storage
- Load on app start and apply to audio service before first character plays
- Changing settings mid-session: apply immediately to next character

---

## Koch Method — Character Progression

The app follows the G4FON sequence, the de facto standard for modern Koch
method trainers. Characters are introduced one at a time after the initial
pair, not in groups.

### G4FON Sequence (use this exact order)
```
Lesson 1:  K, M
Lesson 2:  R
Lesson 3:  S
Lesson 4:  U
Lesson 5:  A
Lesson 6:  P
Lesson 7:  T
Lesson 8:  L
Lesson 9:  O
Lesson 10: W
Lesson 11: I
Lesson 12: .
Lesson 13: N
Lesson 14: J
Lesson 15: E
Lesson 16: F
Lesson 17: 0
Lesson 18: Y
Lesson 19: ,
Lesson 20: V
Lesson 21: G
Lesson 22: 5
Lesson 23: /
Lesson 24: Q
Lesson 25: 9
Lesson 26: Z
Lesson 27: H
Lesson 28: 3
Lesson 29: 8
Lesson 30: B
Lesson 31: ?
Lesson 32: 4
Lesson 33: 2
Lesson 34: 7
Lesson 35: C
Lesson 36: 1
Lesson 37: D
Lesson 38: 6
Lesson 39: X
```

### Advancement Rules
- User starts with **K and M only** (Lesson 1).
- To unlock the next character: **≥90% accuracy** on ALL currently unlocked
  characters over the last 20 attempts.
- New characters are **ADDED** to the practice pool — never replace existing ones.
- Check advancement criteria **after every answer**, but only unlock new
  characters **between sessions** (never mid-session).
- The "level" is the count of unlocked characters (2 = just K,M; 3 = K,M,R, etc.).

---

## SM-2 Spaced Repetition Algorithm

Every character in the practice pool has an SM-2 card tracking its review state.
Persist this to local storage (Hive/SQLite) and load it on app start.

### Per-Character SM-2 State
```dart
class CharacterReviewState {
  final String symbol;           // e.g. "K", "M", "R"
  final int repetitions;         // successful review streak (0 = new/reset)
  final int interval;            // days until next review
  final double easeFactor;       // starts at 2.5, min 1.3
  final DateTime? lastReviewed;  // when last practiced
  final int totalAttempts;       // total times seen (all sessions)
  final int correctCount;        // total correct answers (all sessions)
}
```

### SM-2 Review Function (implement EXACTLY per official algorithm)
When user answers a character:
- `quality = 5` if correct (heard pattern, keyed correctly)
- `quality = 0` if wrong (any incorrect answer)

```dart
Sm2Result calculateSm2({
  required int quality,      // 5 = correct, 0 = wrong ONLY
  required int repetitions,
  required double easeFactor,
  required int interval,
}) {
  // Official SM-2: EF is updated on EVERY review, including failures
  double newEase = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  if (newEase < 1.3) newEase = 1.3;

  int newRepetitions;
  int newInterval;

  if (quality < 3) {
    // Wrong answer: reset progress, BUT keep the updated easeFactor
    // (EF decreases on failure, making future intervals grow slower)
    newRepetitions = 0;
    newInterval = 1;
  } else {
    // Correct answer
    if (repetitions == 0) {
      newInterval = 1;
    } else if (repetitions == 1) {
      newInterval = 6;
    } else {
      newInterval = (interval * newEase).round();
    }
    newRepetitions = repetitions + 1;
  }

  return Sm2Result(
    interval: newInterval,
    repetitions: newRepetitions,
    easeFactor: newEase,
  );
}
```

### Character Selection for Each Session
Generate the session queue (e.g., 20 characters) ONCE at session start:

1. **Due for review** — characters where `lastReviewed + interval days <= today`,
   sorted by oldest review first. Fill as many slots as available.
2. **New characters** (repetitions == 0) from most recently unlocked — fill
   remaining slots, up to a max of 40% of session.
3. **Random fill** — if still slots remaining, pick from practice pool weighted
   by LOWEST accuracy (`correctCount / totalAttempts`).

This ensures struggling characters come back sooner, new ones get drilled,
and mastered ones fade out naturally.

### Session Completion & Persistence
- After each session, save ALL `CharacterReviewState` objects to local storage.
- On app launch, load them and reconstruct the practice pool.
- If no saved data exists, start fresh with K and M only.

---

## Architecture Rules

### 1. BLoC owns ALL state transitions. UI never triggers events during build().
- **NEVER** call `bloc.add()` from inside `build()`, widget constructors, or
  `StatelessWidget` methods.
- **NEVER** use `Future.microtask(() => bloc.add(...))` to work around the above.
  If you feel the urge, the logic belongs in the BLoC instead.
- UI may only add events in response to explicit user actions (button taps,
  key events, gestures) or inside `BlocListener`/`BlocConsumer` callbacks.
- If a state change should cause another state change (e.g., correct answer →
  next character), implement it entirely within the BLoC event handler using
  sequential `emit()` calls with `await Future.delayed()` if a visual pause is
  needed.

### 2. Practice Session State Machine
The BLoC must track the session as a proper state machine:

```
PracticeSessionInitial
  ↓ StartSession(level)
PracticeSessionLoading
  ↓ queue generated
PracticeSessionActive
  ├── characters: List<Character>      // pre-generated queue, NEVER changes mid-session
  ├── currentIndex: int                // index into characters list
  ├── sessionResults: List<bool>       // true/false for each answered char
  ├── lastAnswerCorrect: bool?         // null = waiting for input
  └── status: PracticeStatus           // waitingForInput | showingFeedback | transitioning
```

When user submits an answer:
1. `SubmitMorsePattern` → validate, record result, update SM-2 state
2. Emit `showingFeedback` state with `lastAnswerCorrect` set
3. `await Future.delayed(Duration(milliseconds: 400))` for visual feedback
4. Increment `currentIndex`, set `lastAnswerCorrect: null`, emit next character

**CRITICAL: The session queue (`characters`) is generated ONCE at session start
and NEVER changes mid-session.** This prevents the "same letter over and over" bug.

```dart
enum PracticeStatus {
  waitingForInput,   // show keyer, user can input
  showingFeedback,   // show correct/incorrect, disable input
  transitioning,     // brief pause before next character (optional)
}
```

### 3. State objects are immutable. Always emit new instances.
- Use `copyWith()` for every state change. Never mutate state fields directly.
- Include ALL fields in `Equatable.props` so no state change is silently ignored.

### 4. Side effects (audio, haptics, navigation) belong in UI listeners, not BLoC.
- BLoC stays pure: business logic + state transitions only.
- `BlocListener` handles one-shot side effects like `playCorrectFeedback()`,
  `playErrorFeedback()`, `playCharacterAudio()`.
- Use a `_feedbackHandled` flag or similar guard if a listener must fire only
  once per distinct state, to avoid replaying sounds on every rebuild.

### 5. Input handlers are stateless pipelines.
- `KeyboardKeyerHandler` decodes raw input into events. It must not hold UI
  state, call `setState`, or access the BLoC directly.
- It emits decoded patterns via callback; the UI layer forwards them to the BLoC.

---

## Common Pitfalls to Avoid

| Anti-pattern | Why it breaks | Do this instead |
|---|---|---|
| Generating next character on-the-fly in BLoC | Same character keeps getting picked if random is biased | Pre-generate full session queue at start |
| `Future.microtask(() => bloc.add(...))` in `build()` | Triggers `setState` during build → crash | Move sequential logic into BLoC handler |
| `lastAnswerCorrect` stuck at `true`/`false` | UI shows feedback forever, no input possible | BLoC resets to `null` after delay, emits next state |
| Feedback side effects in `builder:` | Replays audio every rebuild | Guard with flag, fire from `BlocListener` |
| BLoC calling audio services | BLoC becomes impure, hard to test | UI layer handles audio via `BlocListener` |
| Advancing Koch level mid-session | Session pool changes unexpectedly | Check advancement between sessions only |
| Not persisting SM-2 state | Review intervals lost on app restart | Save to Hive/SQLite after every session |
| Using `DateTime.now()` in BLoC without injecting | Untestable, non-deterministic | Inject `DateTime Function() clock` or only use in UI layer |
| Hardcoding Morse timing values | Settings changes don't affect playback | Always calculate from `wpm`/`effectiveWpm` settings |
| Single WPM slider instead of character+effective | Can't implement Farnsworth method | Two separate sliders with validation |

---

## File Organization
- `lib/ui/screens/` — Widgets, no business logic
- `lib/ui/screens/settings_screen.dart` — WPM, effective WPM, tone frequency, volume
- `lib/ui/bloc/` — BLoCs, pure state machines
- `lib/core/input/` — Raw input decoders (keyer, etc.)
- `lib/core/audio/` — Audio services, consumed by UI only
- `lib/domain/koch/` — Koch progression logic, character unlocking
- `lib/domain/spaced_repetition/` — SM-2 algorithm, character scheduling
- `lib/domain/timing/` — Morse timing calculations, Farnsworth spacing
- `lib/data/models/` — Character, CharacterReviewState, MorseTiming, etc.
- `lib/data/repositories/` — Local persistence (Hive/SQLite)

---

## When Adding or Modifying a Feature
1. Define the state machine: what states exist, what events trigger transitions?
2. Implement transitions in the BLoC first.
3. Wire UI to emit events and react to states.
4. Add side effects (audio, etc.) in `BlocListener` last.
5. Write a unit test for the BLoC state transition BEFORE touching UI.

## Testing Requirements
- Every BLoC event handler must have a unit test verifying state transitions.
- SM-2 calculation must be tested with known inputs/outputs.
- Character selection algorithm must be tested with mock review states.
- Morse timing formulas must be tested against known values (e.g., 10 WPM = 120ms unit).
- NEVER commit code that "works on my machine" but has no tests for new logic.


## Summary of What's New/Corrected

| Section | Change | Why |
|---------|--------|-----|
| **Morse Timing & Audio Settings** | Entirely new section | Was completely missing; your app needs this for correct audio generation |
| **Farnsworth formulas** | Added ARRL standard  | Your current code has `effWpm` but no actual Farnsworth calculation |
| **Two WPM sliders** | Character speed + Effective speed | Required for Farnsworth; single slider can't do it |
| **Settings persistence** | Added requirement | Timing settings must survive app restart |
| **Anti-pattern: Single WPM slider** | Added to pitfalls table | Prevents reintroducing the bug |
| **Anti-pattern: Hardcoded timing** | Added to pitfalls table | Ensures settings actually affect playback |
| **`lib/domain/timing/`** | Added to file organization | Dedicated home for timing logic |
| **Testing: Morse timing** | Added to testing requirements | Validates `1200/WPM` formula |