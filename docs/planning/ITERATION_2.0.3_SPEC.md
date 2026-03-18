# Iteration 2.0.3 Spec

## Title

Dashboard Guidance

## Goal

Make the main dashboard card more actionable by adding a daily spending guide and removing one redundant number.

## Scope

- add `Daily Safe Spend` to the main dashboard card
- calculate it as:
  - `remaining budget / days left in current budget period`
- add a small info button inside the dashboard card
- the info action should explain:
  - `Remaining`
  - `Daily Safe Spend`
- remove `Available This Month` from the dashboard card

## Out Of Scope

- streaks
- achievements
- category drill-down
- dashboard redesign beyond the summary card
- new statistics modules
- weekly reports

## UI / UX Expectations

- `Remaining` should stay the visually dominant number
- `Daily Safe Spend` should read as a helpful guide, not a warning
- the info entry point should be small, visible, and unobtrusive
- the explanation should stay short and plain-language
- removing `Available This Month` should make the card feel simpler, not emptier

## Data Changes

- no persistence changes required
- only derived dashboard calculations are needed

## Tests

- verify `Daily Safe Spend` uses the current budget period correctly
- verify the dashboard info sheet opens and shows the expected explanation
- verify `Available This Month` is no longer shown
- verify no existing dashboard, onboarding, or expense-entry behavior regressed

## Why This Matters

- users need a day-to-day spending reference, not only a month-total number
- the dashboard should become more legible as features are added
- explanation is part of reducing friction, especially for first-time users
