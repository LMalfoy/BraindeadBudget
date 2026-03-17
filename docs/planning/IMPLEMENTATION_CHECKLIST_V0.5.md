# PocketBudget v0.5 Implementation Checklist

This is the final pre-coding checklist for `v0.5: Category Overview`.

The goal is to add one lightweight insight layer to the dashboard: category spending for the current month.

## Execution Order

### 1. Add Category Aggregation Logic

- compute totals for each category from current-month expenses
- keep the logic small and explicit
- determine the top-spend category safely

Definition of done:

- category totals can be tested independently of the UI

### 2. Add Unit Tests

- test mixed-category aggregation
- test current-month-only behavior
- test top-category selection
- test empty overview output

Definition of done:

- the analytics logic is stable before chart UI work begins

### 3. Add Dashboard Overview Block

- place the chart below the summary
- keep it visually lightweight
- include a short top-category insight

Definition of done:

- the dashboard now answers where money is going this month

### 4. Handle Empty And Small Data States

- show a clean empty state when there are no current-month expenses
- keep one-category rendering readable

Definition of done:

- the overview never feels broken or misleading

### 5. Verify Layout And Readability

- ensure the chart does not crowd the dashboard
- ensure labels remain understandable on phone screens

Definition of done:

- the new insight fits the existing visual language

### 6. Final Verification

- build the project
- run tests
- manually review the dashboard with several data scenarios

Definition of done:

- `v0.5` adds insight without making the app feel heavy

## Guardrails

Do not include in `v0.5`:

- month navigation
- advanced analytics
- multiple chart types
- filter controls
- smart parsing
- expense edit/delete

This iteration should add only one new insight surface.

## Exit Criteria For v0.5

`v0.5` is complete when:

- category totals are shown for the current month
- the largest category is clearly identified
- the dashboard remains clean and readable
- empty states remain graceful
- tests cover the aggregation behavior
