# Feature Specification: Advanced Training Modes with Graduated Progression

**Feature Branch**: `012-advanced-training-modes`
**Created**: 2026-05-08
**Status**: **SUPERSEDED** — Split into 014-019. Do not implement.
**Input**: User description: "Feature: Head-Copy Practice, Adaptive Speed Ladder, Band Conditions Simulation, Echo Mode, Mini-Contest Mode, Prosign Practice, and Graduated Mode Unlocking with Proficiency Score Calculation"

**Superseded by**:
- `014-graduated-progression` — Proficiency level tracking and mode unlocking
- `015-head-copy-practice` — Passive listening mode without input
- `016-speed-ladder` — Adaptive WPM speed training
- `017-contest-prosigns` — Contest mode and prosign contextual practice
- `018-echo-mode` — Send timing comparison and feedback
- `019-band-conditions` — Audio degradation simulation (QRM, QSB, QRN)

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

### User Story 2 — Head-Copy Practice (Priority: P1)

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

### User Story 3 — Adaptive Speed Ladder (Priority: P2)

A learner enters Speed Ladder mode. The app starts at their comfortable base speed. After every 5 consecutive correct words, speed increases by 1 WPM. After 2 consecutive failures, speed decreases by 1 WPM. The session pushes their "speed ceiling" higher over time.

**Why this priority**: Builds real fluency by dynamically challenging the learner at their edge. Prevents plateauing at a comfortable speed.

**Independent Test**: Can be tested by entering Speed Ladder, answering correctly 5 times, and verifying speed increased.

**Acceptance Scenarios**:

1. **Given** I am in Speed Ladder mode at 15 WPM, **When** I correctly identify 5 words in a row, **Then** the next word plays at 16 WPM.
2. **Given** I am at 20 WPM in Speed Ladder mode, **When** I fail 2 words in a row, **Then** the next word plays at 19 WPM.
3. **Given** I complete a Speed Ladder session, **When** I view my stats, **Then** I see my "speed ceiling" for each practiced word, **And** the ceiling updates if a higher speed was achieved.
4. **Given** my speed drops below the mode's minimum (e.g., 10 WPM), **When** a decrease would occur, **Then** the speed holds at the minimum, **And** the session continues.

---

### User Story 4 — Mini-Contest Mode (Priority: P2)

A learner enters Contest Mode for a 5-minute timed session. The app plays random callsigns followed by signal reports as fast as the learner can copy. Score = correct copies minus errors. Personal best and leaderboard are tracked.

**Why this priority**: Mimics real radio contest pressure in a low-stakes environment. Builds speed and accuracy under time pressure.

**Independent Test**: Can be tested by running a 5-minute session and verifying the score calculation.

**Acceptance Scenarios**:

1. **Given** I start Contest Mode, **When** the session begins, **Then** a 5-minute countdown timer appears, **And** the first callsign plays immediately.
2. **Given** I correctly copy a callsign and signal report, **When** I submit, **Then** my score increases by 1, **And** the next exchange plays.
3. **Given** I submit an incorrect copy, **When** the answer is checked, **Then** my score decreases by 1, **And** the correct text is shown briefly.
4. **Given** the 5-minute timer expires, **When** the session ends, **Then** my final score is displayed, **And** if it is a personal best, a "New Record!" indicator appears, **And** the score is saved to the leaderboard.

---

### User Story 5 — Prosign Practice (Priority: P2)

A learner enters Prosign Practice mode. The app plays common procedural signs (AR, BT, KN, SK, BK, CL) in the context of realistic QSO phrases. The learner must recognize the prosigns within flowing sentences.

**Why this priority**: Prosigns are essential for real-world Morse communication but are rarely practiced in isolation. Contextual practice builds recognition reflexes.

**Independent Test**: Can be tested by entering Prosign Practice, hearing "HELLO BT UR RST 599 AR", and verifying recognition of BT and AR.

**Acceptance Scenarios**:

1. **Given** I am in Prosign Practice mode, **When** a phrase containing "BT" plays, **Then** the phrase flows naturally, **And** "BT" is not visually distinguished from regular letters during playback.
2. **Given** a phrase with multiple prosigns has played, **When** I am asked to identify them, **Then** I can select the prosigns I recognized from a list, **And** my selection is scored.
3. **Given** I am at lower proficiency levels, **When** prosign practice begins, **Then** phrases contain only 1-2 prosigns, **And** the audio speed is reduced.
4. **Given** I am at higher proficiency levels, **When** prosign practice begins, **Then** phrases contain 3-5 prosigns, **And** the audio speed matches my current comfortable WPM.

---

### User Story 6 — Band Conditions Simulation (Priority: P3)

A learner enters any advanced practice mode with Band Conditions enabled. The audio includes adjustable background static, interference (QRM), fading (QSB), and atmospheric noise (QRN). The learner practices copying through degraded audio, starting clean and introducing noise as they advance.

**Why this priority**: Clean audio is a luxury. Real operators copy through garbage. This prepares learners for on-air conditions.

**Independent Test**: Can be tested by enabling Band Conditions in Head-Copy mode and verifying degraded audio playback.

**Acceptance Scenarios**:

1. **Given** I enable Band Conditions in settings, **When** I enter Head-Copy mode, **Then** the audio includes background static at the configured level.
2. **Given** I am at Level 7 or higher, **When** Band Conditions are active, **Then** light static and occasional QSB fading are present.
3. **Given** I am at Level 9 or higher, **When** Band Conditions are active, **Then** heavy QRM (interference signal) and QRN (pops/crashes) are present.
4. **Given** Band Conditions are active, **When** I adjust the static intensity slider, **Then** the audio updates in real time for the next played word.
5. **Given** I am below Level 7, **When** I try to enable heavy QRM, **Then** the option is disabled with a message "Unlock at Level 9".

---

### User Story 7 — Echo Mode (Priority: P3)

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

- What happens if a learner attempts to enter a locked mode? The app shows the mode grayed out; tapping it displays "Unlock at Level X" with the specific criteria needed.
- What happens if proficiency drops due to poor performance? Proficiency never decreases; levels are monotonic. Poor performance simply delays advancement.
- What happens if the learner is in Head-Copy mode and self-assessment is disabled? Session proceeds with "Next" and "Repeat" only; no accuracy data is recorded.
- What happens if a Speed Ladder session starts at the maximum speed (40 WPM)? The speed holds at the maximum; the goal shifts to maintaining accuracy at ceiling.
- What happens if a Contest Mode session is interrupted (app backgrounded)? The timer pauses; the session resumes where it left off when the app returns.
- What happens if Band Conditions static level exceeds device audio limits? The static is capped at a safe maximum; no audio clipping occurs.
- What happens if a prosign is played in isolation (not in a phrase)? At lower levels, prosigns are introduced in isolation first; at higher levels, only contextual phrases are used.
- What happens if Echo Mode receives no input after the target word? A timeout triggers after the inter-word threshold; the attempt is marked incorrect.
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
- **FR-009**: The system MUST provide Head-Copy mode where words play as audio with NO keyboard, NO text field, and NO tapping mechanism.
- **FR-010**: In Head-Copy mode, the system MUST show "Listen...", "Repeat", and "Next" controls.
- **FR-011**: The system MUST optionally enable self-assessment in Head-Copy mode with "I got it" and "Missed it" buttons after each word.
- **FR-012**: The system MUST feed self-assessed accuracy into the smart repetition engine to schedule review intervals.
- **FR-013**: The system MUST provide Adaptive Speed Ladder mode that starts at a comfortable base speed.
- **FR-014**: In Speed Ladder mode, the system MUST increase speed by 1 WPM after 5 consecutive correct responses.
- **FR-015**: In Speed Ladder mode, the system MUST decrease speed by 1 WPM after 2 consecutive failures.
- **FR-016**: The system MUST track a per-word "speed ceiling" that records the highest WPM at which the word was correctly recognized.
- **FR-017**: The system MUST provide Mini-Contest Mode with a 5-minute timed session.
- **FR-018**: In Contest Mode, the system MUST play random callsigns followed by signal reports.
- **FR-019**: In Contest Mode, the system MUST calculate score as correct copies minus errors.
- **FR-020**: The system MUST track personal best scores and display a leaderboard for Contest Mode.
- **FR-021**: The system MUST provide Prosign Practice mode for AR, BT, KN, SK, BK, and CL.
- **FR-022**: In Prosign Practice, prosigns MUST be presented in the context of realistic QSO phrases.
- **FR-023**: The system MUST provide Band Conditions Simulation with adjustable static (white noise).
- **FR-024**: The system MUST provide QRM simulation (second Morse signal at similar frequency).
- **FR-025**: The system MUST provide QSB simulation (volume randomly drops 20-50%).
- **FR-026**: The system MUST provide QRN simulation (random pops and crashes).
- **FR-027**: The system MUST enable light Band Conditions at Level 7+ and heavy conditions at Level 9+.
- **FR-028**: The system MUST provide Echo Mode where the app sends a word and the learner keys it back.
- **FR-029**: In Echo Mode, the system MUST compare sent timing vs. received timing and display a waveform overlay.
- **FR-030**: In Echo Mode, the system MUST provide a timing accuracy score (0-100%) and text feedback on spacing quality.
- **FR-031**: The system MUST check advancement criteria after every completed session in an unlocked mode.
- **FR-032**: The system MUST require all previous level criteria to be met before advancing to the next level.
- **FR-033**: Proficiency scores MUST be monotonic; they never decrease due to poor performance.

### Key Entities

- **ProficiencyProfile**: Tracks the learner's global level and score. Key attributes: level (1-10), proficiencyScore, unlockedModes, advancementCriteriaMet.
- **ModePerformance**: Per-mode accuracy and speed tracking. Key attributes: modeName, bestAccuracy, bestSpeedWpm, totalSessions, speedCeiling.
- **HeadCopySession**: A session with only audio playback and self-assessment. Key attributes: wordQueue, currentIndex, selfAssessmentEnabled, sessionResults.
- **SpeedLadderSession**: A session with dynamically adjusting speed. Key attributes: baseWpm, currentWpm, consecutiveCorrect, consecutiveFail, wordQueue.
- **ContestSession**: A timed contest session. Key attributes: durationSeconds, score, correctCount, errorCount, exchangeQueue, personalBest.
- **BandConditions**: Audio degradation settings. Key attributes: staticLevel, qrmEnabled, qsbEnabled, qrnEnabled, qrmIntensity, qsbDepthPercent.
- **EchoResult**: Timing comparison for a single word. Key attributes: targetPattern, actualPattern, timingAccuracyScore, spacingFeedback.
- **ProsignPhrase**: A QSO phrase containing procedural signs. Key attributes: phraseText, prosignsContained, difficulty.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Learners advance from Level 1 to Level 2 within 3 days of regular practice (15 min/day).
- **SC-002**: Learners who use Head-Copy mode for 2 weeks report ≥ 70% ability to mentally copy common words at 20 WPM without writing.
- **SC-003**: Speed Ladder users increase their average comfortable speed by ≥ 3 WPM after 10 sessions.
- **SC-004**: Contest Mode users achieve ≥ 20 correct copies in a 5-minute session after 1 month of practice.
- **SC-005**: Prosign recognition accuracy reaches ≥ 85% in contextual phrases after 10 practice sessions.
- **SC-006**: Band Conditions users at Level 9+ maintain ≥ 75% copy accuracy in heavy QRM + QRN conditions.
- **SC-007**: Echo Mode users achieve ≥ 80% timing accuracy score within 5 sessions.
- **SC-008**: 90% of learners report the progression system "guides my learning without overwhelming me" in qualitative feedback.
- **SC-009**: No learner reports being stuck at a level for more than 2 weeks due to advancement criteria being unreachable.

## Assumptions

- The app already has a working Morse audio playback service with adjustable WPM and Farnsworth timing.
- The existing keyboard keyer handler can be reused for Echo Mode and Contest Mode.
- Head-Copy mode requires no new input hardware; it is a passive listening mode.
- Proficiency scores are calculated from best-session performance per mode, not cumulative averages.
- Band Conditions audio effects are generated algorithmically and do not require pre-recorded samples.
- Contest Mode uses the same callsign generation logic as the existing Callsign Copy feature.
- Prosigns use standard International Morse code patterns for AR, BT, KN, SK, BK, and CL.
- Speed Ladder base speed defaults to the learner's current Farnsworth effective speed setting.
- Echo Mode waveform overlay is a simplified visual comparison, not a full oscilloscope display.
- The progression system ships alongside existing Koch, Word, and QSO practice; it does not replace them.
- Level 10 is achievable but requires mastery of all modes at 25+ WPM; it is designed as a long-term goal.
