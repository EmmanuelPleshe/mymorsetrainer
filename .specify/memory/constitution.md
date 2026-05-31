# MorseTrainer Constitution

## Core Principles

### I. Cross-Platform Target
App must build and run on Linux and Android. Consider Qt6 or Flutter for cross-platform audio timing precision.

### II. Multi-Input Support
Support four input methods: keyboard, touchscreen tap, game controller, and audio input (microphone or key plugged into mic/line-in port). All treated as a straight key. No special timing modes - real straight key emulation.

### III. Koch Method Learning
Learning follows the Koch method: start with K and M only, achieve 90% accuracy before adding next letter, progressive alphabet acquisition.

### IV. Interactive Keying Loop
Core interaction: play character audio → wait for user to key it back → verify accuracy → feedback → next character. Always this sequence, never passive listening only.

### V. Spaced Repetition
Implement spaced repetition for memory reinforcement. Track per-character performance, schedule reviews based on Ebbinghaus forgetting curve. Intervals: 2 days → 7 days → 30 days → 90 days as mastery increases.

### VI. Progressive Difficulty
Koch Level: 2 characters → 4 → 6 → full alphabet → common words → QSO phrases. Each level requires 90% accuracy before advancement.

### VII. Gamification
Award points for correct responses, streak bonuses, level completions. Visual progress tracking to reinforce learning motivation.

### VIII. Script + Skill (Cost Control Rule)
Never do the same manual sequence twice. If a workflow repeats, script it in `scripts/` and skill it in `.claude/skills/` or `~/.hermes/skills/`. Applies to: worktree creation, test + lint + commit, PR creation, release deploy, environment setup (Qt6/Flutter toolchain), running the full test suite. Future sessions execute skills in one turn instead of burning tokens repeating commands.

---

## Git Workflow

### Branch Policy

| branch   | purpose                               | protected? |
|----------|---------------------------------------|------------|
| `main`   | production — deployable at all times | yes (PR required) |
| `dev`    | integration branch for PRs           | yes (PR required) |
| `feat/*` | feature work on worktrees             | no (personal) |
| `fix/*`  | bugfix work on worktrees              | no (personal) |

### Worktree-First Rule

Every AI-driven coding session MUST start on a fresh worktree.

```bash
./scripts/worktree.sh my-feature
cd .claude/worktrees/my-feature
```

All PRs from worktrees target the `dev` branch. Only `dev` merges to `main` after CI passes.

### Test-Driven Development (TDD)

Implement failing test first, then make it pass. For Qt6/Flutter projects, use `catch2` or QtTest for C++ and `flutter_test` for Dart. No code merges to main without passing tests.

### Commit Style

Issue-driven: `feat(koch): add level 5 characters (#22)`
All PRs must reference a GitHub issue.

---

## Script + Skill Register

| Skill / Script | Path | Purpose |
|----------------|------|---------|
| worktree.sh | `scripts/worktree.sh` | Create a new Git worktree for feature work |
| (add rows as created) | | |

---

## Governance

Amendments require description. Version: MAJOR for architecture, MINOR for principles, PATCH for clarifications.

**Version**: 1.0.0 | **Ratified**: 2026-04-19 | **Last Amended**: 2026-04-19