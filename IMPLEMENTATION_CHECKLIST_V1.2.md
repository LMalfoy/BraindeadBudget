# PocketBudget v1.2 Implementation Checklist

This is the final pre-coding checklist for `v1.2: Bottom Navigation Structure`.

The goal is to make the app easier to navigate without increasing UI clutter.

## Execution Order

### 1. Add a Bottom Navigation Shell

- create a slim bottom navigation bar
- wire Home, History, and Settings into it

Definition of done:

- the app has one stable navigation structure

### 2. Keep Surface Roles Clear

- keep dashboard as overview
- keep history as the correction surface
- keep settings as app-level configuration

Definition of done:

- each destination has an obvious purpose

### 3. Refine Dashboard Expense Preview

- limit the dashboard to a small recent set
- make those rows visually lighter and slightly smaller
- keep them read-only

Definition of done:

- the dashboard feels like a summary surface, not a ledger

### 4. Verify History Ownership

- ensure edit/delete remain in monthly history
- avoid dashboard correction affordances

Definition of done:

- review/correction behavior is localized to history

### 5. Final Verification

- build the project
- run focused tests
- do manual checks across all three tabs

Definition of done:

- `v1.2` improves structure without adding confusion

## Guardrails

Do not include in `v1.2`:

- gesture navigation experiments
- month picker modal
- monthly digest panel
- chart drill-down
- broad styling overhaul

This iteration is about structure and clarity.

## Exit Criteria For v1.2

`v1.2` is complete when:

- bottom navigation cleanly separates Home, History, and Settings
- the dashboard stays read-only and compact
- monthly history remains the correction surface
