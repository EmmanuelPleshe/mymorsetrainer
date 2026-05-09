# Feature Specification: Head-Copy Practice

**Feature Branch**: `015-head-copy-practice`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "Head-Copy practice mode — continuous Morse audio with no input mechanism, optional self-assessment"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Head-Copy Practice (Priority: P1)

A learner enters Head-Copy mode and hears words or short phrases as continuous Morse audio. The screen shows only "Listen...", a "Repeat" button, and a "Next" button. No keyboard, no text field, no tapping mechanism. The learner mentally comprehends the audio. Optionally, they tap "I got it" or "Missed it" for self-assessment, which feeds the smart repetition engine.

**Why this priority**: Head-copy is the actual skill used in real CW QSOs at 20-40 WPM. Writing is too slow. This mode trains the brain to comprehend Morse mentally without physical decoding crutches.

**Independent Test**: Can be tested by entering Head-Copy mode, hearing a word, and verifying the screen has no input mechanism.

**Acceptance Scenarios**:

1. **Given** I am in Head-Copy mode, **When** a word plays, **Then** the screen shows only a "Listen..." pulse indicator, **And** there is NO keyboard, NO text field, and NO tapping area.
2. **Given** a word has finished playing, **When** I tap "Repeat", **Then** the same word plays again at the same speed.
3. **Given** a word has finished playing, **When** I tap "Next", **Then** a new word plays, **And** the session counter advances.
4. **Given** self-assessment is enabled, **When** a word finishes, **Then** "I got it" and "Missed it" buttons appear, **And** my selection updates the Familiarity Score for that word.
5. **Given** self-assessment is disabled, **When** a word finishes, **Then** tapping "Next" immediately advances to the next word, **And** no accuracy tracking occurs for this item.

---

### Edge Cases

- What happens if the learner is in Head-Copy mode and self-assessment is disabled? Session proceeds with "Next" and "Repeat" only; no accuracy data is recorded.
- What happens if a word queue runs out? The session ends gracefully with a summary of words heard.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide Head-Copy mode where words play as audio with NO keyboard, NO text field, and NO tapping mechanism.
- **FR-002**: In Head-Copy mode, the system MUST show "Listen...", "Repeat", and "Next" controls.
- **FR-003**: The system MUST optionally enable self-assessment in Head-Copy mode with "I got it" and "Missed it" buttons after each word.
- **FR-004**: The system MUST feed self-assessed accuracy into the smart repetition engine to schedule review intervals.
- **FR-005**: The system MUST queue words from the learner's unlocked vocabulary based on spaced repetition priority.
- **FR-006**: The system MUST play words continuously without pausing between them unless the learner taps "Repeat" or "Next".

### Key Entities

- **HeadCopySession**: A session with only audio playback and self-assessment. Key attributes: wordQueue, currentIndex, selfAssessmentEnabled, sessionResults.
- **HeadCopyWord**: A word or phrase tracked for head-copy familiarity. Key attributes: wordText, familiarityScore, lastReviewDate, reviewInterval.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Learners who use Head-Copy mode for 2 weeks report ≥ 70% ability to mentally copy common words at 20 WPM without writing.
- **SC-002**: 90% of learners can complete a 10-word Head-Copy session without exiting early.
- **SC-003**: Self-assessment accuracy correlates with actual decoding accuracy within ±10%.

## Assumptions

- The app already has a working Morse audio playback service with adjustable WPM and Farnsworth timing.
- Head-Copy mode requires no new input hardware; it is a passive listening mode.
- The existing spaced repetition engine (SM-2) can be extended to track head-copy familiarity scores.
- This mode depends on the Graduated Progression system (spec 014) for unlock gating.
