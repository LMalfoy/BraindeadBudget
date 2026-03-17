# Iteration 1.8 Specification

## Goal

Add a month-over-month comparison module to the Statistics area so users can judge whether their current spending is improving or worsening relative to the previous month.

## In Scope

- add one comparison module to Stats
- compare the current month against the previous month
- include a short plain-language interpretation
- keep the module simple and readable

## Out Of Scope

- budget discipline score
- category drill-down
- long-range historical trends
- broader Stats redesign

## UX Expectations

The user should be able to answer:

- am I doing better or worse than last month?
- is my total spending moving in the right direction?

Example interpretations:

- `You are doing better than last month`
- `Your spending is close to last month`
- `You are spending more than last month`

## Acceptance Criteria

- Stats includes a month-over-month comparison module
- the comparison uses current month versus previous month
- the module includes a short interpretation
- existing Stats modules remain intact
- empty and low-data states remain readable

## Validation Plan

- build the project
- add tests for the comparison helper
- run a focused UI test for the Stats area
- manually review whether the comparison is immediately understandable
