# Iteration 2.0.1 Spec

## Title

Friction Reduction

## Goal

Make expense entry feel faster and more direct without changing the app's core budgeting model.

## Scope

- add a `Quick Add Expense` WidgetKit widget
- widget tap should deep-link directly into the add-expense flow
- add direct keyboard submission for the amount field in expense entry
- review and standardize terminology where the same concept is named differently across the app

## Out Of Scope

- dashboard redesign
- streaks or achievements
- weekly reports
- category drill-down
- savings goals or planning tools
- broader stats redesign

## UI / UX Expectations

- widget should be visually simple and obvious
- widget tap should open the app directly into expense entry, not just the dashboard
- amount entry should be finishable with one bottom-of-screen interaction instead of forcing a reach to the navigation bar
- terminology changes should improve clarity without renaming unrelated concepts

## Data Changes

- no persistent model changes are required
- the widget may need a lightweight deep-link route into the existing app structure

## Tests

- verify widget deep link opens the add-expense flow correctly
- verify expense can be saved directly from amount entry using the keyboard toolbar/done action
- verify no existing add-expense behavior broke
- verify any renamed labels remain consistent across dashboard, statistics, and recurring-spending screens

## Why This Matters

- expense capture is the app's main habit loop
- small friction improvements in the capture flow have very high leverage
- this is the safest first step into the `2.0` product phase
