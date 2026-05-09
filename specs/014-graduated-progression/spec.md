# Feature Specification: Graduated Progression and Mode Unlocking

**Feature Branch**: `014-graduated-progression`
**Created**: 2026-05-09
**Status**: Draft
**Input**: User description: "Proficiency level tracking and mode unlocking. Split from 012."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Graduated Progression System (Priority: P1)

A learner starts at Level 1 with only basic Koch letter practice and the freeform Decoder unlocked. As they demonstrate mastery in unlocked modes, new training modes unlock progressively. The home screen shows locked modes as grayed out with "Unlock at Level X". When a level-up occurs, a celebratory animation plays and the new mode preview appears.

**Why this priority**: This is the foundational framework that enables all other advanced modes. Without the progression system, users are overwhelmed with too many choices and skip foundational skills.

**Independent Test**: Can be tested by completing the Level 1 advancement criteria and verifying Level 2 unlocks correctly.

**Acceptance Scenarios**:

1. **Given** a new learner starts the app, **When** they view the home screen, **Then** only Level 1 modes are active (Koch Letters, Decoder), **And** higher-level modes are visible but grayed out with "Unlock at Level X" labels.
2. **Given** a learner at Level 1 achieves 90% accuracy on the 2-character Koch set, **When** the session completes, **Then** a "Level Up!" animation plays, **And** Level 2 modes become unlocked, **And** a tutorial overlay previews the new mode.
3. **Given** the app calculates proficiency, **When** the score crosses a level threshold, **Then** the learner advances exactly one level, **And** progress bar resets for the next level's requirements.
4. **Given** a learner has reached Level 5, **When** they view their profile, **Then** they see their current proficiency score, level, and a checklist of remaining advancement criteria for the next level.

---

### User Story 2 — Mode Unlock Visibility (Priority: P1)

Every mode in the app declares its unlock level in its own spec. The progression system reads these declarations and enforces visibility and gating on the home screen. No mode is hard-coded in the progression system; the table is the single source of truth.

**Why this priority**: Centralizing unlock logic in one table prevents drift. When a new mode spec is added, only the table needs updating.

**Independent Test**: Can be tested by adding a mock mode with unlock level 99 and verifying it appears locked on the home screen.

**Acceptance Scenarios**:

1. **Given** the mode-unlock table lists Decoder at Level 1, **When** a new learner opens the app, **Then** Decoder is available and tappable.
2. **Given** the mode-unlock table lists Common Words at Level 2, **When** a Level 1 learner views the home screen, **Then** Common Words is grayed out with "Unlock at Level 2".
3. **Given** a mode spec does not declare an unlock level, **When** the progression system loads, **Then** the mode defaults to locked until the table is updated.

---

## Mode-Unlock Table *(single source of truth)*

| Mode | Feature Branch | Unlock Level | Rationale |
|------|----------------|--------------|-----------|
| Koch Letters | (existing) | 1 | Default first mode. Character-level foundation. |
| Freeform Decoder | `008-freeform-decoder` | 1 | Sandbox tool. Always available for experimentation. |
| Common Words | `007-common-words-practice` | 2 | Builds on Koch Letters. Needs all characters known first. |
| QSO Fragments | `011-qso-callsign-practice` | 3 | Needs solid word/copy skills at speed. |
| Callsign Copy | `011-qso-callsign-practice` | 3 | Needs solid word/copy skills at speed. |
| Head-Copy Practice | `015-head-copy-practice` | 4 | Passive listening. Requires mental word recognition without tapping. |
| Speed Ladder | `016-speed-ladder` | 5 | Pushes speed ceiling. Needs comfort at base WPM. |
| Echo Mode | `018-echo-mode` | 6 | Sending practice. Less critical than receiving. |
| Contest Mode | `017-contest-prosigns` | 7 | Timed pressure. Needs prosign recognition + speed. |
| Prosign Practice | `017-contest-prosigns` | 7 | Contextual prosigns. Easier after QSO fragments. |
| Band Conditions | `019-band-conditions` | 9 | Heavy audio degradation. Final challenge mode. |

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST track a global Proficiency Level from 1 to 10 based on a weighted proficiency score.
- **FR-002**: The system MUST calculate proficiency using the formula: proficiency = Σ(mode_accuracy × mode_weight × speed_multiplier) / Σ(mode_weight).
- **FR-003**: The system MUST assign mode weights: Koch Letters = 3.0, Common Words = 2.0, QSO Fragments = 2.0, Callsign Copy = 2.0, Head-Copy = 2.5, Speed Ladder = 2.0, Contest = 1.0, Echo = 1.5, Prosigns = 1.5, Decoder = 1.5.
- **FR-004**: The system MUST calculate speed_multiplier as 1.0 at base speed, increasing by 0.1 per WPM above base, capped at 2.0x for speeds ≥ 25 WPM.
- **FR-005**: The system MUST define level thresholds: Level 1 (0-19), Level 2 (20-29), Level 3 (30-39), Level 4 (40-49), Level 5 (50-59), Level 6 (60-69), Level 7 (70-79), Level 8 (80-89), Level 9 (90-99), Level 10 (100+).
- **FR-006**: The system MUST lock modes that require a higher proficiency level than the learner currently has.
- **FR-007**: The system MUST display locked modes on the home screen as grayed out with "Unlock at Level X" labels.
- **FR-008**: The system MUST play a "Level Up!" animation and show a tutorial overlay when advancement criteria are met.
- **FR-009**: The system MUST check advancement criteria after every completed session in an unlocked mode.
- **FR-010**: The system MUST require all previous level criteria to be met before advancing to the next level.
- **FR-011**: Proficiency scores MUST be monotonic; they never decrease due to poor performance.
- **FR-012**: The system MUST read unlock levels from the mode-unlock table; no mode is hard-coded outside the table.

### Key Entities

- **ProficiencyProfile**: Tracks the learner's global level and score. Key attributes: level (1-10), proficiencyScore, unlockedModes, advancementCriteriaMet.
- **ModePerformance**: Per-mode accuracy and speed tracking. Key attributes: modeName, bestAccuracy, bestSpeedWpm, totalSessions, speedCeiling.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Learners advance from Level 1 to Level 2 within 3 days of regular practice (15 min/day).
- **SC-002**: 90% of learners report the progression system "guides my learning without overwhelming me" in qualitative feedback.
- **SC-003**: No learner reports being stuck at a level for more than 2 weeks due to advancement criteria being unreachable.

## Assumptions

- Proficiency scores are calculated from best-session performance per mode, not cumulative averages.
- The progression system ships alongside existing Koch, Word, and QSO practice; it does not replace them.
- Level 10 is achievable but requires mastery of all modes at 25+ WPM; it is designed as a long-term goal.
