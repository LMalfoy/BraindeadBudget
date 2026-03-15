# PocketBudget v0.8 Implementation Spec

## Iteration Goal

Use `v0.8` as a final stabilization pass before the next feature expansion.

The purpose of this iteration is to improve trust, fix narrow issues, and ensure the current app is a solid base for settings, expense history, and later period features.

## Why This Iteration Comes Next

PocketBudget already covers the core product loop:

- budget setup
- fast expense entry
- dashboard summary
- category overview
- expense deletion

Before adding more surfaces, the product should confirm that the existing flows are stable, understandable, and verifiable.

## Scope

In scope:

- fix small bugs that affect correctness or trust
- resolve low-risk UX rough edges found during polish/device review
- improve test reliability where the current suite is noisy or hard to trust
- do a narrow maintenance pass only where it reduces risk directly
- verify the main flows end to end

Out of scope:

- new major features
- new navigation areas
- settings area implementation
- expense history implementation
- category drill-down
- speculative refactors without immediate stability benefit

## Product Decisions

### Core Rule

`v0.8` is a stabilization iteration, not a growth iteration.

Decision:

- prefer trust improvements over new capabilities
- prefer small fixes over ambitious cleanup

### Test Reliability

The automated test suite should continue to exist only if it provides useful signal.

Decision:

- keep good tests
- fix flaky or low-signal tests if feasible
- if a test is structurally unreliable and not worth the maintenance cost, it may be simplified or removed

### Refactoring Standard

Refactoring is allowed only when:

- it directly reduces the chance of mistakes
- it simplifies a currently fragile area
- it does not broaden scope

## Acceptance Criteria

### Functional

- all current core flows still work:
  - onboarding/setup
  - adding expenses
  - deleting expenses
  - dashboard summary
  - category overview

### UX

- no major rough edge remains in the current main flows
- current interactions feel predictable and stable

### Engineering

- the project builds cleanly
- the test story is clearer than before, either through a reliable full run or by narrowing/removing low-signal tests
- changes remain local and low-risk

## Test Plan

### Automated Checks

- build the project
- run the existing test suite
- identify whether any failures are real, flaky, or tooling-bound

### Manual Checks

- complete budget setup
- add several expenses across categories
- delete an expense
- confirm dashboard and category overview update correctly
- review behavior on simulator and, if possible, on a real device

## Recommended Implementation Approach

Implement `v0.8` in this order:

1. identify the most meaningful trust/stability issues
2. fix only the clearly local ones
3. verify automated tests and adjust low-signal cases only if needed
4. run manual regression checks
5. stop when the app is stable enough for the next feature block

This keeps the iteration disciplined and prevents stabilization from turning into endless cleanup.
