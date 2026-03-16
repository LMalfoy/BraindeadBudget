# Iteration 1.7 Specification

## Goal

Add a temporal spending-pattern module to the Statistics area so users can see when during the month their spending tends to cluster.

## In Scope

- add one temporal-pattern module to Stats
- group current-month spending into a simple time-of-month structure
- include a short plain-language interpretation
- keep the UI consistent with the existing Stats modules

## Out Of Scope

- weekday heatmaps
- month-over-month comparison
- budget discipline score
- category drill-down
- broader Stats redesign

## Preferred Model

The first version should use simple month segments:

- early month
- mid month
- late month

This is preferred over a more detailed weekday model because it maps more directly to budgeting behavior and is easier to interpret quickly.

## UX Expectations

The user should be able to answer:

- do I tend to spend heavily near the beginning of the month?
- is my spending spread evenly?
- does my spending bunch up late in the month?

Example interpretations:

- `Your spending is concentrated at the beginning of the month`
- `Your spending is spread fairly evenly across the month`
- `Most of your spending happens later in the month`

## Acceptance Criteria

- Stats includes a temporal spending-pattern module
- the module uses a simple time-of-month grouping
- the module includes a short interpretation
- existing Stats modules remain intact
- empty and low-data states remain readable

## Validation Plan

- build the project
- add tests for the temporal grouping helper
- run a focused UI test for the Stats area
- manually review whether the interpretation feels clear and useful
