# PocketBudget Polish Notes

Small improvements to capture during the polish phase or when a nearby iteration touches the same screen.

## Current Notes

- Remove the `PocketBudget` headline from the main dashboard.
- Keep `Date` and `Note` visible in the add-expense sheet instead of hiding them behind a disclosure control.
- Make dashboard expense rows tappable in a later polish pass so they can reveal the full title and additional details like amount, date, note, and category.
- Align dashboard card/panel spacing more precisely so the summary and category overview blocks feel visually consistent.
- Remove the redundant `Category Overview` title from the chart card if the chart context is already obvious.
- Consider making pie or donut slices tappable in a later version so selecting a category reveals the underlying expenses for that category.
- Add a dedicated expense-history sheet in a later version that lets the user browse expenses by month.
- In that future history sheet, provide easy month/year navigation so the user can switch to a specific period quickly.
- That future month-based expense list should support both editing and deleting expenses.

## Usage Rule

Only pull items from this list into an active iteration when:

- they fit the current scope naturally, or
- they clearly improve the current screen without expanding the feature set

This file is for low-risk refinement notes, not major roadmap features.
