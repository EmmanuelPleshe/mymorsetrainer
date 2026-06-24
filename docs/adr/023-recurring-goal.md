# ADR 023 – Add Recurring Goal feature

## Context
Users can only set a single, one‑off goal path. Many learners want a repeated practice schedule (daily, weekly, monthly) to build habit and track progress over time.

## Decision
Introduce a `RecurringGoal` aggregate with full management UI (create, edit, pause/cancel, view upcoming occurrences) and push‑notification reminders. The feature will be exposed under a new top‑level **Goals** tab, alongside the existing goal‑path UI.

## Consequences
- Adds a new data model (SQLite table) and domain‑logic layer.
- UI complexity increases modestly (new tab, forms, calendar view).
- Enables habit‑forming workflows, which should improve user retention.
- Requires background scheduling for reminders (e.g., Android AlarmManager / iOS notifications).
