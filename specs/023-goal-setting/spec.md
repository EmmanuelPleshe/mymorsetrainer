# Feature Specification: Goal Setting and Personalized Learning Paths

**Feature Branch**: `023-goal-setting`
**Created**: 2026-05-23
**Status**: Draft
**Input**: User description: "Create a feature that lets us define goals for users and help them pursue those goals. Some users are new to CW, others are brushing up or starting at a different level."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Pick a Learning Path (Priority: P1)

A new user (or existing user) wants to set a clear direction for their Morse code learning. They are presented with 3–4 predefined goal paths based on their experience level, pick one, and see their first milestone.

**Why this priority**: Without a clear goal, learners drift between modes without a sense of direction or accomplishment. A path provides motivation and structure.

**Independent Test**: Can be tested by opening the goal selection screen, picking a path, and verifying the progress screen shows the active goal.

**Acceptance Scenarios**:

1. **Given** the user has not yet selected a goal path, **When** they visit the Progress screen, **Then** they see a "Choose Your Path" card prompting them to select one.
2. **Given** the user taps "Choose Your Path", **When** the Goal Selection screen opens, **Then** they see all available paths with descriptions and milestone counts.
3. **Given** the user selects a path, **When** they confirm, **Then** the path is saved as their active goal, **And** the first milestone is shown on the Progress screen.

---

### User Story 2 — Track Milestone Progress (Priority: P1)

A learner with an active goal path sees their current milestone and how close they are to completing it. After each practice session, the app checks whether the milestone criteria were met.

**Why this priority**: Visibility into progress keeps learners motivated. Checking milestones automatically after sessions removes manual tracking friction.

**Independent Test**: Can be tested by completing a practice session that meets a milestone criterion and verifying the milestone is marked complete.

**Acceptance Scenarios**:

1. **Given** a user on "Complete the Alphabet & Numbers" has completed 5/6 Koch letters in Level 1, **When** they finish another session with the 6th letter at 80% accuracy, **Then** Milestone 2 ("Complete Level 1") is marked complete.
2. **Given** a milestone is completed, **When** the user views the Progress screen, **Then** they see a celebratory indicator and the next milestone is displayed.
3. **Given** all milestones in a path are completed, **When** the user views the Progress screen, **Then** they see a "Path Complete!" badge and an option to select a new path.

---

### User Story 3 — Switch or Re-select a Path (Priority: P2)

A learner who picked the wrong path, finished a path, or wants a new challenge can switch to a different goal path at any time. Progress on the old path is preserved.

**Why this priority**: Learners' needs change. Locking them into one path causes frustration. Preserving old path progress allows them to return later.

**Independent Test**: Can be tested by switching from "Complete the Alphabet & Numbers" to "Speed Builder" and verifying the new milestone is tracked independently.

**Acceptance Scenarios**:

1. **Given** the user has an active path, **When** they tap "Change Goal" on the Progress screen, **Then** the Goal Selection screen opens with their current path highlighted.
2. **Given** the user selects a different path, **When** they confirm, **Then** the new path becomes active, **And** the old path's milestone progress is retained in storage.
3. **Given** the user re-selects a previously started path, **When** they confirm, **Then** their prior milestone progress is restored.

---

## Goal Paths and Milestones

### Path 1: Complete the Alphabet & Numbers

**Audience**: New to CW
**Description**: Start from zero and build a solid foundation. Learn all 26 letters and digits 0–9 at a comfortable pace.
**Bonus Points on Completion**: 500

| # | Milestone Title | Completion Criteria |
|---|-----------------|---------------------|
| 1 | First Steps | Complete 1 session with any 2 Koch letters |
| 2 | Level 1 Mastery | Complete all 6 letters in Koch Level 1 with >= 80% average accuracy |
| 3 | Halfway There | Complete all 12 letters in Koch Level 2 with >= 80% average accuracy |
| 4 | Full Alphabet | Complete all 26 letters with >= 80% average accuracy |
| 5 | Number Whiz | Master digits 0–9 with >= 80% average accuracy |
| 6 | Mixed Practice | Complete 3 sessions mixing letters and numbers at 10 WPM with >= 80% accuracy |

### Path 2: Speed Builder

**Audience**: Knows the alphabet, wants speed
**Description**: Push your copy speed higher. Focus on clean copy at increasing WPM.
**Bonus Points on Completion**: 750

| # | Milestone Title | Completion Criteria |
|---|-----------------|---------------------|
| 1 | 15 WPM Club | Complete 3 sessions at 15 WPM with >= 90% accuracy |
| 2 | 20 WPM Club | Complete 3 sessions at 20 WPM with >= 90% accuracy |
| 3 | 25 WPM Club | Complete 3 sessions at 25 WPM with >= 90% accuracy |
| 4 | 30 WPM Master | Complete 3 sessions at 30 WPM with >= 90% accuracy |

### Path 3: Rusty Refresher

**Audience**: Experienced but out of practice
**Description**: Get back up to speed with an assessment and structured refresh.
**Bonus Points on Completion**: 500

| # | Milestone Title | Completion Criteria |
|---|-----------------|---------------------|
| 1 | Assessment | Complete 1 assessment session to determine current level |
| 2 | Back in the Saddle | Complete 5 sessions at assessed WPM level |
| 3 | Level Up | Complete 3 sessions at +5 WPM from assessed level |
| 4 | Consistency King | Maintain a 7-day practice streak |

### Path 4: Numbers Specialist

**Audience**: Knows letters, struggles with numbers
**Description**: Targeted practice on the 10 Morse digits. A common weak point for CW operators.
**Bonus Points on Completion**: 500

| # | Milestone Title | Completion Criteria |
|---|-----------------|---------------------|
| 1 | Digits 0–4 | Master digits 0–4 with >= 80% accuracy |
| 2 | Digits 5–9 | Master digits 5–9 with >= 80% accuracy |
| 3 | Full Range | Master all digits 0–9 with >= 90% accuracy |
| 4 | Speedy Numbers | Complete 3 sessions with digits only at 15 WPM with >= 90% accuracy |

### Path 5: Prosign Specialist

**Audience**: Knows letters and numbers, wants to learn CW shorthand
**Description**: Master the most common prosigns and Q-signals used in real CW QSOs. Essential for on-air communication.
**Bonus Points on Completion**: 500

| # | Milestone Title | Completion Criteria |
|---|-----------------|---------------------|
| 1 | Q-Codes | Master QSO, QRM, QRN, QSB, QSL, QTH with >= 80% accuracy |
| 2 | Prosign Basics | Master AR, AS, SK, BK, KN with >= 80% accuracy |
| 3 | Full Prosign Set | Master all common prosigns with >= 90% accuracy |
| 4 | QSO Ready | Complete 3 QSO practice sessions using prosigns with >= 90% accuracy |

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST present at least 5 predefined goal paths.
- **FR-002**: System MUST allow the user to select one active goal path at a time.
- **FR-003**: System MUST display the current milestone and completion status on the Progress screen.
- **FR-004**: System MUST automatically check milestone criteria after each completed practice session.
- **FR-005**: System MUST award bonus points when a milestone or full path is completed.
- **FR-006**: System MUST allow the user to switch goal paths without losing prior path progress.
- **FR-007**: System MUST show a celebratory indicator when a milestone is completed.
- **FR-008**: System MUST show a "Path Complete" state when all milestones in a path are finished.
- **FR-009**: System MUST persist goal path selection and milestone progress across app sessions.

### Key Entities

- **GoalPath**: A named learning journey containing an ordered list of Milestones.
- **Milestone**: A concrete objective with a title, description, criteria type, and target parameters.
- **UserGoal**: Tracks which GoalPath is active, current milestone index, per-milestone completion status, and completion timestamps.
- **MilestoneCriteria**: An enum defining how completion is checked (e.g., `kochLevelAccuracy`, `sessionsAtWpm`, `streakDays`, `assessmentComplete`).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- Users can select and view an active goal path within 2 taps from the Progress screen.
- Milestone completion is detected automatically with zero manual steps from the user.
- At least 80% of users who select a goal path complete at least one milestone within 7 days.

---

## UI Changes

### Progress Screen
- Add a `GoalCard` widget at the top showing:
  - Active path name (e.g., "Complete the Alphabet & Numbers")
  - Current milestone title and description
  - Linear progress indicator (e.g., "Milestone 2 of 6")
  - A "Change Goal" button to open Goal Selection

### Goal Selection Screen
- Full-screen list of available paths
- Each path shows: name, description, number of milestones, estimated time
- Tapping a path expands to show its milestone list
- "Select This Path" button to confirm
- Current active path is highlighted

### Practice Completion / Session End
- If a milestone was completed during the session, show a brief banner: "Milestone Complete: [Title] +[Points] pts"
- If the final milestone of a path was completed, show a celebration modal with path completion summary

---

## Architecture Overview

```
GoalPath (immutable definitions)
  └── List<Milestone>
        └── MilestoneCriteria

UserGoal (per-user persisted state)
  └── goalPathId, currentMilestoneIndex, List<bool> completedMilestones

GoalService
  ├── loadUserGoal() → UserGoal
  ├── selectGoalPath(String pathId) → void
  ├── checkMilestones(SessionResult result) → List<Milestone> completed
  ├── getActivePath() → GoalPath
  └── awardMilestonePoints(Milestone) → void

Integration Points:
  - PracticeSessionBloc → on session complete, calls GoalService.checkMilestones()
  - GamificationService → GoalService calls awardPoints() for milestone bonuses
  - ProgressScreen → reads UserGoal via GoalService to display GoalCard
```

## Files to Create / Modify

| File | Action | Responsibility |
|------|--------|---------------|
| `lib/data/models/goal_path.dart` | Create | GoalPath, Milestone, MilestoneCriteria models |
| `lib/data/models/user_goal.dart` | Create | UserGoal model with persistence methods |
| `lib/domain/goals/goal_service.dart` | Create | Business logic for goal selection and milestone checking |
| `lib/ui/screens/goal_selection_screen.dart` | Create | Screen to browse and select goal paths |
| `lib/ui/widgets/goal_card.dart` | Create | Reusable widget showing current goal progress |
| `lib/ui/screens/progress_screen.dart` | Modify | Add GoalCard at top of Progress screen |
| `lib/ui/bloc/practice_session_bloc.dart` | Modify | Call GoalService after session completion |
| `lib/data/database/database_helper.dart` | Modify | Add tables for UserGoal persistence |

---

## Open Questions / Dependencies

- **Digits tracking**: The "Complete the Alphabet & Numbers" and "Numbers Specialist" paths assume digits 0–9 are tracked for accuracy. If the database does not yet have digit records, `CharacterRepository` (or a new `DigitRepository`) must be extended to include them.
- **Assessment session**: The "Rusty Refresher" assessment milestone requires a dedicated assessment mode or a special flag on a normal session to determine the user's current level. This can be a simplified session that samples characters at multiple WPM levels.
- **Mixed practice mode**: Milestone 6 of "Complete the Alphabet & Numbers" requires a session that mixes letters and numbers. If no mixed mode exists, this can initially be simulated by alternating character types within a normal session.
- **Prosign tracking**: Individual prosigns (AR, AS, SK, BK, KN) and Q-codes (QSO, QRM, etc.) are embedded within QSO phrases but not tracked separately. The "Prosign Specialist" milestones can initially be satisfied by completing QSO practice sessions that include those elements, or by adding a dedicated prosign practice subset to `QSOService`.

## Tech Stack

- Flutter / Dart
- Existing: `UserProgress`, `GamificationService`, `KochProgressionService`, `PracticeSessionBloc`
- Testing: flutter_test, mocktail, bloc_test
