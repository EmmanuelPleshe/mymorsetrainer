# Feature Specification: Central Morse Timing Module

**Feature Branch**: `010-central-morse-timing`
**Created**: 2026-05-10
**Status**: Draft

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Single Source of Truth (Priority: P1)

As a developer, I want all Morse timing computed in one place so that changing WPM updates playback, keyer thresholds, and UI consistently.

**Independent Test**: Unit test verifies `MorseTimingEngine` outputs correct durations at 20 WPM.

**Acceptance Scenarios**:

1. **Given** WPM=20 and effWPM=20, **When** timing engine computes durations, **Then** dot=60ms, dash=180ms, intra-char=60ms, inter-char=180ms, inter-word=420ms.
2. **Given** WPM=20 and effWPM=10, **When** timing engine computes durations, **Then** dot and dash stay at 60ms/180ms, **And** inter-char and inter-word expand per Farnsworth formula.

---

### User Story 2 — Keyer Threshold Synchronization (Priority: P1)

As a learner, I want keyer dot/dash classification and auto-submit thresholds to match the audio playback timing exactly, so my keyed input is judged against the same standard I hear.

**Independent Test**: Unit test: keyer threshold at 20 WPM equals 3× dot duration from timing engine.

**Acceptance Scenarios**:

1. **Given** timing engine at 20 WPM, **When** keyer requests dot/dash threshold, **Then** threshold = 180ms (3 dits).
2. **Given** timing engine at 20 WPM, **When** keyer requests inter-letter threshold, **Then** threshold = 180ms (3 dits).
3. **Given** timing engine at 20 WPM, **When** keyer requests inter-word threshold, **Then** threshold = 540ms (9 dits).

---

### User Story 3 — Zero Drift Guarantee (Priority: P1)

As a developer, I want a guarantee that playback timing and keyer thresholds never drift, so bug reports about "keyer too strict/loose" disappear.

**Independent Test**: Regression test: change WPM, verify keyer threshold and playback dot duration both update proportionally.

**Acceptance Scenarios**:

1. **Given** WPM changed from 20 to 15, **When** timing engine recomputes, **Then** dot duration becomes 80ms, **And** keyer dot/dash threshold becomes 240ms (still 3× dot).

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `MorseTimingEngine` MUST compute `dotDurationMs` as `1200 / WPM` rounded to nearest integer.
- **FR-002**: `MorseTimingEngine` MUST compute `dashDurationMs` as `dotDurationMs × 3`.
- **FR-003**: `MorseTimingEngine` MUST compute `intraCharacterSpaceMs` as `dotDurationMs × 1`.
- **FR-004**: `MorseTimingEngine` MUST compute `interCharacterSpaceMs` using ARRL Farnsworth formula when `effWPM < WPM`, otherwise `dotDurationMs × 3`. Result rounded to nearest integer ms.
- **FR-005**: `MorseTimingEngine` MUST compute `interWordSpaceMs` using ARRL Farnsworth formula when `effWPM < WPM`, otherwise `dotDurationMs × 7`. Result rounded to nearest integer ms. Extra word space (default 0 ms) added on top.
- **FR-006**: `MorseTimingEngine` MUST expose `keyerDotDashThresholdMs` as `dotDurationMs × 3`.
- **FR-007**: `MorseTimingEngine` MUST expose `keyerInterLetterThresholdMs` as `dotDurationMs × 3`.
- **FR-008**: `MorseTimingEngine` MUST expose `keyerInterWordThresholdMs` as `dotDurationMs × 9`.
- **FR-009**: `AudioPlaybackService` MUST read all timing values from `MorseTimingEngine` and MUST NOT compute durations internally.
- **FR-010**: `KeyboardKeyerHandler` MUST accept a `MorseTimingEngine` instance and read thresholds from it.
- **FR-010a**: `GameControllerKeyerHandler` MUST accept a `MorseTimingEngine` instance and read thresholds from it.
- **FR-010b**: `AudioKeyerHandler` MUST accept a `MorseTimingEngine` instance and read thresholds from it.
- **FR-011**: Existing tests MUST be updated to assert against `MorseTimingEngine` values rather than hardcoded constants.
- **FR-012**: `WpmCalculator` MUST be removed; all timing logic consolidated into `MorseTimingEngine`.
- **FR-013**: `AudioPlaybackService.playWord` MUST use `interCharacterSpaceMs` (3 dits) between letters, not `intraCharacterSpaceMs * 2` (incorrect 5 dits).

### Key Entities

- **MorseTimingEngine**: Immutable timing calculator. Fields: wpm, effWpm, extraWordSpace (default 0). Computed getters for all durations and thresholds.
- **AudioPlaybackService**: Reads timing from `MorseTimingEngine`. No internal timing calculations.
- **KeyboardKeyerHandler**: Reads dot/dash, inter-letter, inter-word thresholds from `MorseTimingEngine`.
- **GameControllerKeyerHandler**: Reads thresholds from `MorseTimingEngine`.
- **AudioKeyerHandler**: Reads thresholds from `MorseTimingEngine`.
- **WpmCalculator**: Replaced by `MorseTimingEngine`.

## Success Criteria *(mandatory)*

- **SC-001**: Changing WPM in one place updates playback timing and keyer thresholds identically.
- **SC-002**: 100% of Morse timing constants in codebase come from `MorseTimingEngine`; zero hardcoded timing outside engine and tests.
- **SC-004**: `AudioPlaybackService.playWord` inter-letter gap equals 3 dits (interCharacterSpaceMs), not 5 dits.
- **SC-003**: All existing tests pass after refactor with no behavioral changes.

## Assumptions

- ARRL PARIS standard is the correct formula for all timing.
- Rounding to nearest integer ms is acceptable for all durations.
