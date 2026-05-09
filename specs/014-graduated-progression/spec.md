# Feature Specification: Graduated Progression System

**Feature Branch**: `014-graduated-progression`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "Graduated mode unlocking with proficiency score calculation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Graduated Progression System (Priority: P1)

A learner starts at Level 1 with only basic Koch letter practice unlocked. As they demonstrate mastery in unlocked modes, new training modes unlock progressively. The home screen shows locked modes as grayed out with "Unlock at Level X". When a level-up occurs, a celebratory animation plays and the new mode preview appears.

**Why this priority**: This is the foundational framework that enables all other advanced modes. Without the progression system, users are overwhelmed with too many choices and skip foundational skills.

**Independent Test**: Can be tested by completing the Level 1 advancement criteria and verifying Level 2 unlocks correctly.

**Acceptance Scenarios**:

1. **Given** a new learner starts the app, **When** they view the home screen, **Then** only Level 1 modes are active (Koch Letters), **And** higher-level modes are visible but grayed out with "Unlock at Level X" labels.
2. **Given** a learner at Level 1 achieves 90% accuracy on the 2-character Koch set, **When** the session completes, **Then** a "Level Up!" animation plays, **And** Level 2 modes become unlocked, **And** a tutorial overlay previews the new mode.
3. **Given** the app calculates proficiency, **When** the score crosses a level threshold, **Then** the learner advances exactly one level, **And** progress bar resets for the next level's requirements.
4. **Given** a learner has reached Level 5, **When** they view their profile, **Then** they see their current proficiency score, level, and a checklist of remaining advancement criteria for the next level.

---

### Edge Cases

- What happens if a learner attempts to enter a locked mode? The app shows the mode grayed out; tapping it displays "Unlock at Level X" with the specific criteria needed.
- What happens if proficiency drops due to poor performance? Proficiency never decreases; levels are monotonic. Poor performance simply delays advancement.
- What happens if a learner's calculated proficiency exceeds 100? The score caps at 100; Level 10 is the maximum.
- What happens if multiple modes unlock at once (e.g., level jump from a very high score)? Levels advance one at a time; the learner sees sequential level-up animations.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST track a global Proficiency Level from 1 to 10 based on a weighted proficiency score.
- **FR-002**: The system MUST calculate proficiency using the formula: proficiency = Σ(mode_accuracy × mode_weight × speed_multiplier) / Σ(mode_weight).
- **FR-003**: The system MUST assign mode weights: Koch Letters = 3.0, Head-Copy = 2.5, Speed Ladder = 2.0, Contest = 1.0, Echo = 1.5, Prosigns = 1.5, QSO Fragments = 2.0, Callsign Copy = 2.0, Decoder = 1.5.
- **FR-004**: The system MUST calculate speed_multiplier as 1.0 at base speed, increasing by 0.1 per WPM above base, capped at 2.0x for speeds ≥ 25 WPM.
- **FR-005**: The system MUST define level thresholds: Level 1 (0-19), Level 2 (20-29), Level 3 (30-39), Level 4 (40-49), Level 5 (50-59), Level 6 (60-69), Level 7 (70-79), Level 8 (80-89), Level 9 (90-99), Level 10 (100+).
- **FR-006**: The system MUST lock modes that require a higher proficiency level than the learner currently has.
- **FR-007**: The system MUST display locked modes on the home screen as grayed out with "Unlock at Level X" labels.
- **FR-008**: The system MUST play a "Level Up!" animation and show a tutorial overlay when advancement criteria are met.
- **FR-031**: The system MUST check advancement criteria after every completed session in an unlocked mode.
- **FR-032**: The system MUST require all previous level criteria to be met before advancing to the next level.
- **FR-033**: Proficiency scores MUST be monotonic; they never decrease due to poor performance.

### Key Entities

- **ProficiencyProfile**: Tracks the learner's global level and score. Key attributes: level (1-10), proficiencyScore, unlockedModes, advancementCriteriaMet.
- **ModePerformance**: Per-mode accuracy and speed tracking. Key attributes: modeName, bestAccuracy, bestSpeedWpm, totalSessions, speedCeiling.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Learners advance from Level 1 to Level 2 within 3 days of regular practice (15 min/day).
- **SC-008**: 90% of learners report the progression system "guides my learning without overwhelming me" in qualitative feedback.
- **SC-009**: No learner reports being stuck at a level for more than 2 weeks due to advancement criteria being unreachable.

## Assumptions

- The app already has a working Morse audio playback service with adjustable WPM and Farnsworth timing.
- Proficiency scores are calculated from best-session performance per mode, not cumulative averages.
- The progression system ships alongside existing Koch, Word, and QSO practice; it does not replace them.
- Level 10 is achievable but requires mastery of all modes at 25+ WPM; it is designed as a long-term goal.
- Each new training mode that depends on this progression system will define its own level requirements in its respective spec.
