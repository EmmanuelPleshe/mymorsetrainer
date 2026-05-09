# Feature Specification: Freeform Decoder Mode with Generous Timing

**Feature Branch**: `008-freeform-decoder`  
**Created**: 2026-05-08  
**Status**: Draft  
**Unlock Level**: 1 — Always available from first launch.
**Input**: User description: "Feature: Freeform Decoder Mode with Generous Timing. As a user, I want to tap Morse freely and see it decoded live, without stress about speed, so that I can practice encoding at my own pace."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Live Decoding with Forgiving Pauses (Priority: P1)

A user enters Decoder mode and taps Morse code freely. The app decodes each letter in real time as the user keys, displaying the resulting text in a text field. Pauses between letters are generous, so learners are not penalized for natural hesitation.

**Why this priority**: This is the core behavior of the feature — without live decoding and forgiving timing, the mode cannot serve its purpose as a low-pressure practice environment.

**Independent Test**: Can be tested by tapping the Morse pattern for "HELLO" with pauses up to the inter-letter threshold and verifying the text field shows "HELLO".

**Acceptance Scenarios**:

1. **Given** I am in Decoder mode, **When** I tap Morse for "HELLO" and pause up to 3 dits between letters, **Then** each letter is decoded and appears in the text field, **And** the text field shows "HELLO".

2. **Given** I tap the Morse for "SOS" and pause 2.5 dits between each letter (slow but within threshold), **Then** the decoder still recognizes "SOS", **And** no timeout or error occurs.

---

### User Story 2 — Word Boundaries via Longer Pauses (Priority: P2)

After keying a word, the user pauses longer to indicate a word boundary. The decoder inserts a space in the text field, allowing multi-word messages to be composed.

**Why this priority**: Word boundaries are essential for composing meaningful text, but the decoder functions for single words without them.

**Independent Test**: Can be tested by tapping "HELLO", pausing longer than the inter-word threshold, then tapping "WORLD", and verifying the text shows "HELLO WORLD".

**Acceptance Scenarios**:

1. **Given** I tap "HELLO" and pause 4 dashes (12 dits) between "HELLO" and "WORLD", **Then** the text field shows "HELLO WORLD", **And** the longer pause is interpreted as a word space.

---

### User Story 3 — Clear and Reset (Priority: P2)

The user can clear all keyed input and start fresh without leaving Decoder mode.

**Why this priority**: A clear/reset action is important for usability, but the decoder works without it.

**Independent Test**: Can be tested by tapping some Morse, pressing Cancel, and verifying the text field is empty and the decoder is ready for new input.

**Acceptance Scenarios**:

1. **Given** I have tapped some Morse code, **When** I press Cancel, **Then** the text field is cleared, **And** all timing buffers are reset, **And** I remain in Decoder mode.

---

### Edge Cases

- What happens when the user pauses for exactly the inter-letter threshold (3 dits)? The letter is finalized and decoding occurs.
- What happens when the user pauses for exactly the inter-word threshold (3 dashes / 9 dits)? A space is inserted in the text field.
- What happens if the user taps an unmapped pattern? A placeholder character (e.g., "?" or Unicode replacement) appears, or the pattern is silently ignored until a valid letter emerges.
- What happens if the user pauses mid-letter (e.g., releases the key and waits too long during a dash)? The partial input is treated as a completed symbol (dot or dash based on duration) and the letter is finalized.
- What happens if the user switches apps or receives a notification mid-tap? The decoder state is preserved; tapping resumes where it left off.
- What happens if the text field overflows? The field scrolls horizontally or vertically; the decoder continues to append characters.
- What happens on device rotation? The decoder state and text field content are preserved.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a Decoder mode accessible from the app's main navigation.
- **FR-002**: In Decoder mode, the system MUST accept Morse input via the same keyboard/touch keyer used in practice modes.
- **FR-003**: The system MUST decode tapped Morse patterns into letters in real time as the user keys.
- **FR-004**: The system MUST auto-finalize a letter after 3 dits of silence following the last symbol.
- **FR-005**: The system MUST auto-finalize a word (insert a space) after 3 dashes (9 dits) of silence following the last letter.
- **FR-006**: The system MUST display decoded text in a visible text field that updates live as each letter is finalized.
- **FR-007**: The system MUST NOT reject or penalize pauses up to the inter-letter or inter-word thresholds.
- **FR-008**: The system MUST provide a Cancel action that clears the text field and resets all decoder timing buffers without exiting Decoder mode.
- **FR-009**: The system MUST handle unmapped Morse patterns gracefully, displaying a visible indicator that the pattern does not match any known character.
- **FR-010**: The system MUST preserve decoder state across brief interruptions (app backgrounding, notifications) and resume seamlessly.
- **FR-011**: The system MUST keep Decoder mode unlocked at all levels; it MUST NOT be gated by progression.

### Key Entities

- **DecoderSession**: Represents the active state of a freeform decoding session. Key attributes: accumulatedText, currentSymbolBuffer, lastKeyUpTime, phase (idle | keying | awaitingLetter | awaitingWord).
- **DecoderState**: Per-session runtime state tracking the current letter being keyed and timing buffers. Key attributes: currentPattern, lastEventTimestamp, pendingSpace.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can tap any message of up to 20 words in Decoder mode without receiving a timing error or rejection.
- **SC-002**: 95% of Morse messages tapped with pauses within the inter-letter threshold are decoded correctly into plain text.
- **SC-003**: Decoder output appears in the text field within 300 ms of the inter-letter threshold being reached.
- **SC-004**: Users report the mode feels "stress-free" or "relaxed" in qualitative feedback, with ≥ 80% positive sentiment about pacing.
- **SC-005**: A new learner can successfully decode their first 5-letter word within 3 minutes of entering Decoder mode for the first time.

## Assumptions

- The app already has a working Morse keyer input handler that reports key-down and key-up events with timing data.
- The existing Morse code lookup table covers all standard letters, numbers, and common punctuation.
- The decoder does not require audio feedback; it is a silent text-generation tool.
- The text field supports multi-line or horizontal scrolling for longer messages.
- The Cancel action is a prominent on-screen button, not a hardware key mapping.
