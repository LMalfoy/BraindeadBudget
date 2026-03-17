# Implementation Checklist: v1.3

## 1. History Month Selection

- add a direct month/year picker path from the history month header
- keep left/right arrow navigation unchanged
- ensure the selected month always stays in sync with the list content

## 2. History Digest

- define the exact digest values to show for the selected month
- compute them from existing store/model data with minimal new logic
- keep the presentation compact and secondary to the list itself

## 3. History Screen Integration

- place the digest near the top of the history screen
- ensure month changes update both the digest and the expense list
- preserve tap-to-edit and swipe-to-delete behavior

## 4. Expense Entry Submit Flow

- allow keyboard submission from the amount field when the expense is valid
- keep existing validation rules intact
- avoid changing the rest of the add-expense layout

## 5. Tests

- add or adjust tests for history month selection if needed
- add or adjust tests for digest calculations if logic becomes testable
- add a UI test for saving an expense via keyboard submit
- rerun the focused regression tests for add, edit, delete, and history navigation

## 6. Verification

- build successfully
- confirm history remains readable on device-sized layouts
- confirm the new keyboard-submit path feels reliable rather than clever
