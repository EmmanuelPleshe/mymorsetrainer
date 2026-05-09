# Feature Specification: Universal Home Navigation

**Feature Branch**: `009-universal-home-nav`  
**Created**: 2026-05-08  
**Status**: Draft  
**Input**: User description: "Feature: Universal Home Navigation. As a user, I want a consistent way to return to the home screen from any practice mode so that I can switch modes or exit without system back gestures."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Home Button on Non-Home Screens (Priority: P1)

A user is on any screen other than the home screen and sees a consistent, visually distinct "<- Home" button in the upper left. Tapping it returns to the home screen cleanly.

**Why this priority**: This is the core behavior of the feature — without a visible and reliable home button, users cannot easily exit practice modes.

**Independent Test**: Can be tested by navigating to any non-home screen and verifying the home button is visible, tappable, and returns to the home screen.

**Acceptance Scenarios**:

1. **Given** I am on any screen that is NOT the home screen, **Then** I see a "<- Home" button in the upper left, **And** it is tappable and visually distinct.

---

### User Story 2 — No Home Button on Home Screen (Priority: P1)

The home button does not appear on the home screen itself, since the user is already there.

**Why this priority**: Showing a home button on the home screen would be confusing and redundant. This is part of the core completeness of the feature.

**Independent Test**: Can be tested by verifying the home button is absent when on the home screen.

**Acceptance Scenarios**:

1. **Given** I am on the home screen, **Then** I do NOT see a "<- Home" button.

---

### User Story 3 — Clean State Reset on Navigation (Priority: P2)

When the user taps "<- Home" from an active practice mode, the app cleanly stops all ongoing activity and saves progress before transitioning.

**Why this priority**: Leaving audio playing or buffers uncleared would degrade user experience. Saving progress ensures learning data is not lost. However, the basic navigation works even without this cleanup.

**Independent Test**: Can be tested by entering Common Words or Decoder mode, tapping "<- Home", and verifying audio stops, buffers clear, and session progress is saved.

**Acceptance Scenarios**:

1. **Given** I am in Common Words or Decoder mode, **When** I tap "<- Home", **Then** I return to the home screen, **And** any active audio stops, **And** any in-progress tapping buffers are cleared, **And** the Smart Repetition Engine saves current session progress.

---

### Edge Cases

- What happens if the user taps "<- Home" while audio is still loading? The audio load is cancelled and the navigation proceeds.
- What happens if the user double-taps "<- Home" rapidly? Only the first tap is processed; the second is ignored while the transition is in progress.
- What happens if session save fails due to a storage error? The user is still navigated to the home screen; the failure is logged silently without blocking the UI.
- What happens on screens that already have a system back button or gesture? The "<- Home" button coexists with system navigation; both lead to the home screen.
- What happens on tablets or wide screens where the layout differs? The "<- Home" button maintains the same upper-left position and visibility rules regardless of screen size.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display a "<- Home" button in the upper left on every screen except the home screen.
- **FR-002**: The home button MUST be visually distinct from other UI elements.
- **FR-003**: The home button MUST be tappable and respond with visual feedback.
- **FR-004**: The system MUST NOT display the "<- Home" button on the home screen itself.
- **FR-005**: When the home button is tapped, the system MUST navigate to the home screen.
- **FR-006**: When navigating home from an active practice mode, the system MUST stop any playing audio.
- **FR-007**: When navigating home from an active practice mode, the system MUST clear any in-progress tapping buffers or keyer state.
- **FR-008**: When navigating home from an active practice mode, the system MUST save current session progress to the Smart Repetition Engine before the transition completes.
- **FR-009**: The system MUST ignore duplicate taps on the home button while a navigation transition is already in progress.
- **FR-010**: If session save fails, the system MUST still complete navigation to the home screen and log the failure without showing an error to the user.

### Key Entities

- **HomeButton**: A persistent navigation control present on all non-home screens. Key attributes: visibility (hidden on home screen), tap target, visual style.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can return to the home screen from any non-home screen in a single tap.
- **SC-002**: 100% of non-home screens display the home button; 0% of home screen views display it.
- **SC-003**: Audio stops within 200 ms of the home button being tapped.
- **SC-004**: Session progress is saved successfully in ≥ 99% of home navigation events.
- **SC-005**: Users rate the home navigation as "easy to find" in ≥ 90% of qualitative feedback responses.

## Assumptions

- The app already has a home screen defined as the primary landing view.
- The existing navigation system supports programmatic routing to the home screen.
- The app has an active audio playback service that can be stopped on demand.
- The Smart Repetition Engine supports saving partial session progress.
- The "<- Home" button uses standard iconography (back arrow + "Home" text) and matches existing app theming.
