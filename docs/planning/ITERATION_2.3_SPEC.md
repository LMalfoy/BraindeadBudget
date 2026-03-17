# Iteration 2.3 Spec

## Title

Total Spending Foundation

## Goal

Make the new `Total Spending` perspective actually useful by showing how much of the month is already structurally committed and how those fixed costs are distributed.

## User Outcome

When the user switches to `Total Spending`, they should be able to understand:

- what share of their monthly income is already committed to recurring costs
- which recurring-cost category dominates their fixed financial structure

## Scope

### 1. Fixed Cost Ratio

Add a module that shows:

- total recurring monthly cost
- recurring cost as a share of total monthly income

The interpretation should remain plain-language, for example:

- `More than half of your monthly income is already committed to fixed costs.`
- `Your recurring costs leave solid room for variable spending.`

### 2. Fixed Cost Distribution

Add a module that shows how recurring costs are distributed across the recurring-cost categories:

- Housing / Utilities
- Subscriptions
- Insurance
- Savings
- Debt

The module should:

- stay visually simple
- use a small, readable chart
- include a short interpretation that points to the dominant fixed-cost area

## Product Rules

- preserve the separation between `Budget Spending` and `Total Spending`
- do not feed fixed-cost statistics into the behavioral rank system
- keep recurring-cost categories intentionally broad
- avoid dense financial dashboards

## Technical Direction

- add only the minimum recurring-cost categorization support required for these modules
- keep recurring-cost aggregation logic separate from the view
- keep empty states explicit and calm

## Out Of Scope

- subscription count/load
- savings stability
- recurring-cost trend history
- redesign of recurring-expense editing flows
