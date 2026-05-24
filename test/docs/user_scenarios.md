# Documentation User Scenario Tests

These scenarios test whether documentation and in-app help allow users to accomplish common goals. Each scenario is marked **FAILING** until sufficient documentation exists.

---

## Scenario 1: Onboarding — Understanding the Koch Method

**Status: PASSING** (added to README.md and onboarding_screen.dart)

- **User goal**: New user installs app, wants to know what "Koch method" means and why they should use it.
- **Doc assertion**: README must have "What is the Koch Method?" section (2 paragraphs max). App must have onboarding that explains it.

---

## Scenario 2: First Practice — How to Key Input

**Status: PASSING** (added help bottom sheet to practice_screen.dart)

- **User goal**: User is on Level 1, hears a character, doesn't know how to key it on their keyboard.
- **Doc assertion**: Practice screen must have a "?" button or inline help explaining how to key (hold Spacebar for dit/dah, release to submit).

---

## Scenario 3: Settings — Understanding WPM, Eff WPM, Word Space

**Status: PASSING** (added Tooltip icons to each slider in settings_screen.dart)

- **User goal**: User wants to slow down audio. Opens Settings, sees "Speed (WPM)", "Effective Speed (Farnsworth)", "Extra Word Space" — doesn't understand any of them.
- **Doc assertion**: Each setting needs a one-sentence tooltip or info icon explaining it. Settings labels should have `?` icons that show Tooltip on tap.

---

## Scenario 4: Progress — When Can I Advance to Next Level?

**Status: PASSING** (added to help_screen.dart Progression section)

- **User goal**: User finishes session, sees "Accuracy: 75%", wants to know if they're ready for Level 2.
- **Doc assertion**: Post-session results must show "Next level at 90% accuracy" or similar. Help docs must explain progression logic.

---

## Scenario 5: Bug Report — Is It My Fault or a Known Issue?

**Status: PASSING** (added Troubleshooting & FAQ section to help_screen.dart)

- **User goal**: User experiences the stuck-state bug (feedback stays forever). Wants to know if it's a known issue before reporting.
- **Doc assertion**: App must have Help screen with "Troubleshooting" or "FAQ" section. Known bugs should be documented.

---

## Scenario 6: Practice Feedback — What Do the Colors Mean?

**Status: PASSING** (added color legend to practice_screen.dart bottom sheet)

- **User goal**: User wants to understand the visual feedback (blue waiting state, green correct, red wrong).
- **Doc assertion**: Inline help on practice screen must explain: Blue = waiting for input, Green = correct, Red = wrong.

---

## Scenario 7: Timeout — Why Did It Submit Early?

**Status: PASSING** (added timeout explanation to practice_screen.dart bottom sheet and help_screen.dart)

- **User goal**: User released key briefly and pattern submitted early. Wants to know if they can adjust timing.
- **Doc assertion**: Help must explain "Pattern submits after Xms of silence" and link to Input Timeout setting.

---

## Running These Tests

To mark a scenario as **PASSING**:
1. Add sufficient documentation (README update, help screen content, tooltips, etc.)
2. Update this file: change `FAILING` to `PASSING` and add a note about what was added

Example after Scenario 1 passes:
```markdown
## Scenario 1: Onboarding — Understanding the Koch Method

**Status: PASSING** (added to README.md and onboarding_screen.dart)
```
