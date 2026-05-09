# Feature Specification: Audio Feedback for Test Results in Morse Code

**Feature Branch**: `010-morse-test-reporter`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "Feature: Audio Feedback for Test Results in Morse Code. As a developer learning Morse code, I want my test runner to announce pass/fail in Morse audio so that I can practice recognizing common words and numbers auditorily while coding."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Suite Completes with Failures (Priority: P1)

After the full test suite finishes with some failures, the reporter plays a Morse audio summary: the word "DONE", the word "BAD", and the exact failure count as true Morse numbers.

**Why this priority**: This is the core behavior — announcing results in Morse audio is the primary value of the feature.

**Independent Test**: Can be tested by running a suite with known failures and verifying the Morse audio sequence matches "DONE", "BAD", and the failure count as true Morse numbers.

**Acceptance Scenarios**:

1. **Given** the entire suite finishes and 3 tests failed, **Then** the word "DONE" plays in Morse, **And** then the word "BAD" plays in Morse, **And** then the number 3 plays as true Morse number (not spelled "THREE"), **And** there is a 3-dash gap (9 dits) between each element.

2. **Given** the entire suite finishes and 42 tests failed, **Then** the word "DONE" plays in Morse, **And** then the word "BAD" plays in Morse, **And** then the number 42 plays as true Morse numbers (each digit in 5-element prosign form), **And** there is a 3-dash gap (9 dits) between each element.

---

### User Story 2 — Suite Completes with All Passes (Priority: P1)

After the full test suite finishes with zero failures, the reporter plays a Morse audio summary indicating success.

**Why this priority**: The feature must handle both pass and fail outcomes; announcing success is equally important for auditory practice.

**Independent Test**: Can be tested by running a suite with all tests passing and verifying the Morse audio sequence matches "DONE", "GOOD", and the pass count as true Morse numbers.

**Acceptance Scenarios**:

1. **Given** the entire suite finishes and all tests passed, **Then** the word "DONE" plays in Morse, **And** then the word "GOOD" plays in Morse, **And** then the pass count plays as true Morse numbers, **And** there is a 3-dash gap (9 dits) between each element.

---

### User Story 3 — Numbers Play as True Morse, Never Spelled Words (Priority: P1)

All numeric output uses true International Morse number prosigns (5-element patterns). Numbers are never spelled out as words.

**Why this priority**: This is a hard constraint of the feature — spelled-out numbers would defeat the purpose of practicing number recognition in Morse.

**Independent Test**: Can be tested by asserting that numeric output never contains letter patterns that would spell a number word (e.g., "THREE", "FORTY", "TWO").

**Acceptance Scenarios**:

1. **Given** a test result contains the number 3, **When** the reporter plays the count, **Then** the audio plays the prosign pattern for 3 (five elements), **And** the pattern for the spelled word "THREE" is never used.

2. **Given** a test result contains the number 42, **When** the reporter plays the count, **Then** the audio plays the prosign for 4 followed by the prosign for 2, **And** the spelled words "FOUR" and "TWO" are never used.

---

### Edge Cases

- What happens when the failure count is 0? The "BAD" word is skipped; only "DONE" and "GOOD" with the pass count play.
- What happens when the pass count is 0? The "GOOD" word is skipped; only "DONE" and "BAD" with the failure count play.
- What happens when both pass and fail counts are 0? Only "DONE" plays.
- What happens with very large counts (e.g., 1000+ tests)? Each digit plays as its own prosign; there is no upper limit on digit count.
- What happens if the audio device is unavailable? The reporter silently skips audio output and logs the failure without blocking the test run.
- What happens if a single test fails in a suite of hundreds? The reporter still plays the exact failure count accurately.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST play a Morse audio announcement when the test suite finishes.
- **FR-002**: The announcement MUST begin with the word "DONE" in standard International Morse.
- **FR-003**: If any tests failed, the announcement MUST include the word "BAD" in standard International Morse after "DONE".
- **FR-004**: If all tests passed, the announcement MUST include the word "GOOD" in standard International Morse after "DONE".
- **FR-005**: The announcement MUST include the relevant numeric count (failed count if failures exist, passed count if all passed) as true Morse number prosigns.
- **FR-006**: Numbers MUST be encoded using 5-element International Morse prosign patterns (0–9), NOT spelled out as words.
- **FR-007**: Each element in the announcement (word or number) MUST be separated by a 3-dash gap (9 dits).
- **FR-008**: Multi-digit numbers MUST be played as a sequence of individual digit prosigns with standard inter-digit spacing (3 dits).
- **FR-009**: If audio playback is unavailable, the reporter MUST silently skip audio and allow the test run to complete normally.
- **FR-010**: Letters in the announcement MUST use standard International Morse code.

### Key Entities

- **MorseReporter**: The component that translates test results into Morse audio sequences. Key attributes: result source, audio output channel, Morse mapping tables.
- **TestResult**: The outcome of a test suite run. Key attributes: passed count, failed count, total count.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users hear a complete Morse audio announcement within 2 seconds of the test suite finishing.
- **SC-002**: 100% of numeric output in announcements uses true Morse prosigns; 0% uses spelled-out words.
- **SC-003**: Announcements for suites with up to 4-digit counts remain under 15 seconds in total audio duration.
- **SC-004**: Users correctly identify the pass/fail outcome from the Morse audio alone in ≥ 85% of trials after 2 weeks of use.
- **SC-005**: Audio playback failures do not block or delay test suite completion; suite exits within 100 ms of normal runtime.

## Assumptions

- The test runner provides a hook or event fired when the entire suite finishes.
- An audio synthesis or playback service is available that can play sequences of Morse patterns with configurable gaps.
- Standard International Morse code is used for all letters and numbers.
- The feature is optional and can be enabled or disabled by the user without affecting test execution.
- The announcement language is English; words like "DONE", "BAD", and "GOOD" are fixed.
