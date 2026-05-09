# Feature Specification: Adaptive Speed Ladder

**Feature Branch**: `016-speed-ladder`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "Adaptive Speed Ladder mode — dynamically adjusts WPM based on consecutive correct/incorrect responses"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Adaptive Speed Ladder (Priority: P1)

A learner enters Speed Ladder mode. The app starts at their comfortable base speed. After every 5 consecutive correct words, speed increases by 1 WPM. After 2 consecutive failures, speed decreases by 1 WPM. The session pushes their "speed ceiling" higher over time.

**Why this priority**: Builds real fluency by dynamically challenging the learner at their edge. Prevents plateauing at a comfortable speed.

**Independent Test**: Can be tested by entering Speed Ladder, answering correctly 5 times, and verifying speed increased.

**Acceptance Scenarios**:

1. **Given** I am in Speed Ladder mode at 15 WPM, **When** I correctly identify 5 words in a row, **Then** the next word plays at 16 WPM.
2. **Given** I am at 20 WPM in Speed Ladder mode, **When** I fail 2 words in a row, **Then** the next word plays at 19 WPM.
3. **Given** I complete a Speed Ladder session, **When** I view my stats, **Then** I see my "speed ceiling" for each practiced word, **And** the ceiling updates if a higher speed was achieved.
4. **Given** my speed drops below the mode's minimum (e.g., 10 WPM), **When** a decrease would occur, **Then** the speed holds at the minimum, **And** the session continues.

---

### Edge Cases

- What happens if a Speed Ladder session starts at the maximum speed (40 WPM)? The speed holds at the maximum; the goal shifts to maintaining accuracy at ceiling.
- What happens if the learner fails after 4 correct streak? The consecutive correct counter resets to 0; speed does not change.
- What happens if the learner answers correctly after a failure? The consecutive failure counter resets to 0; speed does not change.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide Adaptive Speed Ladder mode that starts at a comfortable base speed.
- **FR-002**: In Speed Ladder mode, the system MUST increase speed by 1 WPM after 5 consecutive correct responses.
- **FR-003**: In Speed Ladder mode, the system MUST decrease speed by 1 WPM after 2 consecutive failures.
- **FR-004**: The system MUST enforce a minimum speed floor (default 10 WPM) that cannot be crossed downward.
- **FR-005**: The system MUST enforce a maximum speed ceiling (default 40 WPM) that cannot be crossed upward.
- **FR-006**: The system MUST track a per-word "speed ceiling" that records the highest WPM at which the word was correctly recognized.
- **FR-007**: The system MUST display current WPM, streak count, and speed ceiling during the session.
- **FR-008**: The system MUST base the starting speed on the learner's current Farnsworth effective speed setting.

### Key Entities

- **SpeedLadderSession**: A session with dynamically adjusting speed. Key attributes: baseWpm, currentWpm, consecutiveCorrect, consecutiveFail, wordQueue.
- **SpeedCeilingRecord**: Per-word speed tracking. Key attributes: wordText, highestWpmAchieved, totalAttemptsAtCeiling.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Speed Ladder users increase their average comfortable speed by ≥ 3 WPM after 10 sessions.
- **SC-002**: 80% of Speed Ladder sessions end at a speed equal to or higher than the session start speed.
- **SC-003**: Per-word speed ceiling data persists across sessions and is visible on the progress screen.

## Assumptions

- The app already has a working Morse audio playback service with adjustable WPM.
- The existing keyboard keyer handler can be reused for word verification in Speed Ladder mode.
- Speed Ladder base speed defaults to the learner's current Farnsworth effective speed setting.
- This mode depends on the Graduated Progression system (spec 014) for unlock gating.
