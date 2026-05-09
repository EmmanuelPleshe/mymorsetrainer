# Feature Specification: Contest Mode and Prosign Practice

**Feature Branch**: `017-contest-prosigns`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "Mini-Contest Mode with callsign copying and Prosign Practice in contextual QSO phrases"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Mini-Contest Mode (Priority: P1)

A learner enters Contest Mode for a 5-minute timed session. The app plays random callsigns followed by signal reports as fast as the learner can copy. Score = correct copies minus errors. Personal best and leaderboard are tracked.

**Why this priority**: Mimics real radio contest pressure in a low-stakes environment. Builds speed and accuracy under time pressure.

**Independent Test**: Can be tested by running a 5-minute session and verifying the score calculation.

**Acceptance Scenarios**:

1. **Given** I start Contest Mode, **When** the session begins, **Then** a 5-minute countdown timer appears, **And** the first callsign plays immediately.
2. **Given** I correctly copy a callsign and signal report, **When** I submit, **Then** my score increases by 1, **And** the next exchange plays.
3. **Given** I submit an incorrect copy, **When** the answer is checked, **Then** my score decreases by 1, **And** the correct text is shown briefly.
4. **Given** the 5-minute timer expires, **When** the session ends, **Then** my final score is displayed, **And** if it is a personal best, a "New Record!" indicator appears, **And** the score is saved to the leaderboard.

---

### User Story 2 — Prosign Practice (Priority: P2)

A learner enters Prosign Practice mode. The app plays common procedural signs (AR, BT, KN, SK, BK, CL) in the context of realistic QSO phrases. The learner must recognize the prosigns within flowing sentences.

**Why this priority**: Prosigns are essential for real-world Morse communication but are rarely practiced in isolation. Contextual practice builds recognition reflexes.

**Independent Test**: Can be tested by entering Prosign Practice, hearing "HELLO BT UR RST 599 AR", and verifying recognition of BT and AR.

**Acceptance Scenarios**:

1. **Given** I am in Prosign Practice mode, **When** a phrase containing "BT" plays, **Then** the phrase flows naturally, **And** "BT" is not visually distinguished from regular letters during playback.
2. **Given** a phrase with multiple prosigns has played, **When** I am asked to identify them, **Then** I can select the prosigns I recognized from a list, **And** my selection is scored.
3. **Given** I am at lower proficiency levels, **When** prosign practice begins, **Then** phrases contain only 1-2 prosigns, **And** the audio speed is reduced.
4. **Given** I am at higher proficiency levels, **When** prosign practice begins, **Then** phrases contain 3-5 prosigns, **And** the audio speed matches my current comfortable WPM.

---

### Edge Cases

- What happens if a Contest Mode session is interrupted (app backgrounded)? The timer pauses; the session resumes where it left off when the app returns.
- What happens if a prosign is played in isolation (not in a phrase)? At lower levels, prosigns are introduced in isolation first; at higher levels, only contextual phrases are used.
- What happens if the learner submits an empty answer in Contest Mode? The attempt is marked incorrect; the correct answer is shown briefly.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide Mini-Contest Mode with a 5-minute timed session.
- **FR-002**: In Contest Mode, the system MUST play random callsigns followed by signal reports.
- **FR-003**: In Contest Mode, the system MUST calculate score as correct copies minus errors.
- **FR-004**: The system MUST track personal best scores and display a leaderboard for Contest Mode.
- **FR-005**: The system MUST provide Prosign Practice mode for AR, BT, KN, SK, BK, and CL.
- **FR-006**: In Prosign Practice, prosigns MUST be presented in the context of realistic QSO phrases.
- **FR-007**: The system MUST generate callsigns algorithmically for Contest Mode.
- **FR-008**: The system MUST pause the Contest timer when the app is backgrounded and resume when foregrounded.

### Key Entities

- **ContestSession**: A timed contest session. Key attributes: durationSeconds, score, correctCount, errorCount, exchangeQueue, personalBest.
- **ContestExchange**: A single callsign + signal report pair. Key attributes: callsign, signalReport, userAnswer, isCorrect.
- **ProsignPhrase**: A QSO phrase containing procedural signs. Key attributes: phraseText, prosignsContained, difficulty.
- **ProsignRecognitionResult**: A scored prosign identification attempt. Key attributes: phraseId, selectedProsigns, correctProsigns, score.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Contest Mode users achieve ≥ 20 correct copies in a 5-minute session after 1 month of practice.
- **SC-002**: Prosign recognition accuracy reaches ≥ 85% in contextual phrases after 10 practice sessions.
- **SC-003**: Contest Mode leaderboard displays top 10 scores with callsign and date.

## Assumptions

- The app already has a working Morse audio playback service with adjustable WPM and Farnsworth timing.
- The existing keyboard keyer handler can be reused for Contest Mode answer entry.
- Contest Mode uses the same callsign generation logic as the existing Callsign Copy feature.
- Prosigns use standard International Morse code patterns for AR, BT, KN, SK, BK, and CL.
- This mode depends on the Graduated Progression system (spec 014) for unlock gating.
