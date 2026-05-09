# Feature Specification: QSO and Callsign Practice

**Feature Branch**: `011-qso-callsign-practice`
**Created**: 2026-05-08
**Status**: Draft
**Unlock Level**: 3 — Requires solid word/copy skills (Common Words / Callsign Copy at Level 2).
**Input**: User description: "Feature: QSO Fragment Practice and Callsign Copy. Practice common QSO exchanges with realistic sequences. Random amateur radio callsigns with mix of letters and numbers."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — QSO Fragment Practice (Priority: P1)

A learner enters QSO Fragment practice and hears complete QSO exchange segments as flowing Morse audio units, with no text shown during playback. The goal is to train the brain to recognize common radio exchange patterns holistically — hearing "CQ CQ CQ DE ___ K" as a single familiar rhythm, not decoding letter-by-letter.

**Why this priority**: Core behavior of the feature. Without holistic QSO pattern recognition, the feature cannot deliver its primary value of building real-world Morse communication skills.

**Independent Test**: Can be tested by starting a QSO fragment session, verifying audio plays as one continuous unit, and confirming no text appears during playback.

**Acceptance Scenarios**:

1. **Given** I am in QSO Fragment practice mode, **When** a new session starts, **Then** a QSO fragment plays as one continuous audio unit with realistic inter-word spacing, **And** NO text appears on screen during playback, **And** NO per-word or per-letter highlighting occurs, **And** the screen shows only a "Listen..." pulse indicator.

2. **Given** the QSO fragment audio has finished, **When** I tap the word using the Morse keyboard, **Then** the app accepts pauses up to 3 dits between symbols within a word without breaking the fragment, **And** pauses up to 3 dashes (9 dits) are accepted as a word boundary, **And** the app does NOT show live letter-by-letter decoding as I tap, **And** the app shows only a raw tap accumulation indicator (e.g., "● ●●● ●").

3. **Given** the target QSO fragment is "CQ CQ CQ DE W1AW K", **When** I key the correct pattern, **Then** my submission is accepted as correct, **And** the full text appears in plain text, **And** the audio replays once at 80% speed for reinforcement.

---

### User Story 2 — Callsign Copy (Priority: P1)

A learner enters Callsign Copy mode and hears random amateur radio callsigns played as continuous Morse audio. The learner must copy the exact callsign — a critical real-world skill since operators identify each other by callsign.

**Why this priority**: Callsign copy is a fundamental real-world Morse skill. Without it, operators cannot identify who they are communicating with.

**Independent Test**: Can be tested by starting Callsign Copy mode, hearing a callsign, keying it back, and verifying the result.

**Acceptance Scenarios**:

1. **Given** I am in Callsign Copy mode, **When** a new callsign plays, **Then** the callsign plays as one continuous audio unit, **And** the callsign contains a mix of letters and numbers, **And** NO text appears during playback, **And** the screen shows only a "Listen..." pulse indicator.

2. **Given** a callsign "K6AA" has played, **When** I key back the pattern correctly, **Then** the submission is accepted as correct, **And** the callsign appears in plain text, **And** the audio replays once at 80% speed.

3. **Given** I have keyed a callsign pattern incorrectly, **When** I submit, **Then** the correct callsign appears in plain text, **And** the audio replays at normal speed, **And** the callsign is requeued for future practice.

---

### User Story 3 — Pattern Recognition Scaffolding (Priority: P2)

New or struggling learners receive scaffolding that helps them recognize common QSO patterns (e.g., "NAME ___ ___", "QTH ___", "RST ___ ___"). Well-practiced learners receive pure audio challenges with no visual preview.

**Why this priority**: Adaptive scaffolding personalizes the learning experience, but the core practice works without it.

**Independent Test**: Can be tested by simulating different familiarity levels and verifying whether pattern hints appear before audio playback.

**Acceptance Scenarios**:

1. **Given** a QSO fragment has Familiarity Score < 20% (new / struggling), **When** the fragment is presented, **Then** a pattern hint appears for 2 seconds before audio plays (e.g., "NAME [___] [___]"), **And** the hint disappears, **And** then the audio plays.

2. **Given** a QSO fragment or callsign has Familiarity Score ≥ 60%, **When** the item is presented, **Then** NO text or hint is shown before audio, **And** I must recognize the pattern purely by sound.

3. **Given** a callsign has Familiarity Score < 20%, **When** the callsign is presented, **Then** the prefix region hint appears for 2 seconds (e.g., "[K/W/N/A] _ _ _ _"), **And** then the audio plays.

---

### User Story 4 — Mode Selection and Progression (Priority: P2)

The learner can choose between QSO Fragment practice and Callsign Copy from the home screen. Progress in each mode is tracked independently.

**Why this priority**: Mode selection is essential for discoverability, but the core practice modes work independently.

**Independent Test**: Can be tested by navigating from the home screen to each mode and verifying independent progress tracking.

**Acceptance Scenarios**:

1. **Given** I am on the home screen, **When** I look for practice modes, **Then** I see both "QSO Fragments" and "Callsign Copy" as selectable options, **And** each mode has a visual indicator showing my current progress level.

2. **Given** I have practiced QSO Fragments and achieved 50% familiarity on several items, **When** I switch to Callsign Copy, **Then** my Callsign Copy progress starts independently from zero, **And** my QSO Fragment progress is preserved.

---

### Edge Cases

- What happens when the user pauses for exactly the inter-word threshold during a callsign? The boundary is treated as a word boundary; the current pattern is submitted.
- What happens if the user taps during audio playback? Input is blocked until playback finishes.
- What happens if the user submits an empty pattern? Treated as incorrect; the correct text is shown and replayed.
- What happens for items with Familiarity Score between 20% and 60%? No pre-audio text or hint is shown; the item is treated as partially known.
- What happens if the user exits mid-session? Session results up to that point are saved to the Word Familiarity tracking system.
- What happens if the device receives a phone call or notification during audio playback? Audio pauses gracefully and resumes or restarts based on user action.
- What happens if a generated callsign contains ambiguous characters (e.g., "B" and "8" sound similar)? The callsign is still presented as-is; the learner must distinguish by pattern.
- What happens if a QSO fragment contains a callsign the user has never heard? The user must key the full pattern; callsign knowledge from Callsign Copy mode may help but is not required.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a QSO Fragment practice mode accessible from the home screen.
- **FR-002**: The system MUST provide a Callsign Copy mode accessible from the home screen.
- **FR-003**: In QSO Fragment mode, the system MUST play complete QSO fragments as single continuous audio units with realistic inter-word spacing.
- **FR-004**: In Callsign Copy mode, the system MUST play callsigns as single continuous audio units.
- **FR-005**: The system MUST NOT display text, per-word highlighting, or letter-by-letter decoding on screen during audio playback in either mode.
- **FR-006**: The system MUST display a "Listen..." pulse indicator during playback in both modes.
- **FR-007**: The system MUST accept Morse keyboard input with forgiving timing: pauses up to 3 dits between symbols within a word, and up to 3 dashes (9 dits) as a word boundary.
- **FR-008**: The system MUST compare submitted tap sequences holistically against the target QSO fragment or callsign based on dit/dah sequence correctness, not timing exactitude.
- **FR-009**: The system MUST provide an explicit Submit button as an alternative to auto-submitting on long pauses.
- **FR-010**: The system MUST display only a raw tap accumulation indicator while the user is keying, with no live letter decoding.
- **FR-011**: On correct submission, the system MUST display the QSO fragment or callsign in large plain text, replay the audio at 80% speed, increase the Familiarity Score, and advance to the next item after a 2-second pause.
- **FR-012**: On incorrect submission, the system MUST display the correct text in plain text, replay the audio at normal speed, decrease or partially reset the Familiarity Score, requeue the item, and advance immediately after replay.
- **FR-013**: The system MUST track a per-item Familiarity Score (0–100%) independently for QSO Fragments and Callsigns.
- **FR-014**: For items with Familiarity Score < 20%, the system MUST show a pattern hint for 2 seconds before playing audio.
- **FR-015**: For items with Familiarity Score ≥ 60%, the system MUST NOT show text or hints before audio.
- **FR-016**: The system MUST generate callsigns following realistic amateur radio prefix patterns (e.g., K, W, N, A prefixes for US; DL, G, F, JA for international).
- **FR-017**: The system MUST manage a library of at least 20 common QSO fragments.
- **FR-018**: The system MUST generate callsigns with a mix of letters and numbers.
- **FR-019**: Progress in QSO Fragment mode and Callsign Copy mode MUST be tracked independently.
- **FR-020**: The system MUST gate QSO Fragment and Callsign Copy practice behind Level 3; learners below Level 3 see the mode grayed out with "Unlock at Level 3".

### Key Entities

- **QsoFragment**: Represents a target QSO exchange segment with text, Morse pattern, category, and difficulty. Key attributes: text, morseCode, category (e.g., "CQ", "RST", "QTH", "CLOSING"), difficulty.
- **Callsign**: Represents a generated amateur radio callsign with text, Morse pattern, prefix, and difficulty. Key attributes: text, morseCode, prefix, region, difficulty.
- **ItemFamiliarity**: Per-item learning state tracked for both QSO Fragments and Callsigns. Key attributes: itemText, itemType (qso_fragment | callsign), familiarityScore (0–100%), totalAttempts, correctCount, lastReviewed, nextReviewDue.
- **QsoSession**: An active practice session containing a pre-generated queue of items, current index, session results, and current phase. Key attributes: itemQueue, currentIndex, sessionResults, phase (listening | tapping | feedback), mode (qso_fragment | callsign).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Learners can complete a 20-item QSO Fragment session in under 6 minutes.
- **SC-002**: Learners can complete a 20-item Callsign Copy session in under 5 minutes.
- **SC-003**: QSO fragment audio playback is perceived as a single flowing unit; inter-word gaps are natural and consistent with real radio exchanges.
- **SC-004**: 90% of tapped QSO fragment and callsign patterns submitted within timing thresholds are accepted as correct when the dit/dah sequence matches the target, regardless of internal pause variation.
- **SC-005**: After 5 sessions, average Familiarity Score for practiced QSO fragments increases by at least 20 percentage points.
- **SC-006**: After 5 sessions, average Familiarity Score for practiced callsigns increases by at least 20 percentage points.
- **SC-007**: Learners with items at Familiarity Score ≥ 60% achieve ≥ 80% accuracy on pure audio challenges (no hint preview).

## Assumptions

- The app already has an existing Morse audio playback service capable of generating timed tones.
- The existing keyboard keyer handler can be adapted to support item-level input with forgiving timing thresholds.
- A curated list of at least 20 common QSO fragments already exists or will be sourced for initial content.
- Callsign generation follows simplified ITU prefix rules; full international regulatory compliance is out of scope.
- Familiarity Scoring is separate from the existing character-level SM-2 spaced repetition system; the two systems may share storage but track different metrics.
- The current Word Practice screen pattern will be extended for QSO and Callsign modes; the feature does not replace existing character or word practice.
- Mobile device audio latency is acceptable for Morse timing at standard WPM ranges (10–20 WPM).
- QSO fragments use standard English QSO vocabulary; non-English exchanges are out of scope for v1.
