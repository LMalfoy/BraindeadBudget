# Iteration 2.1 Spec

## Title

Statistics Refinement

## Goal

Improve the precision and usefulness of two existing Statistics modules:

- Spending Pattern
- Month Comparison

## User Outcome

The user should gain:

- a more precise picture of when spending tends to happen during the month
- a broader sense of recent spending direction across several months

## Scope

### 1. Spending Pattern Refinement

- replace the current 3-part early / mid / late grouping with roughly 10 intra-month periods
- keep the chart more fine-grained than the interpretation text
- continue to interpret the pattern in plain language rather than exposing technical buckets directly

The wording should still stay natural, for example:

- spending happens mostly early in the month
- spending clusters around the middle
- spending is weighted toward the end of the month

### 2. Month Comparison Expansion

- replace the current 2-month comparison card with a trailing 6-month view
- keep the interpretation centered on recent direction and stability
- avoid making the module look like a dense finance chart

## Product Rules

- preserve all existing Stats modules
- do not redesign the Stats screen structure
- do not add new navigation
- keep interpretations easy to understand at a glance
- prefer behavioral usefulness over extra chart complexity

## Technical Direction

- keep the refined temporal evaluation layer separate from the view
- keep the 6-month comparison helper separate from rendering
- preserve compatibility with the existing discipline-rank system

## Out Of Scope

- new Stats modules
- category drill-down
- historical rank timeline
- chess-piece artwork
- broader redesign of the Statistics tab
