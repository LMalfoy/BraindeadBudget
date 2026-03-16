# Iteration v3.0 Spec

## Title
Settings Foundation Pass

## Goal
Expand Settings into a practical utility area without turning it into a complex control panel.

## Scope
- add appearance selection:
  - `System`
  - `Light`
  - `Dark`
- add currency selection
- add destructive `Erase All Data` action with clear confirmation
- keep version/build display visible and polished

## Explicitly Out Of Scope
- budget period anchor setting
- category customization
- color customization
- broader settings redesign outside these utilities

## Product Rules
- Settings must stay simple and easy to understand.
- Appearance should use a three-way choice, not just a dark-mode toggle.
- Currency should be configurable in-app.
- `Erase All Data` must require strong confirmation.
- Reset must clear persisted budgeting data safely and predictably.

## UI Direction
- keep settings grouped into small clear sections:
  - Preferences
  - Budget
  - Danger Zone
  - About
- destructive actions should be visually separated from normal preferences
- version/build info remains in About

## Verification Targets
- settings screen opens
- appearance choice persists
- currency choice persists
- erase-all flow requires confirmation
- erase-all flow returns the app to onboarding state
