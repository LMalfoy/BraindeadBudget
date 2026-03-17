# PocketBudget Roadmap

## Current Product State

BudgetRook is now close to feature-complete for its core personal-budgeting goal.

Implemented today:

- monthly budget baseline from income and recurring commitments
- fast variable expense entry
- dashboard with remaining budget and category overview
- recurring-cost setup and categorization
- expense history with month navigation
- three-perspective Statistics area:
  - `Total Spending`
  - `Budget Spending`
  - `Recurring Spending`
- savings-based chess progression
- settings for appearance, currency, budget period anchor, and full reset
- first-run onboarding with an initial available-budget anchor
- branding, app icon, and dark-mode chess icons

## Product Direction

The app should remain:

- simple
- fast
- trustworthy
- focused on budgeting rather than full accounting

The remaining work is no longer about adding major missing pillars.
It is about tightening correction flows, polishing UX details, and preparing the app for a stable near-release state.

## Remaining Priorities

### 1. Expense Editing And Correction Polish

Goal:
Make fixing mistakes as smooth and obvious as adding an expense.

Scope:

- add or refine expense editing flow
- reuse the existing add-expense interaction style where possible
- keep delete behavior safe and clear
- ensure totals and history update immediately after edits

Why this matters:

- trust depends on easy correction
- fast entry naturally increases the chance of small mistakes

### 2. History UX Polish

Goal:
Tighten the month-history experience without changing its core structure.

Scope:

- lighten or shrink the month picker presentation
- remove redundant history UI where useful
- keep adjacent-month navigation clear even for empty months
- refine any small digest or layout rough edges discovered in use

Why this matters:

- history is already useful
- the remaining gains here are mostly usability and polish

### 3. Final UX And QA Pass

Goal:
Do a careful end-to-end polish and reliability review.

Scope:

- dark-mode pass across all major screens
- copy, spacing, and empty-state cleanup
- onboarding, settings, and stats sheet behavior review
- verify that the most important user flows still feel fast and legible

Why this matters:

- the product is now mature enough that polish has high leverage
- this is the point where rough edges matter more than missing features

### 4. Release Hygiene

Goal:
Clean up the remaining non-product loose ends before calling the app complete.

Scope:

- prune stale planning artifacts
- keep attribution and licensing notes accurate
- confirm versioning stays consistent
- do a final review of test reliability and any fragile UI coverage

Why this matters:

- the app is functionally strong already
- release-readiness now depends more on cleanup than new features

## Deferred Ideas

These are intentionally not part of the immediate final stretch:

- category or color customization
- a larger finance-control-panel style settings area
- denser analytics or drill-down-heavy charts
- broad redesign of the statistics architecture again

## Next Recommended Sequence

1. planning cleanup
2. expense editing and correction polish
3. history UX polish
4. final UX and QA pass
5. release hygiene cleanup
