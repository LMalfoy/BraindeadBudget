# PocketBudget v0.7 Implementation Spec

## Iteration Goal

Use `v0.7` as a focused polish pass.

The objective is to make the app feel tighter and more intentional on a real iPhone without expanding the product surface or changing core behavior.

## Why This Iteration Comes Next

PocketBudget is already useful:

- budget setup works
- expense entry is fast
- category overview exists
- expense deletion exists

At this point, polishing what already works is more valuable than adding speculative features.

## Scope

In scope:

- refine dashboard spacing and panel alignment
- remove redundant labels or titles where the layout already provides context
- polish the category overview presentation if needed
- smooth small real-device interaction issues in the existing expense-entry and dashboard flows
- address a small subset of items from `BACKLOG.md` only when they fit naturally and remain low-risk

Out of scope:

- new data-model changes
- new navigation surfaces
- month history view
- category drill-down
- smart parsing
- broad visual redesign

## Product Decisions

### Core Rule

`v0.7` is not a feature expansion iteration.

Decision:

- improve the feel of current screens
- do not add broad new functionality

### Real-Device Priority

The main source of truth for `v0.7` decisions should be:

- actual iPhone usage

If a flow feels awkward, visually misaligned, too noisy, or slightly confusing in real use, it is a candidate for this iteration.

## Acceptance Criteria

### UX

- the dashboard feels cleaner and more visually consistent
- the chart and summary cards feel aligned and intentional
- the add-expense flow still feels fast on a real device
- no polish change makes the app harder to understand

### Engineering

- changes remain local and low-risk
- no new persistence changes are introduced
- existing tests continue to pass

## Test Plan

### Manual Checks

- review dashboard layout on a real iPhone
- review add-expense flow on a real iPhone
- confirm the chart block feels visually integrated
- confirm no polish change harms discoverability

### Automated Checks

- build the project
- run the existing test suite

## Recommended Implementation Approach

Implement `v0.7` in this order:

1. collect the highest-value polish issues from real-device testing
2. implement only the clearly local ones
3. verify no behavior changes were introduced
4. run tests and do another device pass

This keeps the iteration controlled and reversible.
