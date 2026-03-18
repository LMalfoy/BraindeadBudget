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

## Version 2.0 Direction

Version `2.0` should expand the app carefully along three axes:

- reduce friction when entering expenses
- improve financial insights
- add lightweight planning tools

The guiding rule stays the same:

`Simple budget tracking with useful insights.`

The first `2.0` step should stay intentionally small.

### Iteration 2.0.1: Friction Reduction

Goal:
Reduce input friction in the app's most common daily action: recording an expense.

Scope:

- add a `Quick Add Expense` home screen widget that deep-links into the app
- make amount entry submittable directly from the keyboard
- review terminology consistency across the app for closely related concepts

Why this matters:

- this gives immediate daily-use value without destabilizing the product
- it creates a clean foundation for later `2.0` dashboard and insights work

### Iteration 2.0.2: Friction And UI Polish

Goal:
Tighten the first `2.0` UX pass by removing small points of confusion and visual inconsistency.

Scope:

- reshape the quick-add widget into a clearer, more compact call to action
- make the `Save Expense` action state more intuitive when required fields are empty
- unify the primary green action color across dashboard and expense-entry flows
- make `Recent Expenses` on the dashboard tappable and route into history

Why this matters:

- the first friction pass exposed a few rough edges immediately in real use
- these are small changes with high day-to-day usability value
- keeping them together avoids a bloated backlog of tiny but related UX fixes

### Iteration 2.0.3: Dashboard Guidance

Goal:
Make the dashboard card more helpful and less redundant by adding one practical pacing metric and removing one confusing value.

Scope:

- add `Daily Safe Spend` to the main dashboard card
- add a small info button that explains the most important dashboard figures
- remove `Available This Month` from the dashboard card
- keep `Remaining` as the primary action-driving budget number

Why this matters:

- the dashboard should answer not only \"how much is left\" but also \"what is safe today\"
- the card is now mature enough that redundant values should be trimmed away
- explanation matters more once the dashboard becomes denser

### Iteration 2.0.4: Achievements Beta

Goal:
Add a lightweight achievements system that rewards meaningful budgeting behavior without turning the app into a game-first product.

Scope:

- add a compact achievements preview card in the statistics / progression area
- add an achievements detail page
- show locked and unlocked achievements distinctly
- make achievements tappable for a short detail explanation
- evaluate and persist a first curated achievement set
- show a small in-app unlock notification when a new achievement is earned

Why this matters:

- achievements should reinforce budgeting habits, not replace the app's purpose
- the system is most useful when it stays curated, understandable, and secondary
- this creates the base for future badge artwork and additional achievements later

### Iteration 2.0.6: Dashboard Streak Indicator

Goal:
Make the existing safe-spending streak visible on the dashboard with a compact visual indicator that reinforces momentum without cluttering the main budget card.

Scope:

- add a streak indicator to the budget overview card
- position it in the lower-right area of the card
- use a blue flame symbol with a small circular streak count badge
- show the current streak count from the existing safe-spend streak logic
- keep the indicator compact and secondary to the main budget values

Not in scope:

- no new achievements
- no new dashboard metrics
- no new stats modules
- no gamification redesign

Why this matters:

- the app already computes and rewards disciplined spending, but the dashboard does not surface that momentum clearly
- a small visible streak indicator makes the habit loop more tangible without overwhelming the core budgeting purpose

### Iteration 2.0.7: Subscription Visibility

Goal:
Make subscription costs directly visible inside the recurring-spending statistics so the subscription load metric is not just abstract count and total.

Scope:

- add a compact subscription list beneath the existing subscription load summary
- show each subscription name and monthly amount
- keep the list lightweight and read-only
- use the existing recurring-expense data model and recurring statistics area

Not in scope:

- no recurring-cost editing from this module
- no new subscription categories
- no trend views yet
- no stats navigation changes

Why this matters:

- subscription count and total cost are helpful, but users also need to see what is actually included
- this makes recurring spending more understandable without adding new product complexity
