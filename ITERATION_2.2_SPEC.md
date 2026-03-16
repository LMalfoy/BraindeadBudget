# Iteration 2.2 Spec

## Title

Statistics Perspective Split

## Goal

Introduce a second statistics perspective for recurring-cost structure without disturbing the existing behavioral statistics flow.

## User Outcome

The user should be able to open the Statistics area and clearly switch between:

- `Budget Spending`
- `Total Spending`

`Budget Spending` should remain the current behavioral view.

`Total Spending` should become the entry point for future recurring-cost statistics.

## Scope

### 1. Add Perspective Switch

At the top of the Stats screen, add a simple switch:

- `Budget Spending`
- `Total Spending`

The control should:

- be visually quiet
- feel native and easy to understand
- keep the current Stats layout readable

### 2. Preserve Budget Spending

The existing behavioral statistics flow should remain intact:

- discipline rank
- budget trajectory
- carryover
- month comparison
- spending pattern
- spending by category

This iteration should not redesign or recalculate those modules.

### 3. Add Total Spending Shell

Create the second perspective as a real screen state inside Stats.

For now it should:

- establish the layout and identity of the fixed-cost perspective
- prepare the user for future recurring-cost insights
- handle empty and not-yet-implemented states cleanly

## Product Rules

- do not mix recurring-cost insights into the behavioral rank system
- do not add all fixed-cost statistics at once
- keep the UI simple and understandable
- preserve the current app stability

## Technical Direction

- keep the perspective state inside the Stats feature
- avoid introducing broad architecture changes
- keep the split modular enough that future fixed-cost modules can be added safely

## Out Of Scope

- recurring-cost statistics modules themselves
- recurring-cost category assignment UX
- changes to the discipline-rank logic
- redesign of Settings or baseline setup flows
