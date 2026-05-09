# Data Model: Settings Persistence

## Entity: AppSettings

```dart
class AppSettings {
  final String id;                 // PK, always 'current'
  final double toneFrequency;      // 300–2000 Hz
  final double wpm;                // 5–40 WPM
  final double effWpm;             // 5–40 WPM (Farnsworth)
  final double extraWordSpace;     // 0–5 seconds
  final double volume;             // 0.0–1.0
  final InputMethod inputMethod;   // enum: keyboard, touchscreen, gameController, audioInput
  final bool enableGamification;
  final bool enableSoundEffects;
  final bool enableScreenFlash;
}
```

## Validation Rules

| Field | Min | Max | Clamp Behavior |
|-------|-----|-----|----------------|
| wpm | 5.0 | 40.0 | clamp to range |
| effWpm | 5.0 | 40.0 | clamp to range |
| toneFrequency | 300.0 | 2000.0 | clamp to range |
| volume | 0.0 | 1.0 | clamp to range |
| extraWordSpace | 0.0 | 5.0 | clamp to range |

## Database Schema

Table: `settings`

| Column | Type | Constraints | Default |
|--------|------|-------------|---------|
| id | TEXT | PRIMARY KEY | `'current'` |
| toneFrequency | REAL | NOT NULL | 600.0 |
| wpm | REAL | NOT NULL | 20.0 |
| effWpm | REAL | NOT NULL | 20.0 |
| extraWordSpace | REAL | NOT NULL | 0.0 |
| volume | REAL | NOT NULL | 0.5 |
| inputMethod | INTEGER | NOT NULL | 0 |
| enableGamification | INTEGER | NOT NULL | 1 |
| enableSoundEffects | INTEGER | NOT NULL | 0 |
| enableScreenFlash | INTEGER | NOT NULL | 0 |

## State Transitions (SettingsBloc)

```
SettingsInitial
  → LoadSettings → SettingsLoading → SettingsLoaded | SettingsError
SettingsLoaded
  → UpdateWpm → SettingsLoading → SettingsLoaded | SettingsError
  → UpdateToneFrequency → SettingsLoading → SettingsLoaded | SettingsError
  → UpdateVolume → SettingsLoading → SettingsLoaded | SettingsError
  → UpdateEffWpm → SettingsLoading → SettingsLoaded | SettingsError
  → (any update event) → SettingsLoading → SettingsLoaded | SettingsError
```

## Relationships

- `SettingsBloc` → `SettingsRepository` (read/write)
- `SettingsBloc` → `AudioPlaybackService` (sync on change)
- `SettingsRepository` → `DatabaseHelper` (sqflite)
- `SettingsScreen` → `SettingsBloc` (events)
