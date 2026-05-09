# Audio & Timing Specification

**Feature**: Morse Audio Generation & Timing  
**Scope**: Tone generation, timing calculation, Farnsworth spacing, and audio service interface. All other features depend on this.

---

## Timing Model

All Morse durations derive from a single **unit time** (dit length) per the **PARIS standard** (50 timing units per word).

```
unitDurationMs = 1200 / wpm
```

| Element | Duration (units) | At 10 WPM | At 20 WPM |
|---------|------------------|-----------|-----------|
| Dit (dot) | 1 | 120 ms | 60 ms |
| Dah (dash) | 3 | 360 ms | 180 ms |
| Intra-character space | 1 | 120 ms | 60 ms |
| Inter-character space | 3 | 360 ms | 180 ms |
| Inter-word space | 7 | 840 ms | 420 ms |

### Independent Speed Controls

The settings screen exposes **two independent sliders**:

1. **Character Speed (WPM)** — dit/dah playback speed. Range 5–40, default **20**.
2. **Effective Speed (WPM)** — overall WPM including spacing. Range 5–40, must be **≤ character speed**, default **10**.

When effective speed == character speed, timing is standard (no extra spacing).

---

## Farnsworth Spacing

When effective speed < character speed, extra silence is inserted between characters and words while keeping character sounds at full speed.

Using the ARRL standard formulas:

```dart
// Given: characterSpeed = c WPM, effectiveSpeed = s WPM (s < c)

unitMs = 1200 / c;

// Total extra delay per 50-unit word (seconds)
t_a = (60 * c - 37.2 * s) / (s * c);

// Extra delay per inter-character space (seconds)
t_c = (3 * t_a) / 19;

// Extra delay per inter-word space (seconds)
t_w = (7 * t_a) / 19;

// Final spacing values
interCharSpaceMs = (3 * unitMs) + (t_c * 1000);
interWordSpaceMs = (7 * unitMs) + (t_w * 1000);
```

**Example** (10/20 Farnsworth):
- Character sounds: 60 ms unit, 180 ms dash
- Total inter-char space: ~834 ms
- Total inter-word space: ~1945 ms
- Result: characters sound fast (20 WPM), gaps are long (10 WPM overall)

---

## MorseTiming Data Model

```dart
class MorseTiming {
  final int wpm;              // character speed
  final int effectiveWpm;     // effective speed (for Farnsworth)
  final int toneFrequency;    // Hz, e.g. 600

  int get unitMs => (1200 / wpm).round();
  int get dotMs => unitMs;
  int get dashMs => unitMs * 3;
  int get intraCharSpaceMs => unitMs;
  int get interCharSpaceMs {
    if (effectiveWpm >= wpm) return 3 * unitMs;
    final tA = (60 * wpm - 37.2 * effectiveWpm) / (effectiveWpm * wpm);
    final extraMs = ((3 * tA) / 19 * 1000).round();
    return (3 * unitMs) + extraMs;
  }

  int get interWordSpaceMs {
    if (effectiveWpm >= wpm) return 7 * unitMs;
    final tA = (60 * wpm - 37.2 * effectiveWpm) / (effectiveWpm * wpm);
    final extraMs = ((7 * tA) / 19 * 1000).round();
    return (7 * unitMs) + extraMs;
  }
}
```

All timing values are calculated from `wpm` and `effectiveWpm`. No hardcoded durations anywhere in the app.

---

## Audio Service Interface

Audio layer knows tones and silences only. Character-to-pattern mapping lives in domain layer (`lib/domain/morse/`).

```dart
sealed class MorseElement {}

final class Tone extends MorseElement {
  final int durationMs;
  Tone(this.durationMs);
}

final class Silence extends MorseElement {
  final int durationMs;
  Silence(this.durationMs);
}

abstract class AudioService {
  /// Play a single tone of [frequency] Hz for [durationMs] milliseconds.
  Future<void> playTone({required int frequency, required int durationMs});

  /// Play a silence (gap) for [durationMs] milliseconds.
  Future<void> playSilence({required int durationMs});

  /// Play a complete pattern of tones and silences.
  /// The service must handle tone + silence sequencing.
  Future<void> playPattern(List<MorseElement> elements, MorseTiming timing);

  /// Set master volume (0.0 – 1.0). Affects all subsequent playback.
  void setVolume(double volume);

  /// Halt any active playback immediately.
  Future<void> stop();
}
```

### Morse Pattern Resolver

Domain layer maps characters to patterns:

```dart
abstract class MorsePatternResolver {
  List<MorseElement> resolve(String character);
}
```

Example: `"R"` → `[Tone(60), Silence(60), Tone(180)]` at 20 WPM.

### Side-Effect Rule
BLoC must NOT call audio services. `BlocListener` in the UI layer handles audio side effects.
`BlocListener` calls `stop()` on `PracticeSessionExited` or `SettingsChangedMidPlayback` to abort playback immediately.

---

## Settings Persistence

Save to local storage on change, load on app start:

- `wpm` (int)
- `effectiveWpm` (int)
- `toneFrequency` (int)
- `volume` (double, 0.0–1.0)

Changing settings mid-session must apply to the **next character played**, never interrupt audio currently in progress.

---

## Acceptance Criteria

1. Given character speed = 20 WPM and effective = 20 WPM, when timing is calculated, then unitMs = 60, dotMs = 60, dashMs = 180, interCharSpaceMs = 180, interWordSpaceMs = 420.
2. Given character speed = 20 WPM and effective = 10 WPM, when timing is calculated, then Farnsworth extra delay is applied and interCharSpaceMs ≈ 834, interWordSpaceMs ≈ 1945.
3. Given user changes WPM slider during a session, when next character plays, then new timing values are used without interrupting current audio.
4. Given app restarts, when settings load, then previously saved WPM, effective WPM, tone, and volume are restored.
