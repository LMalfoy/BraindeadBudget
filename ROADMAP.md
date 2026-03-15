# PocketBudget Roadmap

## Planning Approach

PocketBudget should grow through small, low-risk iterations. Each iteration should produce one clear product improvement, remain testable, and avoid bundling multiple major changes together.

The roadmap below reflects the updated product direction:

- calculate the monthly spending budget from income and recurring commitments
- make expense entry extremely easy
- show remaining budget and category insights immediately on launch

## Current State: v0.1

Implemented now:

- manual monthly budget setting
- manual expense entry
- current month summary
- local persistence
- baseline unit tests for storage and month-based calculations

Main gaps versus target product:

- no onboarding or first-run setup
- no income tracking
- no recurring monthly commitments
- no calculated spending budget
- no expense categories
- no chart-based overview
- no ultra-fast expense entry mode
- no edit or delete flow for recorded expenses

## Roadmap Themes

- Build a trustworthy monthly budget baseline
- Remove friction from daily expense capture
- Make the dashboard instantly useful
- Keep implementation small and testable

## Proposed Iterations

### Iteration 0.2: Budget Foundation Setup

Goal:
Replace the single manual budget number with a calculated monthly spending budget.

Scope:

- first-run setup flow
- support one or more monthly income items
- support recurring monthly commitment items
- calculate monthly spending budget from income minus recurring commitments
- update tests around budget calculation behavior

Why this matters:

- this is now the product’s most important calculation
- it defines the number the rest of the app depends on

Risk:
Medium

Validation:

- unit tests for monthly budget calculation logic
- unit tests for edge cases such as zero or multiple income items
- manual test of first-run setup and recalculation after editing values

### Iteration 0.3: Frictionless Expense Entry v1

Goal:
Make adding daily expenses much faster and simpler.

Scope:

- redesign add-expense flow around category, item, and amount
- use four fixed categories: Food, Transport, Household, and Fun
- make category selection the first and easiest interaction in the form
- keep date and note as secondary optional fields
- improve keyboard flow so the item field is ready immediately and submit moves to amount
- move the add-expense action to a bottom, thumb-friendly position
- show category visually in the expense list with restrained color coding

Why this matters:

- fast daily entry is the main product habit loop
- the app only works if recording an expense feels easy enough to do every time

Risk:
Low to medium

Validation:

- manual repeated-entry testing
- regression tests for validation behavior
- UI test for adding an expense with category and amount
- manual one-handed reachability check on common phone sizes

### Iteration 0.4: Dashboard Priority Layout

Goal:
Make the home screen immediately useful and action-oriented.

Scope:

- prioritize remaining budget visually
- show recent expenses clearly
- tighten empty states and first-run guidance
- refine the dashboard layout after the new bottom add-expense action is in place
- remove low-value visual noise such as redundant screen headlines
- keep date and note visible in the add-expense form while preserving a fast main flow
- improve list spacing, hierarchy, and readability without adding clutter

Why this matters:

- the app should answer the budget question instantly on open
- the primary action should always be obvious
- the app should feel polished, not just functional

Risk:
Low

Validation:

- manual UI review on common device sizes
- UI test for dashboard visibility and primary add-expense action
- manual pass on the add-expense form to confirm secondary fields remain easy to access

### Iteration 0.5: Category Overview

Goal:
Show where variable spending is going.

Scope:

- aggregate current-month expenses by category
- add a simple dashboard chart, likely a pie or donut chart
- highlight largest spending category clearly
- keep the chart limited to the current month and the four fixed categories
- ensure the chart supports the existing clean dashboard layout

Why this matters:

- category feedback turns tracking into decision support
- it helps the user spot the biggest spending bucket quickly

Risk:
Medium

Validation:

- unit tests for category aggregation
- manual visual checks for small and large category sets
- ensure chart does not crowd the dashboard
- verify zero-expense and single-category states remain readable

### Iteration 0.6: Expense Correction Basics

Goal:
Let the user fix mistakes in recorded spending.

Scope:

- delete an expense
- optionally add a simple edit flow if delete is already stable
- ensure totals update immediately after changes

Why this matters:

- fast entry increases the chance of small mistakes
- trust requires that errors can be corrected

Risk:
Low

Validation:

- unit tests for delete and recalculation behavior
- UI test for the basic correction flow
- manual check that dashboard totals update correctly

### Iteration 0.7: Smart Single-Line Entry

Goal:
Reduce entry friction further with intelligent parsing.

Scope:

- support single-line expense input such as `4 coffee` or `coffee 4`
- parse amount and item with clear fallback behavior
- keep manual structured entry available

Why this matters:

- this is the strongest opportunity to make the app feel notably faster
- it supports the core product principle of frictionless capture

Risk:
Medium to high

Validation:

- unit tests for parsing rules and ambiguous inputs
- manual testing with realistic examples
- clear failure behavior when parsing confidence is low

## Suggested Category Set For Early Versions

Start simple:

- Food
- Transport
- Household
- Fun

These can change later, but the first version should optimize for speed and clarity rather than perfect categorization.

## What To Avoid For Now

These ideas are likely too broad for the near term:

- bank integrations
- recurring expense auto-import
- advanced forecasting
- shared or family budgets
- large analytics dashboards
- major architecture rewrites

## Release Discipline

For each iteration:

1. Define a single user-visible outcome.
2. Keep the data model changes as small as possible.
3. Add or update tests for calculation and persistence logic.
4. Verify manually in the simulator.
5. Do not combine foundation work, UI redesign, and smart parsing into one release.
