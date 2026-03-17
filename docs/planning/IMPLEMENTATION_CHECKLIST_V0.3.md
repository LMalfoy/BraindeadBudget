# PocketBudget v0.3 Implementation Checklist

This is the final pre-coding checklist for `v0.3: Frictionless Expense Entry v1`.

The goal is to make daily expense entry faster, simpler, and easier to use with one hand.

## Execution Order

### 1. Add Expense Category Support

- add a category type for expenses
- use the fixed set: `Food`, `Transport`, `Household`, `Fun`
- keep display labels and color mapping centralized
- update `Expense` so category is stored with each expense

Definition of done:

- the model builds cleanly
- there is one obvious source of truth for category names and colors

### 2. Update Expense Persistence And Validation

- update `BudgetStore.addExpense` to require category
- keep title and amount validation intact
- update any call sites to pass category

Definition of done:

- no expense can be created without a category
- save logic stays easy to read

### 3. Update Unit Tests

- update existing expense persistence tests for category
- add at least one test that saves an expense with a category
- confirm budget calculations still behave correctly after the model change

Definition of done:

- the new expense shape is covered before UI work expands

### 4. Redesign Add Expense Sheet

- place category selection at the top
- use four easy-to-tap colored tiles
- keep item name and amount as the main text inputs
- keep date and note secondary
- make the item field ready immediately if practical
- move focus from item name to amount on submit

Definition of done:

- the main path is category -> item -> amount -> save
- the form still feels clean and simple

### 5. Move Add-Expense Action On Dashboard

- remove the current top-bar-only primary action
- add a bottom-positioned primary action
- keep the action easy to reach with the right thumb

Definition of done:

- the main entry point for adding an expense is near the bottom of the screen

### 6. Update Expense Row Presentation

- make category visible in each row
- use restrained color coding
- avoid adding visual clutter

Definition of done:

- category can be recognized at a glance in the list

### 7. Update UI Tests

- add or update the expense-entry UI test for category selection
- verify the new add-expense path still works end-to-end
- verify the dashboard add-expense action exists in its new position

Definition of done:

- the main `v0.3` flow is protected against regression

### 8. Final Verification

- build the project
- run tests
- do a manual simulator pass focused on repeated expense entry
- check one-handed reachability and interaction flow

Definition of done:

- `v0.3` feels meaningfully faster than `v0.2`

## Guardrails

Do not include in `v0.3`:

- smart single-line parsing
- dashboard pie charts
- broad dashboard redesign beyond the bottom add-expense action
- expense deletion/editing
- category analytics beyond row visibility

These belong to later iterations.

## Exit Criteria For v0.3

`v0.3` is complete when:

- every new expense has one of the four approved categories
- category is quick to choose and visible in the list
- the add-expense flow is faster and more direct than before
- the bottom add-expense action feels natural on a phone
- tests cover the new expense-entry behavior
