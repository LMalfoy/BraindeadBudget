# Iteration 1.9 Specification

## Goal

Add a carryover-focused module to the Statistics area so users can clearly see whether the previous month helped or hurt the current one.

## In Scope

- add one carryover module to Stats
- show positive, neutral, or negative carryover clearly
- include a short plain-language interpretation
- position carryover as a future input into the Budget Discipline Score

## Out Of Scope

- budget discipline score itself
- category drill-down
- deeper historical analytics
- broader Stats redesign

## UX Expectations

The user should be able to answer:

- did I bring money forward into this month?
- did last month make this month easier or harder?

Example interpretations:

- `You carried money forward from last month`
- `You started this month with no carryover`
- `Last month reduced this month’s available budget`

## Acceptance Criteria

- Stats includes a carryover module
- the module clearly distinguishes positive, neutral, and negative carryover
- the module includes a short interpretation
- existing Stats modules remain intact
- empty or no-history states remain readable

## Validation Plan

- build the project
- add tests for any carryover presentation helper if needed
- run a focused UI test for the Stats area
- manually review whether the carryover message feels clear and meaningful
