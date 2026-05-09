# Feature Specification: Unified Familiarity Score and SRS Engine

**Feature Branch**: `020-unified-familiarity-score`
**Created**: 2026-05-09
**Status**: Draft
**Input**: User description: "Write a single shared FamiliarityScore spec that 007, 011, and 014–019 all reference."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Universal Familiarity Tracking (Priority: P1)

A learner practices in any mode (Common Words, QSO Fragments, Callsign Copy, Head-Copy, Echo Mode, etc.). The app tracks how well they know each item using one consistent scoring system regardless of mode. A word practiced in Common Words and the same word encountered in Head-Copy share the same underlying familiarity record.

**Why this priority**: Without unified tracking, the app fragments learning state across modes. A learner who masters "HELLO" in Common Words starts from zero in Head-Copy. Unified tracking respects the learner's actual knowledge.

**Independent Test**: Can be tested by completing a Common Words session, then entering Head-Copy mode, and verifying the same word's familiarity score carries over.

**Acceptance Scenarios**:

1. **Given** a learner achieves 80% familiarity on the word "HELLO" in Common Words practice, **When** the same word appears in Head-Copy mode, **Then** the familiarity score is 80%, **And** the word is treated as partially known (no text preview shown).
2. **Given** a learner has never practiced callsign "W1AW", **When** it appears in Callsign Copy mode, **Then** the familiarity score is 0%, **And** a prefix hint is shown before audio.
3. **Given** a QSO fragment has been practiced in QSO Fragment mode, **When** the same fragment appears in Contest Mode, **Then** the familiarity score is shared, **And** the fragment is scheduled for review based on combined practice history.

---

### User Story 2 — Keyboard-Verified vs Self-Assessed Results (Priority: P1)

In modes with keyboard input (Common Words, QSO Fragments, Callsign Copy, Echo Mode), correctness is objectively verified. In Head-Copy mode, the learner self-assesses with "I got it" / "Missed it." The system weights keyboard-verified results higher than self-assessed results when updating familiarity scores.

**Why this priority**: Self-assessment is unreliable. Learners often think they copied correctly when they did not. Keyboard-verified results are ground truth. Both feed the same familiarity record but with different confidence weights.

**Independent Test**: Can be tested by answering "I got it" after a Head-Copy word, then seeing the same word in Common Words mode, and verifying the score increase from self-assessment is smaller than a keyboard-verified correct answer.

**Acceptance Scenarios**:

1. **Given** a learner taps "I got it" after a Head-Copy word, **When** the familiarity score updates, **Then** the increase is +3 points (self-assessed weight).
2. **Given** a learner keys the same word correctly in Common Words mode, **When** the familiarity score updates, **Then** the increase is +10 points (keyboard-verified weight).
3. **Given** a learner has a familiarity score of 50%, **When** they fail a keyboard-verified attempt, **Then** the score decreases by 15 points, **And** the item is requeued for near-term review.

---

### User Story 3 — Smart Scheduling and Adaptive Scaffolding (Priority: P2)

The system uses the familiarity score to decide when to show scaffolding (text preview, hints) and when to schedule the next review. Low scores trigger previews and short intervals. High scores suppress previews and extend intervals.

**Why this priority**: This is the pedagogical engine that makes the app adaptive. Without it, every item is treated identically regardless of the learner's actual knowledge.

**Independent Test**: Can be tested by simulating different familiarity scores and verifying that review intervals and scaffolding behavior match the score thresholds.

**Acceptance Scenarios**:

1. **Given** an item has familiarity score < 20%, **When** it is presented in any practice mode, **Then** scaffolding (text preview or pattern hint) is shown for 2 seconds before audio plays.
2. **Given** an item has familiarity score ≥ 60%, **When** it is presented, **Then** no scaffolding is shown, **And** the item must be recognized purely by sound.
3. **Given** an item has familiarity score between 20% and 60%, **When** it is presented, **Then** no scaffolding is shown, **And** the item is treated as partially known.
4. **Given** an item reaches 80% familiarity after a correct answer, **When** the next review is scheduled, **Then** the interval is 7 days.
5. **Given** an item drops to 40% familiarity after a wrong answer, **When** the next review is scheduled, **Then** the interval is 1 day.

---

### User Story 4 — Global Proficiency Level (Priority: P2)

The learner has a global proficiency level (1–10) calculated from weighted performance across all unlocked modes. This level gates access to advanced modes and tracks overall progression.

**Why this priority**: Provides a sense of progression and prevents learners from skipping foundational skills. Separable from per-item familiarity tracking.

**Independent Test**: Can be tested by completing sessions in multiple modes and verifying the global level increases according to the weighted formula.

**Acceptance Scenarios**:

1. **Given** a learner has 90% accuracy in Koch Letters at 15 WPM, **When** the proficiency formula is calculated, **Then** the weighted score contributes toward Level 2.
2. **Given** a learner crosses a level threshold, **When** a session completes, **Then** a "Level Up!" animation plays, **And** the new level's modes are unlocked.
3. **Given** a learner performs poorly in a session, **When** the proficiency is recalculated, **Then** the proficiency score never decreases (monotonic), **And** advancement is simply delayed.

---

### Edge Cases

- What happens when the same item is practiced in two modes on the same day? The familiarity score updates cumulatively. The review interval is recalculated after each update.
- What happens if a learner self-assesses "I got it" but the score is already 95%? The score caps at 100%. Self-assessed increments are small enough that they do not cause frequent capping.
- What happens if an item has never been seen? Familiarity score is 0%, next review is due immediately.
- What happens if the learner deletes app data? All familiarity scores and proficiency progress are reset.
- What happens if a QSO fragment contains a callsign the learner knows well? The QSO fragment's familiarity is independent; knowing a callsign does not automatically boost the containing fragment's score.
- What happens if the proficiency formula produces a score above 100? Capped at 100. Level 10 is maximum.
- What happens if a mode has zero sessions? It contributes zero to the proficiency numerator and denominator.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST track a single `FamiliarityScore` entity for every learnable item, regardless of which practice mode encounters it.
- **FR-002**: The `FamiliarityScore` entity MUST support these `itemType` values: `word`, `qso_fragment`, `callsign`, `prosign_phrase`.
- **FR-003**: The `FamiliarityScore` entity MUST support these `assessmentMode` values: `keyboard_verified`, `self_assessed`.
- **FR-004**: The system MUST apply a higher score delta for `keyboard_verified` results than for `self_assessed` results.
- **FR-005**: The system MUST cap the familiarity score at 0% minimum and 100% maximum.
- **FR-006**: The system MUST schedule the next review using a unified SRS algorithm based on the current familiarity score and result correctness.
- **FR-007**: The SRS algorithm MUST use these base intervals: new/incorrect → 1 day, 20–39% → 2 days, 40–59% → 4 days, 60–79% → 7 days, 80–100% → 14 days.
- **FR-008**: For incorrect answers, the system MUST halve the scheduled interval (minimum 1 day) and reduce the familiarity score.
- **FR-009**: The system MUST show scaffolding (text preview or pattern hint) for 2 seconds before audio when familiarity score < 20%.
- **FR-010**: The system MUST NOT show scaffolding when familiarity score ≥ 60%.
- **FR-011**: The system MUST track a global `ProficiencyProfile` with level (1–10) and a monotonic proficiency score (0–100).
- **FR-012**: The proficiency formula MUST be: proficiency = Σ(mode_best_accuracy × mode_weight × speed_multiplier) / Σ(mode_weight).
- **FR-013**: Mode weights MUST be: Koch Letters = 3.0, Common Words = 2.5, Head-Copy = 2.0, QSO Fragments = 2.0, Callsign Copy = 2.0, Echo Mode = 1.5, Prosigns = 1.5, Contest = 1.0, Speed Ladder = 2.0.
- **FR-014**: The speed_multiplier MUST be 1.0 at base speed, increasing by 0.1 per WPM above base, capped at 2.0x for speeds ≥ 25 WPM.
- **FR-015**: Level thresholds MUST be: Level 1 (0–19), Level 2 (20–29), Level 3 (30–39), Level 4 (40–49), Level 5 (50–59), Level 6 (60–69), Level 7 (70–79), Level 8 (80–89), Level 9 (90–99), Level 10 (100+).
- **FR-016**: The system MUST lock modes that require a proficiency level higher than the learner currently has.
- **FR-017**: The system MUST display locked modes as grayed out with "Unlock at Level X" labels.
- **FR-018**: Proficiency scores MUST be monotonic; they never decrease due to poor performance.
- **FR-019**: The system MUST track per-mode performance metrics: `bestAccuracy`, `bestSpeedWpm`, `totalSessions`, `speedCeiling`.
- **FR-020**: All specs referencing familiarity tracking (007, 011, 014–019) MUST reference this unified spec instead of defining their own entities.

### Key Entities

- **FamiliarityScore**: Per-item learning state shared across all practice modes. Key attributes: `itemId`, `itemType` (word | qso_fragment | callsign | prosign_phrase), `familiarityScore` (0–100%), `totalAttempts`, `correctCount`, `lastReviewed`, `nextReviewDue`, `keyboardVerifiedAttempts`, `selfAssessedAttempts`.
- **ProficiencyProfile**: Global learner progression. Key attributes: `level` (1–10), `proficiencyScore` (0–100), `unlockedModes`, `advancementCriteriaMet`.
- **ModePerformance**: Per-mode statistics used in proficiency calculation. Key attributes: `modeName`, `bestAccuracy`, `bestSpeedWpm`, `totalSessions`, `speedCeiling`.
- **SrsEngine**: Service that records practice results and schedules reviews. Key operations: `recordResult(item, correct, assessmentMode)`, `getNextReviewDate(item)`, `getScaffoldingLevel(score)`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After practicing an item in any mode, the same item encountered in a different mode shares the familiarity score within 1% tolerance.
- **SC-002**: Keyboard-verified correct answers increase familiarity score by at least 3× the amount of self-assessed "I got it" answers.
- **SC-003**: Learners with items at familiarity score ≥ 60% achieve ≥ 80% accuracy on pure audio challenges (no scaffolding).
- **SC-004**: After 5 sessions, average familiarity score for practiced items increases by at least 20 percentage points.
- **SC-005**: The SRS scheduling engine presents due items within 24 hours of their scheduled review date.
- **SC-006**: 90% of learners report the progression system "guides my learning without overwhelming me" in qualitative feedback.
- **SC-007**: Learners advance from Level 1 to Level 2 within 3 days of regular practice (15 min/day).
- **SC-008**: No learner reports being stuck at a level for more than 2 weeks due to advancement criteria being unreachable.

## Assumptions

- All practice modes can identify a unique `itemId` for every learnable item.
- Self-assessment is optional in Head-Copy mode; when disabled, no familiarity updates occur.
- The existing character-level SM-2 system in 001 is deprecated in favor of this unified engine; character familiarity migrates to the new schema.
- Speed ceiling tracking is stored in `ModePerformance`, not `FamiliarityScore`.
- The SRS engine is a single service interface consumed by all practice mode UIs.
- Proficiency calculation runs after every completed session in an unlocked mode.
- Mobile device storage is sufficient for SQLite tables holding familiarity and proficiency data.
