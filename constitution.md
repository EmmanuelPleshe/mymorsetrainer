# Project Constitution

This document defines the binding principles and practices for all development on this project. It supplements CLAUDE.md and takes precedence for process and methodology questions.

---

## Test-Driven Development Covenant

### Core Principle
Every feature, bug fix, and refactor begins with a failing test. No exceptions. Implementation without a preceding failing test is considered incomplete and must be reverted.

### The Red-Green-Refactor Ritual
For every task:

1. **Red**: Write a failing test that describes the desired behavior or reproduces the bug. Commit: `test: add failing test for [description]`.
2. **Green**: Write the minimal implementation to make the test pass. Commit: `feat: implement [description]`.
3. **Refactor**: Clean the implementation while keeping all tests green. Commit: `refactor: clean up [area]`.
4. **Verify**: Run the full test suite (`flutter test`). All tests must pass. Commit: `ci: all tests passing`.
5. **Declare Done**: A feature is only "done" when accompanied by passing tests, test file names, and test output.

### Test Coverage Requirements
- **Game loop** (BLoC, input handler, audio service): 100% coverage. This is safety-critical.
- **Logging**: 100% coverage. Async file operations are prone to race conditions.
- **UI screens**: Widget tests for all user-facing state transitions.
- **Domain services** (Koch progression, spaced repetition, gamification): 100% coverage.
- **Repositories**: Mocked unit tests for all public methods.

### Infrastructure
- Tests live in `test/` and mirror `lib/` structure exactly.
- Dependencies: `flutter_test`, `bloc_test`, `mocktail` (preferred over `mockito` for null safety), `fake_async`.
- `test/helpers/` contains shared mocks, `TestHarness`, and setup utilities.
- No real file system, network, or audio hardware in unit tests. Everything is mocked or faked.

### Regression Tests
Every bug fix must include a regression test named `regression: [brief description]`. This test stays forever. If a regression test fails after a refactor, the refactor is wrong.

### "Done" Criteria
Before any task is declared complete:
- [ ] Failing test was written first (red phase)
- [ ] Implementation makes test pass (green phase)
- [ ] Refactoring is complete with no test changes
- [ ] `flutter test` passes with zero failures
- [ ] New tests are documented in commit messages
- [ ] Test output is included in the "done" declaration

### CI Gate
The GitHub Actions workflow (`flutter.yml`) must run `flutter test` on every push and pull request. A failing test suite blocks merge to `main`.

### Specify Integration
When Specify generates code, it must:
1. Generate corresponding tests using the same patterns and mocks
2. Follow the red-green-refactor sequence
3. Never declare a feature complete without test verification

---

## Documentation Covenant

### Core Principle
Every feature, bug fix, and behavior change must ship with user-facing documentation. Silent features are broken features. No exceptions.

### The Docs TDD Ritual
For every task:

1. **Red**: Add a FAILING scenario to `test/docs/user_scenarios.md` describing what the user must be able to understand or accomplish.
2. **Green**: Write the minimal docs/help/tooltips to make the scenario PASSING.
3. **Refactor**: Improve clarity and completeness while keeping the scenario PASSING.
4. **Verify**: Update `user_scenarios.md` status to PASSING with a note.

### Mandatory Help Surfaces
At least one of these must be updated for every user-visible change:
- `README.md` for setup and high-level concepts
- `lib/ui/screens/help_screen.dart` for in-app reference
- `lib/ui/screens/practice_screen.dart` bottom sheet for inline contextual help
- `lib/ui/screens/settings_screen.dart` tooltips for configuration options
- `test/docs/user_scenarios.md` scenario coverage

### Scenario Baseline
The 7 scenarios in `test/docs/user_scenarios.md` are the permanent baseline. All must remain PASSING. New features must add new scenarios or extend existing ones.

### Regression Docs
Every known bug must have a Troubleshooting/FAQ entry before the fix is declared complete. If users hit it once, future users will too.

### "Done" Criteria (Docs)
- [ ] Failing scenario was written first (red phase)
- [ ] Docs make the scenario PASSING (green phase)
- [ ] `user_scenarios.md` status updated with note
- [ ] Help surfaces reviewed for consistency

### CI Gate
`flutter test` must pass, and `test/docs/user_scenarios.md` must have zero FAILING scenarios before merge to `main`.

---

## Definition of Done

A task is complete when:
- All code compiles without errors or warnings
- `flutter test` passes with 100% of relevant tests
- Code follows the architecture rules in CLAUDE.md
- Tests cover the new logic per the Testing Doctrine above
- User-facing docs cover the change per the Documentation Covenant above
- `test/docs/user_scenarios.md` has zero FAILING scenarios
- Commit message follows conventional commits format

---

## Architecture Principles

### BLoC Rules
- BLoC owns ALL state transitions
- UI never triggers events during build()
- Side effects (audio, haptics, navigation) belong in UI listeners, not BLoC

### Input Handling
- Input handlers are stateless pipelines
- Raw input decoders must not hold UI state or call setState

### State Machine Requirements
- All session states must be explicit (no overloaded null states)
- Race conditions between timer and state transitions must be tested

---

## Process Guidelines

### Commit Message Format
```
<type>: <subject>

<body>

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

Types: `feat`, `fix`, `refactor`, `test`, `ci`, `docs`, `chore`

### Branch Naming
- Feature: `feature/<description>`
- Bug fix: `fix/<description>`
- Refactor: `refactor/<area>`

### PR Requirements
- All tests passing
- No merge conflicts with main
- Description includes test plan

---

## Cross-References
- Testing Doctrine: see section above
- Morse Timing: see CLAUDE.md
- Koch Progression: see CLAUDE.md
- SM-2 Algorithm: see CLAUDE.md