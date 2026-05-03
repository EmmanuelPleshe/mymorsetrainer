# Feature Specification: Morse Trainer App

**Feature Branch**: `001-morse-trainer-app`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "full app specification, including options for adjusting tone and speed, but start at 20wpm"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Learn First Characters with Koch Method (Priority: P1)

A beginner starts the app, selects Koch mode, and begins learning with just K and M characters. The app plays the morse code audio for a character, the user keys it back using their preferred input method, and the app verifies accuracy. Upon achieving 90% correct responses, the app unlocks the next character.

**Why this priority**: Core learning loop - the fundamental interaction that makes the app useful for learning morse code.

**Independent Test**: Can be tested by completing first Koch level with 2 characters and advancing to next level.

**Acceptance Scenarios**:

1. **Given** user starts app in Koch mode, **When** app plays "K" in morse code, **Then** user keys K using any input method and receives immediate feedback
2. **Given** user has 90%+ accuracy on current level, **When** they complete a practice session, **Then** next character is unlocked and available in next session
3. **Given** user is on characters K and M, **When** they achieve 90% accuracy, **Then** next character (R) is added to practice pool

---

### User Story 2 - Practice with Multiple Input Methods (Priority: P1)

User selects their preferred input method (keyboard, touchscreen, game controller, or audio input from microphone/keyed interface). The app correctly interprets their input as morse code dots and dashes.

**Why this priority**: Accessibility and personal preference - users must be able to use whatever input device they have available.

**Independent Test**: Each input method can be tested independently without affecting other functionality.

**Acceptance Scenarios**:

1. **Given** keyboard is selected as input, **When** user presses/releases spacebar to key dots/dashes, **Then** input is captured as morse code and decoded to characters
2. **Given** touchscreen tap is selected, **When** user taps screen for dots/dashes, **Then** touch duration is measured and decoded
3. **Given** game controller button is selected, **When** user presses configured button, **Then** press duration is measured and decoded
4. **Given** audio input is selected, **When** user keys a real morse key into microphone/line-in, **Then** audio is decoded into dots/dashes

---

### User Story 3 - Adjust Tone and Speed (Priority: P2)

User can adjust the morse code audio tone (frequency) and speed (WPM) to their preference. Default settings are 800Hz tone and 15 WPM.

**Why this priority**: Comfortable learning - different users have different hearing abilities and preferred practice speeds.

**Independent Test**: Can be tested by changing settings and verifying audio output matches configuration.

**Acceptance Scenarios**:

1. **Given** default settings are 600Hz and 20 WPM, **When** user plays morse code, **Then** audio plays at 600Hz tone at 20 WPM speed
2. **Given** user changes tone to 800Hz, **When** morse code plays, **Then** audio pitch is 800Hz
3. **Given** user changes speed to 25 WPM, **When** morse code plays, **Then** character timing reflects 25 WPM

---

### User Story 4 - Spaced Repetition Review (Priority: P2)

User has been practicing and the app tracks their performance on each character. Characters with lower mastery appear more frequently per the spaced repetition algorithm, while mastered characters appear less often.

**Why this priority**: Memory optimization - ensures efficient learning by focusing on characters the user struggles with.

**Independent Test**: Can be verified by checking that struggling characters appear more frequently than mastered ones.

**Acceptance Scenarios**:

1. **Given** user has learned characters K, M, R, and has low accuracy on K, **When** practice session starts, **Then** K appears more frequently than R
2. **Given** user has 90%+ accuracy on a character for multiple sessions, **When** next practice occurs, **Then** that character's review interval has increased (2 days → 7 days → 30 days → 90 days)
3. **Given** user hasn't practiced for 7 days, **When** they start a session, **Then** characters due for review are prioritized

---

### User Story 5 - Progress to Words and QSO Phrases (Priority: P3)

User has completed the alphabet and wants to practice with common words and QSO (contact) phrases used in ham radio operations.

**Why this priority**: Real-world application - moving from individual characters to practical communication.

**Independent Test**: Can be tested by completing alphabet level and transitioning to word/phrase practice.

**Acceptance Scenarios**:

1. **Given** user has mastered all 26 letters, **When** they complete alphabet level, **Then** word practice mode becomes available
2. **Given** user selects word practice, **When** app plays a common ham radio word (e.g., "CQ", "73", "QTH"), **Then** user keys the word and receives feedback
3. **Given** user selects QSO phrase practice, **When** app plays complete QSO phrases, **Then** user keys the full phrase

---

### User Story 6 - Gamification and Progress Tracking (Priority: P3)

User earns points for correct responses, maintains streaks for consecutive correct answers, and sees visual progress indicators that motivate continued practice.

**Why this priority**: Motivation reinforcement - gamification elements encourage regular practice sessions.

**Independent Test**: Can be verified by checking point accumulation and streak tracking during practice.

**Acceptance Scenarios**:

1. **Given** user answers correctly, **When** response is verified as correct, **Then** points are awarded based on character difficulty
2. **Given** user maintains correct streak, **When** streak reaches milestones (5, 10, 25, 50), **Then** bonus points are awarded
3. **Given** user views progress screen, **When** they see their statistics, **Then** they see total points, current streak, longest streak, characters mastered, and current level

---

### Edge Cases

- What happens when audio input has excessive background noise?
- How does the app handle a user who keys a character while audio is still playing?
- What occurs when input timing is ambiguous (too short to be a dot, too long to be a dash)?
- How does the app handle very long silence between key presses (abandoned attempt)?
- What happens on Android when the app goes to background during a practice session?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST play morse code audio for characters using Koch method sequence (K, M, R, U, A, P, L, T, W, I, N, J, E, Y, O, S, Q, Z, H, V, F, B, D, X, C). Audio MUST play automatically when character is displayed. User does NOT type the character - user keys it back using spacebar.
- **FR-002**: System MUST accept input from keyboard, touchscreen tap, game controller button, and audio input (microphone/line-in)
- **FR-003**: System MUST verify user keying against expected morse code pattern and provide immediate feedback (correct/incorrect)
- **FR-004**: System MUST require 90% accuracy before unlocking next character in Koch sequence
- **FR-005**: System MUST implement spaced repetition algorithm with intervals: 2 days → 7 days → 30 days → 90 days based on mastery level
- **FR-006**: System MUST allow adjustment of audio tone frequency (default 800Hz, range 300Hz-2000Hz)
- **FR-007**: System MUST allow adjustment of morse code speed in WPM (default 20 WPM, range 5-40 WPM)
- **FR-008**: System MUST track user performance per character and schedule reviews based on spaced repetition
- **FR-009**: System MUST provide word practice mode after alphabet completion
- **FR-010**: System MUST provide QSO phrase practice mode after word completion
- **FR-011**: System MUST award points for correct responses with bonus for streak milestones
- **FR-012**: System MUST display progress statistics including points, streaks, characters mastered, and current level
- **FR-013**: System MUST build for Linux desktop and Android mobile platforms
- **FR-014**: System MUST support multiple input methods simultaneously without requiring restart

### Key Entities *(include if feature involves data)*

- **Character**: Represents a letter or symbol with its morse code pattern (dots/dashes), current mastery level, and spaced repetition schedule
- **UserProgress**: Tracks total points, current streak, longest streak, current level, and per-character performance
- **Session**: Records a practice session including characters practiced, accuracy, duration, and input method used
- **Settings**: User preferences including tone frequency, speed (WPM), preferred input method, and audio volume

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete Koch level 1 (2 characters: K, M) with 90% accuracy within first 10-minute session
- **SC-002**: Users can progress through all 26 letters using spaced repetition within 60 days of regular practice (15 min/day)
- **SC-003**: 90% of users successfully complete character keying verification on first attempt after hearing the character
- **SC-004**: App builds successfully on Linux and Android without platform-specific errors
- **SC-005**: Audio latency between key press and sound output is under 50ms
- **SC-006**: Input recognition accuracy is 95%+ for keyboard/touchscreen/controller inputs
- **SC-007**: Audio input decoding accuracy is 90%+ with proper key/interface

## Assumptions

- Users have basic familiarity with keyboard or touchscreen devices
- Audio input will use standard system audio APIs (PulseAudio on Linux, Oboe on Android)
- Default 20 WPM speed is comfortable for beginners while being fast enough to build real-world skills
- Gamification elements can be disabled for users who prefer pure learning without points
- Settings persist between sessions on the same device
- Network connectivity is not required for core functionality (offline-first design)