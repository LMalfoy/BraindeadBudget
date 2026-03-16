# PocketBudget v1.0 Implementation Checklist

This is the final pre-coding checklist for `v1.0: Full Carryover Budgeting`.

The goal is to make monthly budget calculations continuous across periods while keeping the app small and understandable.

## Execution Order

### 1. Define Carryover Calculation

- add helper logic for previous-month remainder
- keep the rule explicit and month-based

Definition of done:

- carryover is calculable in isolation from the UI

### 2. Add Unit Tests First

- cover positive carryover
- cover negative carryover
- cover no previous-month data
- cover month-boundary correctness

Definition of done:

- the new budgeting rule has clear automated coverage

### 3. Wire Carryover Into Dashboard Budgeting

- update the available/remaining budget calculations to include prior-month carryover
- keep the rest of the dashboard behavior unchanged unless clarity requires a small wording tweak

Definition of done:

- the main dashboard number reflects baseline plus carryover

### 4. Verify Related Flows

- adding current-month expenses still works
- deleting expenses still updates totals correctly
- previous-month changes affect current carryover as expected

Definition of done:

- the new rule behaves coherently across existing flows

### 5. Final Verification

- build the project
- run unit tests
- run targeted UI/manual checks around month-transition scenarios

Definition of done:

- `v1.0` introduces carryover without destabilizing the core app

## Guardrails

Do not include in `v1.0`:

- history browsing UI
- drill-down interactions
- manual carryover editing
- advanced forecasting
- broad redesign of the dashboard

This iteration is for one budgeting rule only.

## Exit Criteria For v1.0

`v1.0` is complete when:

- positive and negative carryover both work
- the dashboard budget number remains understandable
- automated coverage exists for the new core rule
