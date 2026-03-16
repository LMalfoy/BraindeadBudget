# Implementation Checklist: v1.4

## 1. Shared Editing Experience

- review the current add-expense and edit-expense sheets
- reuse or align the edit flow with the add-expense visual structure
- keep validation and save behavior unchanged

## 2. History List Cleanup

- remove redundant section heading from the monthly list
- ensure the screen still reads clearly without extra chrome

## 3. Month Picker Presentation

- replace the current full-page picker presentation with a smaller, lighter variant
- keep direct month/year selection intact
- preserve adjacent-month arrow navigation

## 4. Regression Safety

- confirm edit and delete still operate only in history
- confirm dashboard preview remains read-only
- confirm history digest and month selection still update together

## 5. Tests And Verification

- build successfully
- rerun focused unit tests for history-related calculations
- rerun focused UI tests for history open, edit, delete, and month selection
- manually review presentation weight and consistency
