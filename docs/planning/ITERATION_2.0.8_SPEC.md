# Iteration 2.0.8 Spec

## Goal
Improve the expense history view by adding a category overview and direct category-based filtering so users can move from monthly overview to concrete matching entries in one place.

## Scope

- add a `Spending by Category` module near the top of the expense history screen
- show the same variable-spending category breakdown concept already used elsewhere in the app
- allow users to tap category chart elements to activate a category filter
- filter the visible history list to the selected category
- add a clear reset path for the active category filter

## Out of Scope

- no recurring-spending filter in this pass
- no search bar
- no simultaneous multi-filter system
- no editing redesign
- no new statistics page navigation

## UI / UX Expectations

- the category overview should sit above the expense list and feel like a lightweight filter bar, not a second full stats page
- the active filter should be obvious
- resetting the filter should be simple
- the empty state for a filtered category should remain understandable

## Data / Logic Notes

- use the currently selected history month / budget period as the source range
- category totals should match the currently viewed history period
- the filter should affect only the list content, not the underlying stored data
- prefer reusing existing category aggregation helpers where possible

## Tests

- verify category totals for the selected history period are correct
- verify filtering by category returns only matching expenses
- verify clearing the filter restores the full list
- build the project after implementation
