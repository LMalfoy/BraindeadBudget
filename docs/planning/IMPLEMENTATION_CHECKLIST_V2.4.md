# Implementation Checklist: v2.4

## 1. Subscription Load

- identify recurring items in the `Subscriptions` category
- compute count and total monthly subscription cost
- add a short interpretation

## 2. Savings Stability

- identify recurring items in the `Savings` category
- compute savings amount and savings share of income
- add a short interpretation

## 3. Recurring-Cost Setup UX

- replace the recurring-cost category picker with 5 visual category tiles
- keep income editing unchanged unless row affordance needs the same polish
- make setup rows feel clearly interactive across the full width

## 4. Regression Safety

- preserve existing recurring-cost save/edit/delete behavior
- preserve the current `Total Spending` modules
- avoid touching behavioral stats logic

## 5. Tests And Verification

- add focused tests for subscription-load logic
- add focused tests for savings-share logic
- update UI tests for recurring-cost category selection if needed
- verify build success and key stats/setup flows
