# Audio & Timing Spec — Fix Plan

**Source**: Elmer review of `audio-timing.md` (commit `e584bbb`)
**Goal**: Resolve all blocking and important issues before downstream features build on this spec.

---

## Blocking (Must Fix Before Shipping)

### F1: Correct Farnsworth Example Numbers
**Problem**: 10/20 Farnsworth example claims `interCharSpaceMs ≈ 1623` and `interWordSpaceMs ≈ 3787`. ARRL formula yields `≈ 834` and `≈ 1945`.
**Fix**: Re-run formula with `c=20, s=10`, update example line-by-line.
**Verify**: `t_a = (1200 - 372) / 200 = 4.14s`, `t_c = 12.42/19 = 0.654s`, `t_w = 28.98/19 = 1.525s`.

### F2: Fix Acceptance Criterion #2
**Problem**: AC2 asserts the wrong expected values (`≈ 1623`, `≈ 3787`).
**Fix**: Replace with correct values: `interCharSpaceMs ≈ 834`, `interWordSpaceMs ≈ 1945`.

### F3: Add `stop()`/`cancel()` to `AudioService`
**Problem**: No lifecycle control — user can't abort playback mid-character.
**Fix**: Add to interface:
```dart
/// Halt any active playback immediately.
Future<void> stop();
```
Update side-effect rule: `BlocListener` calls `stop()` on `PracticeSessionExited` or `SettingsChangedMidPlayback`.

---

## Important (Should Fix Before Merging)

### F4: Decouple `playCharacter` from Domain Knowledge
**Problem**: `playCharacter(String character, MorseTiming timing)` forces audio layer to know Morse code mappings.
**Fix**: Replace with:
```dart
abstract class AudioService {
  Future<void> playPattern(List<MorseElement> elements, MorseTiming timing);
  ...
}

sealed class MorseElement {}
final class Tone extends MorseElement {
  final int durationMs;
  Tone(this.durationMs);
}
final class Silence extends MorseElement {
  final int durationMs;
  Silence(this.durationMs);
}
```
A separate `MorsePatternResolver` (domain layer) maps `"R"` → `[Tone(60), Silence(60), Tone(180)]`.

### F5: Complete `MorseTiming` Getters
**Problem**: `interCharSpaceMs` and `interWordSpaceMs` are stub comments.
**Fix**: Implement getters with actual Farnsworth branching:
```dart
int get interCharSpaceMs => effectiveWpm < wpm
    ? (3 * unitMs) + ((3 * t_a) / 19 * 1000).round()
    : 3 * unitMs;
```
(Same pattern for `interWordSpaceMs`.)

### F6: Add Boundary Acceptance Criteria
**Problem**: No tests for edge cases.
**Fix**: Add ACs:
- **AC5**: Given `wpm = 20` and `effectiveWpm = 20`, then `interCharSpaceMs = 180`, `interWordSpaceMs = 420` (standard timing, zero Farnsworth).
- **AC6**: Given `effectiveWpm > wpm`, then `effectiveWpm` is clamped to `wpm` before calculation (no negative extra delay).
- **AC7**: Given `wpm = 5` (minimum), then `unitMs = 240`, `dashMs = 720`.
- **AC8**: Given `wpm = 40` (maximum), then `unitMs = 30`, `dashMs = 90`.
- **AC9**: Given `toneFrequency = 300` and `toneFrequency = 2000`, tones play at boundary frequencies without distortion.

---

## Nice to Have

### F7: Link Latency Requirement
Add reference under Audio Service: "Latency requirement defined in `spec.md` SC-005: <50ms from trigger to sound output."

### F8: Add Tone/Silence Sequence Diagram
Add ASCII diagram showing `playPattern([Tone(60), Silence(60), Tone(180)], timing)` timeline for character "R".

### F9: Document Morse Pattern Lookup Location
Add note: "Character-to-pattern mapping lives in `lib/domain/morse/`, NOT in `AudioService`."

---

## Risks to Monitor

### R1: `Future<void>` Playback Drift
`playTone` returning `Future<void>` may resolve before hardware finishes. Document that implementations must await actual playback completion, not just buffer enqueue.

### R2: Integer Rounding Accumulation
`(1200 / wpm).round()` introduces small errors (e.g., 13 WPM → 92ms instead of 92.307ms). Document that this is acceptable for single-character practice; word/phrase mode may need cumulative timing correction.

---

## Execution Order

1. **F1 + F2** together (same formula, same example)
2. **F3** (adds interface method)
3. **F5** (completes data model)
4. **F4** (refactors interface — do after F3/F5 to avoid merge conflicts)
5. **F6** (adds ACs — do after F1/F2/F5 so values are correct)
6. **F7–F9** last (documentation polish)

Each fix gets its own commit. F1–F3 are blocking; F4–F6 are important; F7–F9 are nice-to-have.
