# Iteration 2.0.6 Spec

## Goal
Add a compact dashboard streak indicator that visualizes the user's current safe-spending streak without changing the existing budgeting logic.

## Scope

- show the current safe-spending streak in the dashboard budget overview card
- place the indicator in the lower-right area of the card
- use a blue flame symbol as the main icon
- overlay a small circular count badge in the flame's lower-right corner
- reuse the existing safe-spend streak logic already present in the app

## Out of Scope

- no new achievements
- no new statistics modules
- no new dashboard calculations beyond exposing the existing streak
- no UI redesign of the dashboard card outside the indicator
- no changes to achievement rules

## UI / UX Expectations

- the streak indicator should feel secondary to `Remaining` and `Daily Safe Spend`
- it should be compact and legible in both light and dark mode
- the streak count should be easy to scan at a glance
- if the streak is zero, the UI may either hide the badge or show a neutral zero state, but this must be decided consistently during implementation

## Data / Logic Notes

- use the existing `BudgetStore.safeSpendStreak(...)` logic
- avoid recalculating the streak multiple times in separate dashboard paths
- if dashboard derivations are touched, keep them centralized and lightweight

## Tests

- add calculation coverage for streak values where needed
- verify dashboard-facing streak data is derived correctly
- ensure existing dashboard calculations still behave as before
- build the project after implementation
