# Feature Specification: Anti-Grind Protection

**Feature Branch**: `013-anti-grind-protection`
**Created**: 2026-05-08
**Status**: Draft
**Input**: User description: "Feature: Diminishing Returns / Daily Caps and Stagnation Detection. Anti-grind mechanics that reduce progression gains from excessive single-mode practice and detect when learners are stuck, offering guidance."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Diminishing Returns on Single-Mode Grinding (Priority: P1)

A learner has completed 5 or more sessions in the same practice mode today. On the 6th session, accuracy gains toward level progression are reduced by 50%. A gentle suggestion appears: "Try Head-Copy for variety!"

**Why this priority**: Core anti-grind mechanic. Without it, learners exploit easy modes to unlock everything, bypassing balanced skill development.

**Independent Test**: Can be tested by completing 5 sessions in one mode and verifying the 6th session awards half the normal proficiency progress.

**Acceptance Scenarios**:

1. **Given** I have completed 5 sessions in Koch Letters mode today, **When** I start the 6th session in Koch Letters, **Then** a banner appears: "Diminishing returns active — try a different mode for full progress", **And** my accuracy gains toward proficiency are reduced by 50%.
2. **Given** diminishing returns are active, **When** I switch to Head-Copy mode and start a session, **Then** full proficiency gains are restored, **And** the banner disappears.
3. **Given** I have completed 3 sessions in Contest Mode and 3 in Speed Ladder today, **When** I start a 7th session in either mode, **Then** full proficiency gains apply, **Because** the sessions were spread across modes.
4. **Given** diminishing returns are active, **When** I view my home screen, **Then** an unlocked but under-practiced mode is highlighted with a "Recommended for full progress" badge.

---

### User Story 2 — Daily Session Cap Notification (Priority: P1)

A learner has hit the daily soft cap for a single mode. The app notifies them they have reached the optimal daily practice volume for that mode and suggests alternatives.

**Why this priority**: Prevents burnout and over-practice in one skill. Encourages distributed practice across the day.

**Independent Test**: Can be tested by completing 5 sessions in one mode and verifying the post-session summary includes a cap notification.

**Acceptance Scenarios**:

1. **Given** I have completed 5 sessions in the same mode today, **When** I finish the 5th session, **Then** the post-session summary shows: "Great work! You've reached the daily goal for this mode. Come back tomorrow or try another skill."
2. **Given** I attempt to start a 6th session in a capped mode, **When** the session starts, **Then** a non-blocking dialog appears: "You've practiced this mode enough today for maximum benefit. Continue anyway?", **And** I can choose "Continue" or "Switch Mode".
3. **Given** I start a 6th session and choose "Continue", **When** the session runs, **Then** diminishing returns apply, **And** my progress is still recorded but at reduced weight.

---

### User Story 3 — Stagnation Detection (Priority: P1)

A learner has failed to advance their proficiency level for 10 consecutive sessions. The app detects the stagnation and presents three options: "Review fundamentals?" (drop to easier mode), "Adjust Farnsworth spacing?" (slower effective speed), or "Take a break — come back tomorrow".

**Why this priority**: Stuck learners quit. Detection and guidance prevents frustration and attrition.

**Independent Test**: Can be tested by simulating 10 failed sessions and verifying the stagnation prompt appears.

**Acceptance Scenarios**:

1. **Given** I have completed 10 sessions without meeting any advancement criteria, **When** I finish the 10th session, **Then** a stagnation dialog appears with three options: "Review fundamentals?", "Adjust Farnsworth spacing?", and "Take a break — come back tomorrow".
2. **Given** the stagnation dialog is showing, **When** I tap "Review fundamentals?", **Then** the app suggests dropping to the previous level's practice mode, **And** a one-time bonus to proficiency gains is applied for the next 3 sessions in that easier mode.
3. **Given** the stagnation dialog is showing, **When** I tap "Adjust Farnsworth spacing?", **Then** the settings screen opens with the effective WPM slider highlighted, **And** a tooltip explains: "Slowing down the effective speed may help you hear the rhythm more clearly."
4. **Given** the stagnation dialog is showing, **When** I tap "Take a break — come back tomorrow", **Then** the app closes the dialog, **And** a reminder notification is scheduled for the next day, **And** no penalty is applied for the break.
5. **Given** stagnation has been detected, **When** I successfully advance after choosing an intervention, **Then** the stagnation counter resets to zero, **And** a "Back on track!" message appears.

---

### User Story 4 — Progress Dashboard Warnings (Priority: P2)

A learner views their progress dashboard and sees visual warnings about grinding or stagnation risks before they become severe.

**Why this priority**: Proactive warnings help learners self-correct before the system forces intervention. Gives agency.

**Independent Test**: Can be tested by viewing the dashboard after 3 sessions in one mode and verifying a mild warning appears.

**Acceptance Scenarios**:

1. **Given** I have completed 3 sessions in the same mode today, **When** I view my progress dashboard, **Then** a yellow warning appears: "You're focusing heavily on one mode. Variety builds stronger skills."
2. **Given** I have completed 4 sessions in the same mode today, **When** I view my progress dashboard, **Then** an orange warning appears: "Diminishing returns begin after the next session in this mode."
3. **Given** I have completed 7 sessions without advancing, **When** I view my progress dashboard, **Then** a yellow warning appears: "You haven't advanced recently. Consider reviewing fundamentals or adjusting speed."
4. **Given** I have completed 10 sessions without advancing, **When** I view my progress dashboard, **Then** a red alert appears: "Stagnation detected. Tap for suggestions."

---

### Edge Cases

- What happens if a learner plays exactly 5 sessions across 2 modes (3 in one, 2 in another)? No diminishing returns apply; the 3-session mode is at 60% of the cap.
- What happens if the learner starts a 6th session in a capped mode but quits mid-session? The partial session counts toward the cap if at least one item was completed.
- What happens if the learner uses multiple devices? Daily caps are tracked per device; cross-device sync is out of scope.
- What happens if the learner practices at 11:59 PM and resumes at 12:01 AM? The daily cap resets at midnight local time.
- What happens if the learner is in a stagnation state but also has diminishing returns active? Both apply independently; the stagnation dialog still appears after the 10th failed session.
- What happens if the learner declines all stagnation interventions and keeps failing? The stagnation dialog reappears every 5 additional failed sessions with slightly different wording.
- What happens if the learner advances during a session that also triggers stagnation? Advancement takes precedence; stagnation is not declared if the session ends with a level-up.
- What happens if the app is uninstalled and reinstalled? Daily cap and stagnation counters reset; this is acceptable as there is no cloud backup.
- What happens on days when the learner only has time for one session? No warnings appear; the system is lenient for low-volume days.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST track the number of completed sessions per mode per calendar day.
- **FR-002**: The system MUST define a daily soft cap of 5 sessions per mode per day.
- **FR-003**: When a learner completes more than 5 sessions in the same mode on the same day, the system MUST reduce proficiency gains for that mode by 50%.
- **FR-004**: The system MUST display a non-blocking banner when diminishing returns are active for the current session.
- **FR-005**: The system MUST suggest an alternative unlocked mode on the home screen when diminishing returns are active.
- **FR-006**: The system MUST track the number of consecutive sessions without meeting any advancement criteria.
- **FR-007**: When a learner completes 10 consecutive sessions without advancing, the system MUST display a stagnation dialog with three options: "Review fundamentals?", "Adjust Farnsworth spacing?", and "Take a break — come back tomorrow".
- **FR-008**: The stagnation dialog MUST appear after the post-session summary, not during active practice.
- **FR-009**: The system MUST reset the stagnation counter when any advancement criteria are met.
- **FR-010**: The system MUST display a progress dashboard warning when a learner approaches the daily cap (3+ sessions in one mode).
- **FR-011**: The system MUST display a progress dashboard warning when a learner approaches stagnation (7+ sessions without advancing).
- **FR-012**: The system MUST allow the learner to continue a capped mode at reduced gains after acknowledging a non-blocking dialog.
- **FR-013**: The system MUST offer a one-time proficiency gain bonus for the next 3 sessions when "Review fundamentals?" is selected.
- **FR-014**: The system MUST open the settings screen with the effective WPM slider highlighted when "Adjust Farnsworth spacing?" is selected.
- **FR-015**: The system MUST schedule a next-day reminder notification when "Take a break — come back tomorrow" is selected.
- **FR-016**: The system MUST apply diminishing returns and stagnation detection independently; both can be active simultaneously.
- **FR-017**: The daily session counter MUST reset at midnight local time.
- **FR-018**: The stagnation counter MUST persist across app restarts.

### Key Entities

- **DailySessionLog**: Tracks sessions per mode per day. Key attributes: modeName, sessionCount, date, lastSessionTimestamp.
- **StagnationState**: Tracks consecutive failed sessions. Key attributes: consecutiveSessionsWithoutAdvancement, lastAdvancementDate, stagnationFlag, interventionChosen.
- **AntiGrindConfig**: Configuration for caps and thresholds. Key attributes: dailyCapPerMode, diminishingReturnsFactor, stagnationThreshold, warningThreshold.
- **ProgressWarning**: A dashboard warning about grinding or stagnation. Key attributes: warningType (grinding | stagnation | approaching_cap | approaching_stagnation), severity (yellow | orange | red), message, actionable.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Learners who hit diminishing returns switch to a different mode within 1 session in ≥ 70% of cases.
- **SC-002**: No learner reaches Level 10 by grinding a single mode; 100% of Level 10 learners have practiced ≥ 5 different modes.
- **SC-003**: Learners who receive stagnation intervention and follow it advance within 5 sessions in ≥ 60% of cases.
- **SC-004**: Learner churn rate (sessions dropping to zero for 7+ days) among stagnating users decreases by ≥ 30% compared to users without the feature.
- **SC-005**: ≥ 80% of learners report the anti-grind messages feel "helpful, not punishing" in qualitative feedback.
- **SC-006**: Daily cap warnings appear in ≤ 300ms on the progress dashboard.

## Assumptions

- The app already tracks sessions per mode and per-user advancement criteria.
- Proficiency scores and level thresholds are managed by the Graduated Mode Unlocking system.
- The effective WPM slider already exists in the settings screen.
- Notification scheduling uses the device's local notification system.
- A **session** is a bounded practice unit: **20 characters or 5 minutes of elapsed time, whichever comes first**.
- A session is considered "completed" if at least one item was answered.
- Cross-device session tracking is out of scope; caps are per-device.
- The definition of "today" uses the device's local timezone.
- A "failed" session is one where no advancement criteria were met, regardless of individual item accuracy.
