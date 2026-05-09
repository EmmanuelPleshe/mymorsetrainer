# Feature Specification: Common Words Practice — Holistic Word Sound Recognition

**Feature Branch**: `007-common-words-practice`  
**Created**: 2026-05-08  
**Status**: Draft  
**Unlock Level**: 2 — Requires Koch Letters mastery (Level 1).
**Input**: User description: "Feature: Common Words Practice — Holistic Word Sound Recognition. As a learner, I want to hear complete words as single flowing Morse patterns so that I internalize words by their overall rhythm, not letter-by-letter decoding."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Unified Word Playback (Priority: P1)

A learner enters Common Words practice mode and hears each word as a single flowing Morse audio unit, with no letters shown on screen. The goal is to train the brain to recognize the *rhythm* of a word, not decode it letter-by-letter.

**Why this priority**: This is the core behavior of the feature — without holistic playback, the feature cannot deliver its primary value of building pattern recognition.

**Independent Test**: Can be tested by starting a word practice session, verifying audio plays as one continuous unit, and confirming no text appears during playback.

**Acceptance Scenarios**:

1. **Given** I am in Common Words practice mode, **When** a new word session starts, **Then** the word's complete Morse pattern plays as one continuous audio unit with inter-letter gaps of exactly 3 dits (tight, flowing), **And** NO letters appear on screen during playback, **And** NO per-letter highlighting occurs, **And** the screen shows only a "Listen..." pulse indicator.

---

### User Story 2 — Forgiving Tap-Back Input (Priority: P1)

After hearing a word, the learner taps the Morse keyboard to reproduce the *entire* word pattern. The input handler is forgiving about pause lengths within reasonable bounds, so the learner can focus on accuracy of dot/dash sequence rather than strict timing between letters.

**Why this priority**: Holistic recognition requires reproducing entire word patterns. Without forgiving timing, learners would be penalized for natural pauses between letters, discouraging whole-word practice.

**Independent Test**: Can be tested by tapping a word pattern with pauses up to the inter-letter threshold, submitting, and verifying the pattern matches regardless of internal pause lengths.

**Acceptance Scenarios**:

1. **Given** the word audio has finished, **When** I tap the word using the Morse keyboard, **Then** the app accepts pauses up to 3 dits between letters without breaking the word, **And** pauses up to 3 dashes (9 dits) are accepted as a word boundary, **And** the app does NOT show live letter-by-letter decoding as I tap, **And** the app shows only a raw tap accumulation indicator (e.g., "● ●●● ●").

2. **Given** I have keyed a pattern, **When** I pause longer than the inter-word threshold (3 dashes / 9 dits) or tap an explicit Submit button, **Then** my complete tapped sequence is compared holistically against the target, **And** timing forgiveness is applied: sequences match if dit/dah pattern is correct, regardless of intra-letter or inter-letter pause lengths within thresholds.

---

### User Story 3 — Feedback and Smart Repetition (Priority: P2)

After submission, the learner receives clear success/failure feedback with visual text and audio reinforcement. The Smart Repetition Engine tracks Word Familiarity Scores to optimize which words appear next and when scaffolding is needed.

**Why this priority**: Feedback and spaced repetition are essential for retention, but the session can function without them in a minimal implementation.

**Independent Test**: Can be tested by submitting correct and incorrect answers and verifying feedback audio, text display, and familiarity score changes.

**Acceptance Scenarios**:

1. **Given** my submitted sequence matches the target word's Morse pattern, **When** success is determined, **Then** the word appears in large plain text, **And** the word's Morse audio plays once more at 80% speed for reinforcement, **And** the Smart Repetition Engine records SUCCESS, **And** the Word Familiarity Score for this word increases, **And** after a 2-second pause, the next word starts.

2. **Given** my submitted sequence does not match, **When** failure is determined, **Then** the correct word appears in plain text, **And** the word's Morse audio plays once more at normal speed, **And** the Smart Repetition Engine records FAILURE, **And** the Word Familiarity Score decreases or resets partially, **And** the word is requeued by the Smart Repetition Engine, **And** the next word starts immediately after the replay.

---

### User Story 4 — Adaptive Scaffolding (Priority: P2)

New or struggling words (low Familiarity Score) receive visual scaffolding to aid learning. Well-known words (high Familiarity Score) are presented as pure audio challenges with no visual preview.

**Why this priority**: Adaptive scaffolding personalizes the learning experience, but the core word practice works without it.

**Independent Test**: Can be tested by simulating different familiarity scores and verifying whether text appears before audio playback.

**Acceptance Scenarios**:

1. **Given** a word has Familiarity Score < 20% (new / struggling), **When** the word is presented, **Then** the word text appears for 2 seconds before audio plays, **And** the text disappears, **And** then the audio plays.

2. **Given** a word has Familiarity Score ≥ 60%, **When** the word is presented, **Then** the word text is NEVER shown before audio, **And** I must recognize the pattern purely by sound.

---

### Edge Cases

- What happens when the user pauses for exactly the inter-word threshold? The boundary is treated as a word boundary; the current pattern is submitted.
- What happens if the user taps during audio playback? Input is blocked until playback finishes.
- What happens if the user submits an empty pattern? Treated as incorrect; the word is shown and replayed.
- What happens for words with Familiarity Score between 20% and 60%? No pre-audio text is shown; word is treated as partially known.
- What happens if the user exits mid-session? Session results up to that point are saved to the Smart Repetition Engine.
- What happens if the device receives a phone call or notification during audio playback? Audio pauses gracefully and resumes or restarts based on user action.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST play complete word Morse patterns as a single continuous audio unit with inter-letter gaps of exactly 3 dits.
- **FR-002**: The system MUST NOT display letters, per-letter highlighting, or letter-by-letter decoding on screen during audio playback.
- **FR-003**: The system MUST display a "Listen..." pulse indicator during playback.
- **FR-004**: The system MUST tolerate pauses up to 3 dits between letters within a word during user Morse keyboard keying, and MUST accept pauses up to 3 dashes (9 dits) as a word boundary. Audio playback continues to use precise 3-dit inter-letter spacing.
- **FR-005**: The system MUST compare submitted tap sequences holistically against the target word's Morse pattern based on dit/dah sequence correctness, not timing exactitude.
- **FR-006**: The system MUST provide an explicit Submit button as an alternative to auto-submitting on long pauses.
- **FR-007**: The system MUST display only a raw tap accumulation indicator (e.g., "● ●●● ●") while the user is keying, with no live letter decoding.
- **FR-008**: On correct submission, the system MUST display the word in large plain text, replay the audio at 80% speed, increase the Word Familiarity Score, and advance to the next word after a 2-second pause.
- **FR-009**: On incorrect submission, the system MUST display the correct word in plain text, replay the audio at normal speed, decrease or partially reset the Word Familiarity Score, requeue the word, and advance immediately after replay.
- **FR-010**: The Smart Repetition Engine MUST track a per-word Familiarity Score (0–100%) and use it to determine word presentation order and scaffolding level.
- **FR-011**: For words with Familiarity Score < 20%, the system MUST show the word text for 2 seconds before playing audio.
- **FR-012**: For words with Familiarity Score ≥ 60%, the system MUST NOT show text before audio.
- **FR-013**: The system MUST manage a set of at least 100 common words within the Smart Repetition Engine.
- **FR-014**: The system MUST gate Common Words practice behind Level 2; learners below Level 2 see the mode grayed out with "Unlock at Level 2".

### Key Entities

- **Word**: Represents a target word with text, Morse pattern, category, and difficulty. Key attributes: text, morseCode, category, difficulty.
- **WordFamiliarity**: Per-word learning state tracked by the Smart Repetition Engine. Key attributes: wordText, familiarityScore (0–100%), totalAttempts, correctCount, lastReviewed, nextReviewDue.
- **WordSession**: An active practice session containing a pre-generated queue of words, current index, session results, and the current playback/input phase. Key attributes: wordQueue, currentIndex, sessionResults, phase (listening | tapping | feedback).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Learners can complete a 20-word Common Words session in under 5 minutes.
- **SC-002**: Word audio playback is perceived as a single flowing unit; inter-letter gaps are indistinguishable from intra-character gaps during playback.
- **SC-003**: 90% of tapped word patterns submitted within timing thresholds are accepted as correct when the dit/dah sequence matches the target, regardless of internal pause variation.
- **SC-004**: After 5 sessions, average Word Familiarity Score for practiced words increases by at least 20 percentage points.
- **SC-005**: Learners with words at Familiarity Score ≥ 60% achieve ≥ 80% accuracy on pure audio challenges (no text preview).

## Assumptions

- The app already has an existing Morse audio playback service capable of generating timed tones.
- The existing keyboard keyer handler can be adapted to support word-level input with forgiving timing thresholds.
- A curated list of 100 common English words already exists or will be sourced for initial content.
- Word Familiarity Scoring is separate from the existing character-level SM-2 spaced repetition system; the two systems may share storage but track different metrics.
- The current Word Practice screen will be enhanced or a new screen added; the feature does not replace existing character practice.
- Mobile device audio latency is acceptable for Morse timing at standard WPM ranges (10–20 WPM).
