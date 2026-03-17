# PocketBudget v0.2 Implementation Checklist

This is the final pre-coding checklist for `v0.2: Budget Foundation Setup`.

The goal is to implement the new monthly budget baseline in small, low-risk steps without mixing in later features like categories, charts, or smart parsing.

## Execution Order

### 1. Add New Baseline Models

- create `IncomeItem`
- create `RecurringExpenseItem`
- keep fields minimal: `id`, `name`, `amount`, `createdAt`
- update the app model container so these new models are persisted

Definition of done:

- project builds with the new models included
- no existing expense features are broken by the model container update

### 2. Add Calculation Logic

- add helpers for total monthly income
- add helpers for total recurring monthly commitments
- add helper for calculated available monthly spending budget
- update remaining budget calculation to use the calculated baseline instead of the old manual budget value

Definition of done:

- calculations live in `BudgetStore` or one small calculation helper
- no calculation logic is duplicated in SwiftUI views

### 3. Add Unit Tests For Budget Calculations

- test single income item calculation
- test multiple income items
- test multiple recurring commitments
- test available budget with no recurring commitments
- test available budget when commitments exceed income
- test remaining budget after subtracting current-month expenses

Definition of done:

- the new calculation rules are covered before UI wiring gets deeper

### 4. Add Persistence APIs In `BudgetStore`

- add save/fetch/update/delete support for income items
- add save/fetch/update/delete support for recurring commitment items
- keep validation simple and explicit
- keep existing expense APIs working

Definition of done:

- the store supports baseline setup and later editing
- invalid names or non-positive amounts are rejected consistently

### 5. Add Storage Tests

- test saving income items
- test saving recurring commitment items
- test editing an existing income item
- test editing an existing recurring commitment item
- test deleting baseline items
- test that calculation results stay correct after persistence changes

Definition of done:

- baseline data behavior is covered independently of the UI

### 6. Build The Full-Screen First-Run Setup Flow

- detect whether baseline setup is incomplete
- present a full-screen onboarding/setup flow
- require at least one income item before completion
- allow zero or more recurring commitment items
- show a live summary:
  - total income
  - total recurring commitments
  - calculated available monthly spending budget
- save the setup and dismiss into the main app

Definition of done:

- a first-time user can complete setup without touching the old budget screen
- the app does not fall through to a misleading dashboard before setup is complete

### 7. Integrate The Dashboard With The New Baseline

- replace the old manual monthly budget display with the calculated available monthly spending budget
- continue showing spent this month
- continue showing remaining budget
- remove or demote the old manual budget behavior so there is only one source of truth

Definition of done:

- the dashboard reflects the new budgeting model correctly
- remaining budget updates after expenses are added

### 8. Add Baseline Management After Onboarding

- add a simple management screen or sheet reachable from the dashboard
- show current income items
- show current recurring commitment items
- use separate add/edit sheets for each item type
- allow deleting items
- keep a recalculated summary visible

Definition of done:

- the user can update recurring costs and income later without rerunning onboarding

### 9. Add Narrow UI Tests

- first launch shows the full-screen setup flow
- setup cannot finish without at least one income item
- user can save setup with one income item and optional recurring items
- dashboard shows calculated values after setup

Definition of done:

- the main baseline flow is protected against regression

### 10. Final Cleanup Before Moving To v0.3

- remove dead code related to the old manual monthly budget flow if no longer needed
- confirm naming stays consistent across models, store methods, and UI labels
- run the full build and test suite
- do one manual simulator pass through setup, dashboard, expense entry, and baseline editing

Definition of done:

- `v0.2` ships with one coherent budgeting model

## Guardrails

Do not include in `v0.2`:

- categories
- chart visualizations
- central large add-expense button redesign
- smart single-line parsing
- broad dashboard redesign beyond what is necessary

These belong to later iterations and should not be mixed into the baseline work.

## Recommended Coding Sequence

If coding starts immediately after this checklist, use this order:

1. models
2. calculation helpers
3. unit tests
4. store persistence APIs
5. storage tests
6. first-run setup UI
7. dashboard integration
8. baseline management UI
9. UI tests
10. cleanup and verification

## Exit Criteria For v0.2

`v0.2` is complete when:

- the app calculates monthly available spending budget from income and recurring commitments
- first launch is guided by a full-screen setup flow
- the dashboard uses the calculated value as the source of truth
- the user can later edit income and recurring commitment items
- tests cover the new calculation and persistence behavior
