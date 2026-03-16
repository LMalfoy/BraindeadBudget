# Iteration 1.5 Specification

## Goal

Launch the Statistics area safely by implementing only the first meaningful module: current-month Spending by Category.

## In Scope

- add a Stats area to the main app structure
- implement one category-spending chart for the current month
- show a short plain-language interpretation beneath it
- handle empty states cleanly
- keep the UI aligned with the rest of the app

## Out Of Scope

- budget trajectory
- temporal/day-based analysis
- month-over-month comparison
- budget discipline score
- category drill-down interactions

## UX Expectations

The Statistics area should feel useful immediately, even with only one module.

The first module should answer:

- where is my money going this month?

The interpretation should be plain and short, for example:

- `Food is your largest spending category this month`

The screen should not feel empty or under-designed when there is no data.

## Acceptance Criteria

- the app has a dedicated Stats surface
- the Stats surface shows current-month category spending
- the Stats surface includes a short interpretation
- empty states remain clean and understandable
- the rest of the app behavior remains unchanged

## Validation Plan

- build the project
- add tests for any extracted statistics helpers if needed
- add a UI test for reaching the Stats area
- manually verify chart readability and interpretation quality
