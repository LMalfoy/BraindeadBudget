# PocketBudget v0.7 Implementation Checklist

This is the final pre-coding checklist for `v0.7: Polish Pass`.

The goal is to improve the quality of the current experience without adding new core features.

## Execution Order

### 1. Review Current Backlog Notes

- identify the items that fit naturally into the current dashboard and expense-entry screens
- ignore anything that would expand scope into a new feature

Definition of done:

- only local, low-risk polish targets are selected

### 2. Test On A Real Device

- review dashboard spacing, hierarchy, and chart presentation
- review add-expense flow with one hand
- note any awkward or noisy interactions

Definition of done:

- the iteration is grounded in real usage, not abstract cleanup

### 3. Apply Small UI Refinements

- align cards and spacing
- remove redundant labels if safe
- tune visual hierarchy where needed

Definition of done:

- the app feels cleaner without changing its shape

### 4. Verify Existing Flows

- budget setup still works
- add-expense still works
- delete-expense still works
- chart overview still works

Definition of done:

- polish changes have not damaged the main workflows

### 5. Final Verification

- build the project
- run tests
- do one final manual pass on device or simulator

Definition of done:

- `v0.7` is visibly better but behaviorally unchanged

## Guardrails

Do not include in `v0.7`:

- new major screens
- month history view
- category drill-down
- smart parsing
- architecture changes

This iteration is for refinement only.

## Exit Criteria For v0.7

`v0.7` is complete when:

- the current app feels more polished on a real device
- no unnecessary new features were introduced
- the core flows remain stable
