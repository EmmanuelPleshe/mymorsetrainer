# Feature Specification: Settings Persistence

**Feature Branch**: `022-settings-persistence`
**Created**: 2026-05-09
**Status**: Draft
**Input**: User description: "Add Settings Persistence spec — WPM, effective WPM, tone, volume. Load on startup. Apply immediately. Mentioned everywhere, specified nowhere."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Persist WPM and Effective WPM (Priority: P1)

A user adjusts WPM or effective WPM to their preferred learning speed. The app remembers these values so the user does not need to reconfigure them every session.

**Why this priority**: WPM is the core training parameter. Reconfiguring it on every launch is friction that discourages daily practice.

**Independent Test**: Can be fully tested by changing WPM, closing the app, reopening it, and verifying the same WPM is active. Delivers immediate user value without any other features.

**Acceptance Scenarios**:

1. **Given** the user sets WPM to 25, **When** they close and reopen the app, **Then** playback uses WPM 25.
2. **Given** the user sets effective WPM to 18, **When** they close and reopen the app, **Then** effective WPM remains 18.

---

### User Story 2 - Persist Tone and Volume (Priority: P2)

A user adjusts tone frequency or volume to a comfortable level for their hearing and environment. The app retains these audio preferences across sessions.

**Why this priority**: Audio comfort is personal and environment-dependent. Re-setting tone/volume each time adds unnecessary friction.

**Independent Test**: Can be tested by changing tone and volume, closing the app, reopening, and hearing the same tone and volume on playback.

**Acceptance Scenarios**:

1. **Given** the user sets tone to 700 Hz, **When** they close and reopen the app, **Then** playback tone is 700 Hz.
2. **Given** the user sets volume to 30%, **When** they close and reopen the app, **Then** playback volume is 30%.

---

### User Story 3 - Apply Settings Immediately (Priority: P1)

A user changes a setting during a training session and sees the effect right away, without restarting the app or the current exercise.

**Why this priority**: Immediate feedback is essential for a responsive learning tool. Users experiment with settings to find what works; delay breaks the experimentation loop.

**Independent Test**: Can be tested by starting playback, changing WPM mid-playback, and hearing the new speed on the next symbol.

**Acceptance Scenarios**:

1. **Given** playback is active, **When** the user changes WPM, **Then** the next symbol plays at the new WPM.
2. **Given** playback is active, **When** the user changes volume, **Then** the next symbol plays at the new volume.

---

### Edge Cases

- What happens when persisted settings data is missing or unreadable on startup?
- How does the system handle a user setting values outside the valid range?
- What happens when a new setting is added in a future version and no persisted value exists?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST persist WPM setting across app sessions.
- **FR-002**: System MUST persist effective WPM setting across app sessions.
- **FR-003**: System MUST persist tone frequency setting across app sessions.
- **FR-004**: System MUST persist volume level setting across app sessions.
- **FR-005**: System MUST load all persisted settings automatically on app startup.
- **FR-006**: System MUST apply setting changes immediately without requiring app restart.
- **FR-007**: System MUST initialize settings to sensible defaults when no persisted values exist.
- **FR-008**: System MUST validate setting values and reject or clamp values outside supported ranges.

### Key Entities *(include if feature involves data)*

- **User Settings**: Collection of audio and timing preferences including WPM (words per minute), effective WPM (Farnsworth spacing), tone frequency (Hz), and volume level (percentage).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users retain their custom settings after closing and reopening the app.
- **SC-002**: Setting changes take effect within 1 second of adjustment.
- **SC-003**: App initializes with persisted settings on cold start in under 2 seconds.
- **SC-004**: Users do not need to reconfigure settings on more than 1% of app launches.

## Assumptions

- Settings are stored locally on the device; cloud sync is out of scope.
- Default values when no persisted data exists: WPM 20, effective WPM 20, tone 600 Hz, volume 50%.
- Settings scope is per-device and per-user profile if profiles exist; otherwise global to the app.
- Future settings additions will follow the same persistence pattern without migration complexity.
