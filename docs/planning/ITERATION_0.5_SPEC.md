# PocketBudget v0.5 Implementation Spec

## Iteration Goal

Add a lightweight category overview to the dashboard so the user can quickly see where variable spending is going this month.

This iteration should introduce useful insight without turning PocketBudget into a complex analytics app.

## Why This Iteration Comes Next

The app already answers:

- how much is available to spend
- how much is left
- what was spent recently

The next useful question is:

"Which category is taking most of my money this month?"

## Scope

In scope:

- aggregate current-month expenses by category
- add one lightweight chart to the dashboard
- show the largest spending category clearly in text
- handle empty and low-data states gracefully
- add focused tests for category aggregation logic

Out of scope:

- cross-month analytics
- filtering controls
- advanced charts or multiple chart types
- expense edit/delete
- smart entry

## Product Decisions

### Time Window

The category overview should reflect:

- current calendar month only

This keeps the chart aligned with the existing monthly budgeting model.

### Categories

The chart should use the existing fixed categories only:

- Food
- Transport
- Household
- Fun

### Chart Type

Preferred direction:

- simple pie chart or donut chart

Reason:

- easy to understand at a glance
- fits the lightweight dashboard goal
- directly supports category share comparison

### Supporting Insight

The dashboard should also show a short textual insight, such as:

- `Top category: Food`

If there are no expenses in the current month, that insight should not pretend there is meaningful category data.

## Dashboard Changes

Add a category overview block to the dashboard:

- placed below the budget summary
- above the recent expense list
- visually compact
- consistent with the existing clean layout

The block should include:

- the chart
- category labels or legend
- the top-category insight

## Data And Logic Changes

Add a small category aggregation helper.

Recommended responsibilities:

- total spending by category for current-month expenses
- sort categories by spending when useful
- determine the largest category safely

This logic should live in a small helper or in `BudgetStore` if it remains concise.

## Empty-State Behavior

If there are no expenses for the current month:

- do not show a misleading chart
- show a simple empty state instead
- keep the dashboard feeling intentional, not broken

If only one category has spending:

- the chart and labels should still remain readable

## Acceptance Criteria

### Functional

- the dashboard shows a category overview for current-month expenses
- spending is aggregated correctly by category
- the largest spending category is identified correctly
- empty current-month data does not produce misleading output

### UX

- the chart is easy to understand at a glance
- the chart does not crowd the existing dashboard
- the overview feels like decision support, not heavy analytics

### Engineering

- aggregation logic is covered by focused tests
- changes stay local to dashboard and helper logic
- no persistence changes are introduced unless strictly necessary

## Test Plan

### Unit Tests

Add tests for:

- category totals from a mixed set of expenses
- aggregation using only current-month expenses
- identifying the highest-spend category
- empty input producing an empty overview

### Manual Checks

- no-expense state
- one-category state
- mixed-category state
- negative remaining budget still coexists cleanly with the chart
- chart remains readable on common phone sizes

## Recommended Implementation Approach

Implement `v0.5` in this order:

1. add category aggregation helpers
2. add unit tests for aggregation
3. add the dashboard chart block
4. handle empty and low-data states
5. run build and manual visual checks

This keeps the logic stable before the UI is layered on top.
