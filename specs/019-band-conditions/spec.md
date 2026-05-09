# Feature Specification: Band Conditions Simulation

**Feature Branch**: `019-band-conditions`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "Band Conditions Simulation — static, QRM, QSB, QRN audio degradation for realistic practice"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Band Conditions Simulation (Priority: P1)

A learner enters any advanced practice mode with Band Conditions enabled. The audio includes adjustable background static, interference (QRM), fading (QSB), and atmospheric noise (QRN). The learner practices copying through degraded audio, starting clean and introducing noise as they advance.

**Why this priority**: Clean audio is a luxury. Real operators copy through garbage. This prepares learners for on-air conditions.

**Independent Test**: Can be tested by enabling Band Conditions in Head-Copy mode and verifying degraded audio playback.

**Acceptance Scenarios**:

1. **Given** I enable Band Conditions in settings, **When** I enter Head-Copy mode, **Then** the audio includes background static at the configured level.
2. **Given** I am at Level 7 or higher, **When** Band Conditions are active, **Then** light static and occasional QSB fading are present.
3. **Given** I am at Level 9 or higher, **When** Band Conditions are active, **Then** heavy QRM (interference signal) and QRN (pops/crashes) are present.
4. **Given** Band Conditions are active, **When** I adjust the static intensity slider, **Then** the audio updates in real time for the next played word.
5. **Given** I am below Level 7, **When** I try to enable heavy QRM, **Then** the option is disabled with a message "Unlock at Level 9".

---

### Edge Cases

- What happens if Band Conditions static level exceeds device audio limits? The static is capped at a safe maximum; no audio clipping occurs.
- What happens if multiple noise types are active simultaneously? The system mixes them at their respective intensity levels without exceeding 0 dBFS.
- What happens if Band Conditions are toggled mid-session? The next played word uses the updated settings; already-played words are not re-generated.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide Band Conditions Simulation with adjustable static (white noise).
- **FR-002**: The system MUST provide QRM simulation (second Morse signal at similar frequency).
- **FR-003**: The system MUST provide QSB simulation (volume randomly drops 20-50%).
- **FR-004**: The system MUST provide QRN simulation (random pops and crashes).
- **FR-005**: The system MUST enable light Band Conditions at Level 7+ and heavy conditions at Level 9+.
- **FR-006**: The system MUST cap total audio amplitude to prevent clipping when noise is mixed with Morse signal.
- **FR-007**: The system MUST allow per-noise-type intensity sliders in settings.
- **FR-008**: The system MUST disable heavy noise options for learners below the required proficiency level.
- **FR-009**: The system MUST apply Band Conditions to all practice modes that support audio playback.
- **FR-010**: Band Conditions audio effects MUST be generated algorithmically and not require pre-recorded samples.

### Key Entities

- **BandConditions**: Audio degradation settings. Key attributes: staticLevel, qrmEnabled, qsbEnabled, qrnEnabled, qrmIntensity, qsbDepthPercent.
- **BandConditionsPreset**: A named preset of conditions. Key attributes: name, staticLevel, qrmEnabled, qsbEnabled, qrnEnabled, requiredLevel.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Band Conditions users at Level 9+ maintain ≥ 75% copy accuracy in heavy QRM + QRN conditions.
- **SC-002**: 80% of users report Band Conditions "better prepared me for real on-air copying" after 2 weeks of use.
- **SC-003**: Audio degradation does not increase playback latency by more than 10ms compared to clean audio.

## Assumptions

- The app already has a working Morse audio playback service with adjustable WPM.
- Band Conditions audio effects are generated algorithmically and do not require pre-recorded samples.
- This feature depends on the Graduated Progression system (spec 014) for unlock gating of heavy conditions.
- The existing audio pipeline can accept a post-processing noise layer without architectural changes.
