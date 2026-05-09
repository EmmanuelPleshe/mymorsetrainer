# Feature Specification: Echo Mode

**Feature Branch**: `018-echo-mode`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "Echo Mode — app sends a word, learner keys it back, timing comparison overlay with accuracy score"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Echo Mode (Priority: P1)

A learner enters Echo Mode. The app sends a word as Morse audio. The learner taps the word back using the Morse keyboard. The app compares the sent timing versus the received timing and shows a waveform overlay of target vs. actual.

**Why this priority**: Improves sending precision, not just receiving. Real operators must send with consistent timing to be understood.

**Independent Test**: Can be tested by entering Echo Mode, hearing a word, keying it back, and verifying the timing comparison overlay appears.

**Acceptance Scenarios**:

1. **Given** I am in Echo Mode, **When** the app sends "HELLO" at 20 WPM, **Then** I tap it back using the keyboard.
2. **Given** I have keyed the word back, **When** the comparison completes, **Then** a waveform overlay shows the target timing vs. my actual timing, **And** a timing accuracy score (0-100%) is displayed.
3. **Given** my inter-element spacing is inconsistent, **When** the feedback appears, **Then** the overlay highlights the gaps that were too short or too long, **And** a text tip appears (e.g., "Work on letter gaps").
4. **Given** I achieve ≥ 80% timing accuracy, **When** the feedback appears, **Then** a "Good sending!" message appears, **And** the Echo Mode Familiarity Score increases.

---

### Edge Cases

- What happens if Echo Mode receives no input after the target word? A timeout triggers after the inter-word threshold; the attempt is marked incorrect.
- What happens if the learner keys extra characters? The comparison ignores extra characters beyond the target length but penalizes accuracy.
- What happens if the learner keys fewer characters? Missing characters are counted as errors; the comparison highlights the missing elements.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide Echo Mode where the app sends a word and the learner keys it back.
- **FR-002**: In Echo Mode, the system MUST compare sent timing vs. received timing and display a waveform overlay.
- **FR-003**: In Echo Mode, the system MUST provide a timing accuracy score (0-100%) and text feedback on spacing quality.
- **FR-004**: The system MUST highlight specific timing errors: dots too long, dashes too short, gaps too wide or narrow.
- **FR-005**: The system MUST provide actionable text tips based on the most common timing error in the attempt.
- **FR-006**: The system MUST time out after the inter-word gap threshold if no input is received.
- **FR-007**: The system MUST track an Echo Mode Familiarity Score that increases with high accuracy attempts.
- **FR-008**: The system MUST queue words from the learner's unlocked vocabulary.

### Key Entities

- **EchoResult**: Timing comparison for a single word. Key attributes: targetPattern, actualPattern, timingAccuracyScore, spacingFeedback.
- **EchoSession**: A session of echo practice. Key attributes: wordQueue, currentIndex, totalAccuracy, results.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Echo Mode users achieve ≥ 80% timing accuracy score within 5 sessions.
- **SC-002**: 90% of users who receive spacing feedback report it helps them identify their specific timing weaknesses.
- **SC-003**: Echo Mode Familiarity Score correlates with actual on-air sending readability ratings.

## Assumptions

- The app already has a working Morse audio playback service with adjustable WPM.
- The existing keyboard keyer handler can be reused for Echo Mode input capture.
- Echo Mode waveform overlay is a simplified visual comparison, not a full oscilloscope display.
- This mode depends on the Graduated Progression system (spec 014) for unlock gating.
