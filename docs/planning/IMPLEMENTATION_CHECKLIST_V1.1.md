# PocketBudget v1.1 Implementation Checklist

This is the final pre-coding checklist for `v1.1: Expense History`.

The goal is to give the app a full monthly ledger view without destabilizing the current dashboard.

## Execution Order

### 1. Define Month Selection and Filtering

- add explicit month-selection logic
- keep filtering deterministic and testable

Definition of done:

- the app can derive the correct expense set for a chosen month

### 2. Add the History Surface

- create a dedicated monthly expense-history screen or sheet
- show the full expense list for the selected period

Definition of done:

- users can inspect all expenses for a chosen month

### 3. Add Month/Year Navigation

- expose clear controls for changing the selected period
- keep the controls lightweight and understandable

Definition of done:

- switching months feels fast and explicit

### 4. Add Correction Actions

- support deleting expenses from history
- support editing expenses from history with a small, controlled flow

Definition of done:

- monthly history becomes the primary review/correction surface

### 5. Verify Calculation Effects

- ensure edits and deletes affect:
  - dashboard totals
  - category overview
  - carryover

Definition of done:

- history changes are reflected across the rest of the app correctly

### 6. Final Verification

- build the project
- run unit tests
- run targeted UI/manual checks around history navigation and correction

Definition of done:

- `v1.1` adds monthly history without breaking the core budgeting model

## Guardrails

Do not include in `v1.1`:

- gesture-based navigation polish
- chart drill-down
- advanced filters
- forecasting or analytics expansion

This iteration is for the monthly history surface itself.

## Exit Criteria For v1.1

`v1.1` is complete when:

- users can browse a specific month’s full expense list
- users can edit and delete from that view
- dashboard and carryover calculations remain correct after changes
