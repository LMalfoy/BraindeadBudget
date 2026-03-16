# PocketBudget v1.1 Implementation Spec

## Iteration Goal

Use `v1.1` to add a dedicated monthly expense-history view.

The purpose of this iteration is to give the user a complete, month-based place to inspect, edit, and delete recorded expenses beyond the lightweight dashboard preview.

## Why This Iteration Comes Next

PocketBudget now has:

- budget setup
- fast expense entry
- dashboard summary
- category overview
- carryover-aware budgeting

Once carryover exists, month boundaries matter more. That makes a month-specific history view much more valuable and much easier to justify.

## Scope

In scope:

- add a dedicated monthly expense-history surface
- show all expenses for a selected month
- support quick month and year navigation
- allow editing and deleting expenses from that view
- ensure dashboard totals, category overview, and carryover all update correctly after changes

Out of scope:

- category drill-down from the chart
- gesture-first navigation
- advanced filtering
- analytics expansion
- major redesign of the dashboard

## Product Decisions

### History Purpose

The monthly history view is a review and correction tool.

Decision:

- the dashboard remains a summary surface
- the history view becomes the full monthly ledger

### Period Navigation

Month switching should be easy and explicit.

Decision:

- provide clear month and year controls
- optimize for quick switching without making the screen feel dense

### Editing Scope

This iteration should finally support editing, not just deletion.

Decision:

- use a simple edit flow that reuses existing expense fields where possible
- keep edits local and low-risk

## Acceptance Criteria

### Functional

- a user can open a monthly expense-history view
- a user can switch to a different month and see the correct expenses
- a user can edit an expense from that view
- a user can delete an expense from that view
- dashboard calculations stay correct after those changes

### UX

- the monthly list is easy to scan
- month navigation is understandable without explanation
- editing and deletion feel controlled and predictable

### Engineering

- month filtering is deterministic
- edits and deletes correctly affect carryover-aware calculations
- the change remains compatible with existing dashboard and setup flows

## Test Plan

### Automated Checks

- build the project
- add unit tests for month filtering and recalculation after editing/deleting
- add UI coverage for opening the history view and changing a month if feasible

### Manual Checks

- navigate across several months with different expense data
- edit an expense in an old month and confirm downstream totals change correctly
- delete an expense in an old month and confirm carryover updates correctly

## Recommended Implementation Approach

Implement `v1.1` in this order:

1. define reusable month-filtering helpers
2. add the history surface with explicit navigation controls
3. wire deletion there
4. add a small edit flow
5. verify recalculation behavior across dashboard and carryover logic

This keeps the iteration centered on review and correction rather than visual experimentation.
