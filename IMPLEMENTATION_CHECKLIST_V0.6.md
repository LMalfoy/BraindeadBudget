# PocketBudget v0.6 Implementation Checklist

This is the final pre-coding checklist for `v0.6: Expense Correction Basics`.

The goal is to let the user correct wrong expense entries with minimal added complexity.

## Execution Order

### 1. Add Expense Deletion Support

- add a small delete helper for expenses in the store
- keep the implementation explicit and local

Definition of done:

- one expense can be removed cleanly from persistence

### 2. Add Unit Tests

- test deleting an expense
- test recalculated remaining budget after deletion
- test recalculated category overview after deletion

Definition of done:

- correction logic is stable before UI changes land

### 3. Expose Delete In The Dashboard List

- add a native delete interaction for expense rows
- ensure the interaction is easy to discover

Definition of done:

- a user can remove a mistaken expense from the dashboard

### 4. Keep The Dashboard Reactive

- verify that summary values update immediately
- verify that category overview updates immediately

Definition of done:

- deletion visibly affects the dashboard without refresh issues

### 5. Update UI Tests

- add or update the expense-management UI test for deletion

Definition of done:

- the correction flow is regression-protected

### 6. Final Verification

- build the project
- run tests
- manually test deletion in several dashboard states

Definition of done:

- `v0.6` improves trust without adding unnecessary complexity

## Guardrails

Do not include in `v0.6`:

- broad edit flows
- batch delete
- undo stacks
- archive concepts
- advanced expense detail screens unless truly needed

This iteration should solve one problem clearly: removing incorrect expenses.

## Exit Criteria For v0.6

`v0.6` is complete when:

- a user can delete an expense safely
- dashboard numbers update correctly after deletion
- category overview updates correctly after deletion
- tests cover the delete behavior
