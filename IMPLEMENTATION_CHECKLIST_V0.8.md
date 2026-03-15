# PocketBudget v0.8 Implementation Checklist

This is the final pre-coding checklist for `v0.8: Final Stabilization`.

The goal is to make the current app dependable before moving into the next larger feature set.

## Execution Order

### 1. Review Current Rough Edges

- identify small bugs and trust issues from recent device/simulator use
- prefer issues that affect correctness, clarity, or reliability

Definition of done:

- only high-signal stabilization items are selected

### 2. Fix Low-Risk Issues

- address narrow bugs or rough edges in existing flows
- avoid scope expansion

Definition of done:

- the current app becomes more stable without changing its shape

### 3. Evaluate Test Reliability

- run the suite
- distinguish real failures from flaky/tooling failures
- keep or simplify tests based on signal quality

Definition of done:

- the test story is clearer and more useful than before

### 4. Verify Core Flows

- setup still works
- add-expense still works
- delete-expense still works
- dashboard and chart still update correctly

Definition of done:

- the current feature set behaves predictably

### 5. Final Verification

- build the project
- run tests
- do one final regression pass on simulator and, if possible, device

Definition of done:

- `v0.8` leaves the app ready for the next major feature block

## Guardrails

Do not include in `v0.8`:

- settings implementation
- month history view
- category drill-down
- new budgeting rules
- broad architectural rewrites

This iteration is for stabilization only.

## Exit Criteria For v0.8

`v0.8` is complete when:

- the current app feels stable and trustworthy
- no important rough edge is left unresolved in the core flows
- the verification story is strong enough to support the next feature iteration
