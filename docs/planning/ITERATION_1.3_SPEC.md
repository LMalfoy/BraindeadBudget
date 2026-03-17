# Iteration 1.3 Specification

## Goal

Strengthen the monthly history screen and remove one small but frequent friction point from expense entry.

## In Scope

- add direct month/year selection from the history header
- add a compact monthly digest to the history screen
- keep month arrows for adjacent-month navigation
- keep history editing and deletion behavior intact
- submit a new expense from the keyboard when the amount is valid

## Out Of Scope

- category drill-down
- branding rename or icon work
- dashboard redesign
- deeper settings changes

## History Expectations

The monthly history screen should still feel lightweight, but more useful than a plain list.

The top area should help the user answer:

- which month am I looking at?
- how much did I spend?
- what carryover affected this month?
- where did the spending go by category?

The month header should support two navigation modes:

- left and right arrows for adjacent months
- tapping the month label to select a month and year directly

## Digest Expectations

The digest should stay compact and readable.

It should likely include:

- total spent
- carryover
- category totals

This digest should support understanding, not become a second dashboard.

## Expense Entry Expectations

The add-expense flow should keep its current structure.

The only behavior change for this iteration is:

- if the amount field contains a valid positive value, pressing Return or Send should save the expense

This should not weaken validation or allow incomplete entries through.

## Acceptance Criteria

- the history screen provides direct month/year selection
- the history screen still supports adjacent-month navigation with arrows
- the monthly digest updates when the selected month changes
- editing and deleting in history still work
- pressing Return or Send in the add-expense amount field saves a valid expense
- invalid or incomplete expense input still does not save

## Validation Plan

- build the project
- run existing budget/store unit tests
- add tests for any new digest calculations if logic is extracted
- run focused UI tests for history navigation and add-expense keyboard submission
