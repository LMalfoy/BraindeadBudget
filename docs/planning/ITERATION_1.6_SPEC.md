# Iteration 1.6 Specification

## Goal

Extend the Statistics area with the first pacing-oriented module: Budget Trajectory / Remaining Budget Trend.

## In Scope

- add one trajectory module to the Stats screen
- show how spending or remaining budget is evolving through the current month
- include a short plain-language interpretation
- tighten the Stats screen top spacing so the first card starts directly below the title

## Out Of Scope

- temporal weekday pattern analysis
- month-over-month comparison
- budget discipline score
- category drill-down
- broader Stats redesign

## UX Expectations

The user should be able to answer:

- am I spending too quickly this month?
- is my remaining budget declining in a stable way?

The interpretation should stay plain and short, for example:

- `You are spending faster than planned this month`
- `Your spending pace is currently steady`
- `You still have strong budget room for the rest of the month`

## Acceptance Criteria

- the Stats screen includes a Budget Trajectory / Remaining Budget Trend module
- the module includes a short interpretation
- the Stats screen no longer has the extra top spacing above the first module
- the existing category module remains intact
- empty and low-data states stay readable

## Validation Plan

- build the project
- add tests for any new trajectory helpers if needed
- run a focused UI test for opening Stats
- manually review chart readability and interpretation wording
