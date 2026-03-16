# Implementation Checklist: v2.3

## 1. Recurring Cost Categorization

- add a simple recurring-cost category model
- limit categories to:
  - housing / utilities
  - subscriptions
  - insurance
  - savings
  - debt
- keep the implementation lightweight and readable

## 2. Fixed Cost Ratio

- compute total recurring monthly cost
- compute recurring cost as a share of monthly income
- add a short interpretation

## 3. Fixed Cost Distribution

- aggregate recurring costs by recurring-cost category
- render a simple chart in `Total Spending`
- add a short interpretation about the dominant category

## 4. Empty-State Safety

- handle no recurring-cost items cleanly
- handle no income cleanly without misleading ratios

## 5. Regression Safety

- preserve the behavioral `Budget Spending` view
- avoid touching discipline-rank logic
- avoid broader settings/setup redesign

## 6. Tests And Verification

- add focused unit tests for recurring-cost aggregation
- add focused unit tests for fixed-cost ratio logic
- add or update a UI test for the `Total Spending` view
- build successfully
