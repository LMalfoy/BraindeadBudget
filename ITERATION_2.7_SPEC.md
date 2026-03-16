# Iteration 2.7 Spec

## Title

Initial Period Budget Anchor

## Goal

Redesign onboarding so first-time users always enter the variable budget they still have available right now, regardless of when they start using the app.

## Context

The current budgeting model works well once the app is already in motion, but first-time users almost never begin at a clean month boundary.

Because of that, first setup should not assume:

- a fresh month
- zero prior spending
- inferred historical state

Instead, onboarding should establish an explicit starting state for the active period.

## Core Rule

During first setup, the user must enter:

- monthly income
- recurring monthly costs
- current available variable budget right now

That third value becomes the budget anchor for the current active period.

It must not be modeled as:

- a fake expense
- historical spending
- an inferred reset month

## Product Behavior

- the initial active period starts from the user-entered available budget
- statistics for that period should use only real expenses entered after onboarding
- later periods should return to the normal carryover-based budgeting model
- carryover into the next period should emerge naturally from the anchored first period

## Scope

- extend onboarding to collect current available budget
- store that starting-period anchor safely
- integrate it into current-period remaining budget calculations
- preserve the existing income and recurring-cost setup flow where possible
- keep the change modular and explainable

## Explicit Non-Goals

- do not redesign the later carryover model
- do not infer prior spending
- do not add fake historical entries
- do not combine this with app icon or image work
- do not redesign the statistics area here beyond what is needed for correctness

## Success Criteria

- first-time users can begin from real current budget reality
- the first active period no longer assumes a clean month start
- later periods still behave normally
- statistics are not polluted with fabricated spending history
