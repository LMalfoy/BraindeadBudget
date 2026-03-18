# Iteration 2.0.2 Spec

## Title

Friction And UI Polish

## Goal

Refine the first `2.0` friction improvements by making the quick-add affordances clearer, more compact, and more visually consistent.

## Scope

- reduce the quick-add widget to a more compact, button-like presentation
- make the widget label more direct:
  - `Add Expense`
- make the `Save Expense` action state clearer when title and amount are missing
- unify the primary green used by:
  - dashboard `+ Add Expense`
  - expense-entry `Save Expense`
- make dashboard `Recent Expenses` rows tappable
- tapping a recent expense should open the history sheet in the appropriate context

## Out Of Scope

- new widget presets
- dashboard metrics or redesign
- new statistics modules
- streaks, achievements, or reports
- editing flow redesign
- history architecture changes

## UI / UX Expectations

- the widget should feel like a single, obvious CTA rather than a tiny dashboard card
- the widget should use a wider, flatter family if that produces a clearer result
- `Save Expense` should never feel dead or broken
- invalid save state should be visually obvious before the user taps
- green primary actions should look like part of one design system
- `Recent Expenses` should feel intentionally interactive, not merely displayed

## Data Changes

- no model or persistence changes are required
- the history-opening behavior may need lightweight routing state only

## Tests

- verify the widget still deep-links into add expense correctly
- verify the add-expense save action clearly reflects invalid state
- verify recent-expense taps open history reliably
- verify no existing add-expense, dashboard, or history behavior regressed

## Why This Matters

- these are high-frequency touchpoints
- the app now feels close enough to finished that small UX inconsistencies stand out
- this is the right time to fold several related polish fixes into one stable pass
