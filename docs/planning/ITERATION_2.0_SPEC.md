# Iteration 2.0 Spec

## Title

Budget Discipline Rank

## Goal

Create a qualitative, transparent rank system in the Statistics area that summarizes the user's current budgeting discipline without using a numeric score.

## User Outcome

The user should be able to open Stats and quickly understand:

- what their current budgeting rank is
- whether their current behavior is stable or concerning
- which signals most influenced that result

## Product Rules

- the rank must not be numeric
- the rank must be deterministic and rule-based
- the rank must be explainable at a glance
- the UI must show the main reasons behind the result
- the rank should feel fair and motivating, not punitive
- sparse-data states must be conservative and explicit

## Rank Hierarchy

- Pawn
- Knight
- Bishop
- Rook
- Queen
- King

## Inputs

### Behavioral Base Signals

These signals determine the base rank:

- budget trajectory
- category distribution
- temporal spending pattern
- month-over-month comparison

Each signal should resolve to one of:

- strong
- neutral
- weak

### Outcome Modifiers

These signals should stabilize or modify the base rank:

- monthly carryover
- leftover budget percentage for the current month

## Resolution Model

### Base Rank

Use the four behavioral signals to determine a base rank:

- very strong overall behavior should resolve to `Queen`
- clearly good behavior should resolve to `Rook`
- mixed but mostly solid behavior should resolve to `Bishop`
- neutral or provisional behavior should resolve to `Knight`
- clearly unhealthy behavior should resolve to `Pawn`

`King` should be reserved for unusually strong, stable states after modifiers are applied.

### Modifiers

- healthy carryover or strong leftover percentage can lift the rank by one step or prevent a downgrade
- neutral carryover and neutral leftover percentage should not change the base rank
- strongly negative carryover or no budget left can lower the rank by one step

## Sparse Data Behavior

If the app does not have enough current-month or recent historical data:

- do not pretend confidence
- keep the rank conservative
- cap the result around the middle of the scale
- explain that more data is needed for a stable evaluation

Recommended sparse-data default:

- rank: `Knight`
- summary: `Still learning your spending pattern`

## UI Requirements

The rank card should include:

- current rank title
- short summary sentence
- short `Why` list with the most important contributing signals

Example structure:

- `Current Rank: Rook`
- `Your budgeting behavior is stable this month.`
- `Why`
- `✓ Spending pace is close to plan`
- `✓ Category distribution is balanced`
- `• Spending is slightly higher than last month`
- `• Carryover remains healthy`

## Technical Requirements

- keep rank evaluation separate from UI rendering
- create readable evaluation types and helper logic
- avoid hidden formulas or opaque weighting
- make the logic easy to unit test

## Out Of Scope

- chess-piece image assets
- animated rank progression
- historical rank timeline
- drill-down from reasons into deeper detail
- changing any existing Stats module behavior beyond what is needed to support the rank
