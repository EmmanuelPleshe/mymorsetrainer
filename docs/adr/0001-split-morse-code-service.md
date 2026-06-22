# ADR-0001: Split MorseCodeService into Mapper, Coordinator, and AudioPlaybackService

## Status

Accepted

## Context

`MorseCodeService` mixed three concerns in a single shallow module: pure Morse code data (character-to-pattern map, Koch sequence), audio playback (WAV generation, process management, timing), and sequencing logic (iterating symbols, inserting pauses). The `AudioService` interface exposed high-level Morse methods like `playCharacter(String)` and `playWord(String)`, embedding Morse knowledge inside the audio seam.

Three divergent copies of the Morse code table existed across the codebase:

1. `MorseCodeService._morseCode` — 40 entries (letters, digits, 4 punctuation)
2. `CharacterRepository.initializeCharacters()` — 26 entries (letters only, different Koch order)
3. `Word.textToMorse()` — 37 entries (letters + digits, no punctuation)

The Koch sequence also diverged: `MorseCodeService` had 38 characters, `CharacterRepository` had 25 in a different order.

`MorseCodeService` was largely dead code — only `getMorsePattern()` was called (by `AudioPlaybackService` internally). The Koch sequence, `getCharactersForLevel`, `getTotalLevels`, `getAllCharacters`, and `wordToMorse` were unused.

`AudioPlaybackService` used a singleton pattern (`factory` + private `_internal`) that fought the provider-tree dependency injection used elsewhere in the app, causing test state leakage.

Inter-word spacing was computed by `MorseTimingEngine` but never inserted during playback — spaces in input strings were silently skipped.

## Decision

Split the monolith into three deep modules:

- **`MorseCodeMapper`** — owns the Morse code character map (full ITU-R M.1677 set) and the expanded Koch sequence (letters, digits, full ITU punctuation, common prosigns). Pure data module with no audio, timing, or playback dependencies. Single source of truth for all character-to-pattern lookups, Koch level queries, and word-to-Morse conversion. Instance-based for injectability.

- **`AudioPlaybackService`** — owns tone generation, WAV file management, playback process lifecycle, timing parameters (WPM, Farnsworth, volume), and the `MorseTimingEngine`. Exposes narrow audio primitives: `playDot()`, `playDash()`, `intraCharacterPause()`, `interCharacterPause()`, `interWordPause()`, `keyerDown()`, `keyerUp()`, `playCorrectFeedback()`. No knowledge of Morse tables or Koch progression. Singleton pattern dropped in favor of constructor injection.

- **`MorseCodeCoordinator`** — thin orchestration layer that depends on `MorseCodeMapper` and `AudioService`. Given a string, asks the mapper for patterns, sequences dots/dashes/pauses through the audio service, handles inter-word spacing, and drives the `onFlash` visual callback. Only place where Morse logic and audio logic meet.

`MorseCodeService` is deleted. `Word.textToMorse()` is deleted. `CharacterRepository.initializeCharacters()` reads from `MorseCodeMapper` instead of its inline map. `QSOService.phraseToMorse()` delegates to `MorseCodeMapper.wordToMorse()`.

`SettingsBloc` depends on `AudioPlaybackService` directly for configuration (setters). Practice screens depend on `MorseCodeCoordinator` (playback), `AudioPlaybackService` (keyer, feedback), and `MorseCodeMapper` (level queries) — three clean seams.

## Consequences

**Positive:**
- Each module testable in isolation: mapper (pure unit tests), audio service (timing, clamping, file lifecycle), coordinator (mock `AudioService`, verify sequencing)
- Single source of truth for Morse code data — no more divergent tables
- Audio backend swappable — `AudioService` interface is now audio primitives, so a Flutter plugin or web audio backend can implement it without Morse knowledge
- Inter-word spacing bug fixed as a natural consequence of coordinator owning sequencing
- Singleton removed — clean test isolation, consistent with app's DI pattern
- Expanded Koch sequence covers full ITU character set + common prosigns (50+ characters)

**Negative:**
- Callers depend on two or three modules instead of one
- More files and wiring at the composition root
- `AudioService` interface change is a breaking change for any external consumers (none currently exist)