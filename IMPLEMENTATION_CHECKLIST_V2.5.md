# Implementation Checklist: v2.5

## 1. Recurring-Cost Category Row

- place all 5 recurring-cost categories in one row
- keep the selected state obvious
- use meaningful iconography and color coding

## 2. Form Layout

- align the recurring-cost editor with the add-expense interaction style
- keep category selection first
- preserve the rest of the form fields with minimal friction

## 3. Edit Flow Consistency

- ensure existing recurring-cost editing still works
- keep the row-tap edit affordance intact

## 4. Regression Safety

- avoid touching income persistence
- avoid changing recurring-cost statistics logic
- keep changes local to the recurring-cost editor UI

## 5. Tests And Verification

- add or update a UI test for recurring-cost category selection and save
- verify build success
- manually review add and edit recurring-cost flows
