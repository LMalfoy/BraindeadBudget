# PocketBudget v0.4 Implementation Spec

## Iteration Goal

Refine the dashboard and expense-entry presentation so the app feels cleaner, more intentional, and easier to scan every day.

This iteration is about polish with discipline. It should improve hierarchy and usability without expanding the data model or adding analytics features.

## Why This Iteration Comes Next

`v0.2` established the budget baseline and `v0.3` improved expense entry speed. The next step is to make the app feel more finished:

- the dashboard should communicate the right things instantly
- the expense form should keep useful fields visible without slowing down the main path
- the interface should lose any redundant or low-value UI

## Scope

In scope:

- remove redundant dashboard chrome such as the repeated PocketBudget headline
- improve summary-card hierarchy so remaining budget is clearly dominant
- refine spacing and readability of the expense list
- keep the bottom add-expense action in place and tune it if needed
- make date and note visible in the add-expense form again
- preserve the fast category -> item -> amount path while exposing secondary fields more cleanly
- improve empty-state wording and general UI polish where it directly improves comprehension

Out of scope:

- chart or pie visualization
- smart single-line entry
- editing or deleting expenses
- new budget model changes
- large visual redesign or theming work

## Product Decisions

### Dashboard Branding

The navigation title `PocketBudget` is not needed on the main dashboard.

Decision:

- remove the redundant dashboard headline if the screen already communicates its purpose through the layout itself

### Summary Hierarchy

The summary area should emphasize:

1. remaining budget
2. available to spend
3. spent this month

The user should be able to answer "how much is left?" immediately.

### Add-Expense Secondary Fields

Date and note should remain visible in the add-expense form.

Decision:

- keep category, item, and amount as the top priority
- show date and note directly below them without hiding behind a disclosure group
- maintain a clear visual distinction so the main path still feels fast

### General Visual Direction

The interface should remain minimal:

- color as accent, not decoration
- spacing and typography used to create clarity
- no heavy cards, gradients, or dense analytics elements in this iteration

## Screen Changes

### 1. Dashboard

Required changes:

- remove unnecessary headline duplication
- improve the hierarchy within the monthly summary
- ensure the bottom add-expense action still feels intentional and unobtrusive
- refine section spacing and list readability

### 2. Add Expense Sheet

Required changes:

- keep category tiles at the top
- keep item and amount as the central fields
- show date and note directly in the form
- make sure the form still feels fast rather than bloated

### 3. Expense List

Required changes:

- improve scanning of recent expenses
- tune category chip/marker balance if needed
- keep rows compact and clean

## Acceptance Criteria

### Functional

- the main dashboard no longer shows redundant app-name UI
- date and note are visible in the add-expense screen
- the add-expense flow still works with the current category-first entry path

### UX

- remaining budget is the most visually prominent budget number
- the expense list is easy to scan without feeling crowded
- the add-expense form exposes secondary fields without harming the primary flow
- the app feels cleaner after these changes, not more complex

### Engineering

- no new persistent model changes are introduced unless strictly necessary
- existing tests continue to pass
- UI changes remain localized and low-risk

## Test Plan

### UI Tests

Add or update tests for:

- add-expense flow still works with visible date and note fields
- dashboard still exposes the primary add-expense action

### Manual Checks

- confirm the dashboard no longer feels top-heavy
- confirm remaining budget is the first number the eye lands on
- confirm date and note are visible but not distracting
- confirm the bottom add-expense button still feels reachable and clear
- confirm expense rows are readable with multiple categories present

## Recommended Implementation Approach

Implement `v0.4` in this order:

1. adjust dashboard hierarchy and title behavior
2. refine add-expense form layout
3. tune expense row spacing and readability
4. run manual UI review and tests

This keeps the iteration small and primarily presentational.
