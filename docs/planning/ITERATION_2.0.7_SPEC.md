# Iteration 2.0.7 Spec

## Goal
Improve the recurring-spending insights by making individual subscriptions directly visible below the existing `Subscription Load` statistic.

## Scope

- add a subscription list to the recurring-spending stats area
- place it directly under or within the existing `Subscription Load` module
- show subscription name and monthly amount for each item
- keep the presentation compact and easy to scan
- reuse existing recurring-expense records filtered by subscription category

## Out of Scope

- no editing from the list
- no new settings or recurring-cost workflows
- no subscription trend analysis
- no category drilldown redesign
- no changes to other stats modules unless needed for consistency

## UI / UX Expectations

- the list should feel like a supporting detail to the metric, not a new primary screen
- if there are no subscriptions, the empty state should remain simple and explanatory
- if there are several subscriptions, the list may scroll or visually limit height to keep the card compact

## Data / Logic Notes

- source of truth remains `RecurringExpenseItem` with category `.subscriptions`
- keep ordering deterministic and easy to read
- avoid duplicating subscription filtering logic in multiple places if a helper makes sense

## Tests

- verify subscription totals still calculate correctly
- verify the filtered subscription list matches recurring items tagged as subscriptions
- build the project after implementation
