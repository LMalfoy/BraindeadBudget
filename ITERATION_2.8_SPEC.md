# Iteration 2.8 Spec

## Title

Statistics Architecture Redesign

## Goal

Redesign the Statistics information architecture so the app opens with a broad total-spending overview first, while separating behavioral and recurring-cost analysis into dedicated sub-pages.

## Context

The current Statistics structure no longer matches the product direction well enough.

The existing `Total Spending` page is really a recurring-cost structure page, not a true total-spending overview.

At the same time, the current discipline rank system has become too behavior-driven and should be replaced later by a savings-based progression model.

## New Structure

The Statistics area should move to three perspectives:

- `Total Spending`
- `Budget Spending`
- `Recurring Spending`

`Total Spending` should become the default landing perspective.

## Total Spending Purpose

The default view should provide a broad monthly financial overview, not another dense analytics page.

The first version should stay intentionally small:

- one large combined spending chart
- top spending area
- total monthly outflow
- one short interpretation

## Budget Spending Purpose

This page keeps the existing behavioral spending analytics for variable expenses.

## Recurring Spending Purpose

This page keeps the fixed-cost structure analytics for recurring commitments.

## Progression Direction

The current discipline rank system should be treated as transitional.

The future replacement should:

- sit below the overview area
- reward saved-budget outcome
- use cumulative chess progression instead of behavior-based judgment

This replacement should be planned carefully, but not necessarily fully implemented in the first architecture pass.

## Scope

- redesign the Statistics perspective structure
- make `Total Spending` the default landing perspective
- rename the current recurring-cost perspective accordingly
- preserve the existing underlying stats modules where possible
- prepare the layout for the future progression redesign

## Explicit Non-Goals

- do not invent a large number of new total-spending modules immediately
- do not keep the current behavior-based progression model as the long-term design
- do not mix in settings or onboarding work here

## Success Criteria

- Statistics opens on a true overview page
- behavioral and recurring-cost insights are clearly separated
- the information architecture feels more coherent than the current two-perspective compromise
