# Iteration 1.4 Specification

## Goal

Polish the monthly history screen so it feels more cohesive, lighter, and more aligned with the rest of the app.

## In Scope

- reuse the add-expense style editor for history editing
- remove the redundant `Monthly Expenses` section heading
- replace the current oversized month/year picker presentation with a lighter one
- keep history editing, deletion, and month navigation behavior intact

## Out Of Scope

- category drill-down
- dashboard redesign
- branding changes
- deeper settings work
- new budgeting rules

## UX Direction

The history screen should feel like a refined working area, not a prototype with stacked default presentations.

That means:

- editing should visually match the app’s main expense-entry language
- the list should not carry redundant section labels
- month selection should feel compact and proportional to its purpose

## Acceptance Criteria

- editing an expense from history uses the same style language as the add-expense flow
- the redundant `Monthly Expenses` title is removed
- month/year selection opens in a lighter presentation than the current full-page sheet
- history still supports adjacent-month arrows, editing, and deletion
- existing totals and carryover behavior remain unchanged

## Validation Plan

- build the project
- run calculation and store tests relevant to history behavior
- run focused UI tests for opening history, editing, and month selection
- manually confirm the new editor and picker feel visually lighter and more consistent
