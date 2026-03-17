# PocketBudget v1.0 Implementation Spec

## Iteration Goal

Use `v1.0` to introduce full monthly carryover budgeting.

The purpose of this iteration is to make the app’s main budget number reflect continuity between months instead of resetting in isolation every time a new month begins.

## Why This Iteration Comes Next

PocketBudget already calculates a reliable baseline monthly budget:

- income
- minus recurring monthly commitments
- minus current-month variable spending

The next important product improvement is making month transitions financially meaningful.

If the user underspends, that surplus should remain available.
If the user overspends, that deficit should reduce the next month’s budget.

## Scope

In scope:

- calculate the previous month’s remainder
- carry that remainder into the current month
- support both positive and negative carryover
- update dashboard calculations and presentation to reflect the new rule
- add tests for month-boundary and carryover behavior

Out of scope:

- month-history browsing UI
- category drill-down
- editing older months through a dedicated history view
- advanced forecasting
- manual carryover overrides

## Product Decisions

### Carryover Rule

PocketBudget should use full carryover, not deficit-only carryover.

Decision:

- positive leftover budget rolls forward
- negative overspending rolls forward

Rule:

`current month available budget = baseline monthly budget + previous month carryover`

### Current Version Boundary

The first carryover version should remain deliberately simple.

Decision:

- only carry over from the immediately previous month
- do not add manual adjustments or special exception rules
- do not expose complex period controls yet

### Trust Standard

This is a core financial rule.

Decision:

- favor explicit, testable logic over clever abstractions
- ensure the rule is easy to explain in plain language

## Acceptance Criteria

### Functional

- a positive remainder from the previous month increases the current month’s available budget
- a negative remainder from the previous month decreases the current month’s available budget
- current-month spending still subtracts from that adjusted budget correctly

### UX

- the dashboard still reads clearly
- the user can understand that the main number now includes carryover

### Engineering

- calculations remain deterministic and testable
- existing expense-entry and deletion flows still behave correctly under the new budget rule

## Test Plan

### Automated Checks

- build the project
- add unit tests for:
  - positive carryover
  - negative carryover
  - no carryover when there is no previous-month data
  - correct month filtering around boundaries

### Manual Checks

- create a prior month with leftover money and confirm the new month starts higher
- create a prior month with overspending and confirm the new month starts lower
- confirm deleting a previous-month expense updates the current carryover correctly

## Recommended Implementation Approach

Implement `v1.0` in this order:

1. define explicit carryover helper logic
2. add unit coverage for the rule
3. wire the adjusted budget into the dashboard
4. verify existing flows still produce trustworthy totals

This keeps the iteration focused on budgeting correctness rather than UI expansion.
