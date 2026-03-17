# PocketBudget v0.2 Implementation Spec

## Iteration Goal

Replace the current manually entered monthly budget value with a calculated monthly spending budget based on:

`total monthly income - total recurring monthly commitments`

This iteration should establish the financial baseline for the app without yet redesigning the full expense-entry experience.

## Why This Iteration Comes Next

The rest of the product depends on this number being correct.

Before improving expense entry, categories, or charts, the app needs a reliable answer to:

"How much money is actually available for day-to-day spending this month?"

## Scope

In scope:

- support monthly income items
- support recurring monthly commitment items
- calculate available monthly spending budget
- show the calculated budget on the dashboard
- add a simple first-run setup flow
- allow editing the baseline setup after first launch
- add tests for calculation and persistence

Out of scope:

- categories
- chart visualizations
- smart single-line input
- expense deletion or editing
- broad UI redesign beyond what is needed for setup and display

## Product Behavior

### Budget Calculation

Definitions:

- `monthly income`: money coming in each month
- `recurring monthly commitments`: fixed or planned amounts that should be reserved before variable spending
- `available monthly spending budget`: the amount left after subtracting commitments from income

Formula:

`available monthly spending budget = sum(income items) - sum(recurring commitment items)`

Remaining budget on the dashboard:

`remaining budget = available monthly spending budget - current month variable expenses`

### First-Run Experience

If the user has not completed baseline setup, the app should not behave as if a budget already exists.

Instead, it should:

- show a setup-focused full-screen flow
- ask the user to enter income items
- ask the user to enter recurring commitment items
- show the calculated available monthly spending budget before saving

The first version should favor clarity over cleverness.

The full-screen setup should block the normal dashboard flow until the baseline has been completed.

### Editing Baseline Values

After setup, the user should be able to:

- review income items
- review recurring commitment items
- add a new item
- edit an existing item
- delete an existing item

This can live in a simple management screen or sheet.

For v0.2, the lower-risk implementation is a management screen with separate add/edit sheets for individual items rather than inline editing.

## Proposed Data Model

To keep risk low, add two small models instead of overloading `BudgetSettings`.

### `IncomeItem`

Fields:

- `id`
- `name`
- `amount`
- `createdAt`

Purpose:

- stores one monthly income source

Examples:

- Salary
- Freelance
- Child Benefit

### `RecurringExpenseItem`

Fields:

- `id`
- `name`
- `amount`
- `createdAt`

Purpose:

- stores one recurring monthly commitment

Examples:

- Rent
- Electricity
- Internet
- Savings

### `BudgetSettings`

Keep `BudgetSettings`, but simplify its responsibility.

Recommended role:

- app-level preferences that are not lists of financial items
- example: `currencyCode`

Recommended change:

- stop treating `monthlyBudget` as the source of truth once v0.2 ships

## Calculation API Proposal

Add calculation helpers that are easy to test independently.

Recommended responsibilities:

- sum all income items
- sum all recurring expense items
- compute available monthly spending budget
- compute remaining budget after variable expenses

These should stay in `BudgetStore` or a small calculation helper rather than being spread across views.

## Screen Changes

### 1. First-Run Setup Full-Screen Flow

Purpose:

- collect baseline monthly financial inputs

Minimum UI:

- section for income items
- section for recurring monthly commitment items
- button to add another row in each section
- live summary of:
  - total income
  - total recurring commitments
  - calculated available monthly spending budget
- save action

Low-risk implementation note:

- a simple form with editable rows is better than building a complex wizard
- this should still be presented as a full-screen guided flow, even if the UI itself is a single form screen

### 2. Dashboard

Changes needed in this iteration:

- replace the old manual monthly budget display with the calculated available monthly spending budget
- continue showing spent this month
- continue showing remaining budget
- if setup is incomplete, show a clear call to action to complete setup

Not yet required in this iteration:

- central large add-expense button
- category chart

Those should come in later iterations to keep this change set narrow.

### 3. Baseline Management Screen

Purpose:

- let the user update income and recurring commitments after first launch

Minimum UI:

- list current income items
- list current recurring commitment items
- add/edit/delete controls
- recalculated summary

Implementation choice:

- use separate sheets for adding and editing items
- avoid inline row editing in v0.2

## Suggested Delivery Plan

Implement this in small steps:

### Step 1: Foundation Models and Calculations

- add `IncomeItem`
- add `RecurringExpenseItem`
- add calculation helpers
- add unit tests for sums and available budget calculation

### Step 2: First-Run Setup

- detect missing baseline data
- present full-screen setup UI
- persist entered items
- add tests for first save behavior

### Step 3: Dashboard Integration

- use the calculated budget on the dashboard
- show remaining budget from calculated baseline minus current month expenses
- add regression tests for updated budget logic

### Step 4: Baseline Editing

- allow add/edit/delete for income and recurring items
- ensure dashboard updates correctly afterward

This sequencing reduces risk and keeps each sub-step reviewable.

## Acceptance Criteria

### Functional

- A user can add at least one monthly income item.
- A user can add zero or more recurring monthly commitment items.
- A user cannot complete setup without at least one monthly income item.
- The app calculates available monthly spending budget as income minus recurring commitments.
- The dashboard uses that calculated value as the monthly budget baseline.
- The remaining budget updates correctly after variable expenses are added.
- A user can revisit and update baseline values after setup.

### UX

- On first launch, the app clearly guides the user into setup.
- The setup flow is full-screen and blocks entry into the main app until baseline data is provided.
- The setup flow explains what the calculated monthly spending budget means.
- The dashboard does not show misleading budget values when setup is incomplete.
- The UI remains simple and understandable for a non-technical user.

### Engineering

- Calculation logic is covered by focused unit tests.
- Persistence behavior is covered by storage tests.
- Existing expense calculation behavior still works after the change.

## Test Plan

### Unit Tests

Add tests for:

- summing multiple income items
- summing multiple recurring commitment items
- available budget calculation with one income and one commitment
- available budget calculation with multiple items
- available budget calculation when there are no recurring commitments
- remaining budget calculation after subtracting current-month expenses

### Persistence Tests

Add tests for:

- saving income items
- saving recurring commitment items
- updating an existing item
- deleting an item
- keeping budget settings and list items consistent

### UI Tests

Keep UI tests narrow:

- first launch shows setup flow
- user can save baseline setup
- dashboard shows calculated budget afterward

## Edge Cases

Handle these explicitly:

- income total equals zero
- recurring commitments exceed income
- empty item names
- zero or negative amounts
- multiple income sources
- no recurring commitments

Product note:

If recurring commitments exceed income, the app should still calculate and show a negative available budget rather than hiding the result.

Savings plans should be treated as recurring commitments by default.

## Resolved Decisions

1. At least one income item is required before setup can finish.
2. Savings plans are treated as recurring commitments by default.
3. Income and recurring commitment items should use separate add/edit sheets in v0.2.
4. Onboarding should be a full-screen flow that guides the user through the initial budget calculation.

## Recommended Implementation Approach

Keep v0.2 deliberately conservative:

- do not redesign the whole dashboard yet
- do not introduce categories yet
- do not attempt smart parsing yet
- focus on correct data, correct calculations, and a clear first-run setup path

If this ships cleanly, later iterations can safely optimize speed and insight on top of a trustworthy budget baseline.
