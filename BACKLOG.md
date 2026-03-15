# PocketBudget Backlog

Future improvements, polish items, and larger feature notes to revisit after the current iteration.

## Current Notes

- Remove the `PocketBudget` headline from the main dashboard.
- Keep `Date` and `Note` visible in the add-expense sheet instead of hiding them behind a disclosure control.
- Make dashboard expense rows tappable in a later pass so they can reveal the full title and additional details like amount, date, note, and category.
- Align dashboard card/panel spacing more precisely so the summary and category overview blocks feel visually consistent.
- Remove the redundant `Category Overview` title from the chart card if the chart context is already obvious.
- Consider making pie or donut slices tappable in a later version so selecting a category reveals the underlying expenses for that category.
- Add a dedicated expense-history sheet in a later version that lets the user browse expenses by month.
- In that future history sheet, provide easy month/year navigation so the user can switch to a specific period quickly.
- That future month-based expense list should support both editing and deleting expenses.
- Add a dedicated settings area in a later version so budget editing and app-level controls are not always exposed as a top-left dashboard action.
- In that future settings area, the budget setup screen should still open automatically when no budget information exists.
- Use that future settings area for version info, author/app info, and later customization options.
- When a valid numeric amount has been entered, pressing Return or Send in the expense flow should submit the expense directly instead of requiring a separate tap on Save.
- In a future period-based budgeting version, a negative remainder from one month should carry over into the next month’s available budget.
- Example: if March ends at `-200`, April should begin with that `200` deducted from the new month’s budget.

## Usage Rule

Only pull items from this list into an active iteration when:

- they fit the current scope naturally, or
- they clearly improve the current product without destabilizing working flows

This file is for future work notes, not a commitment that every item must land soon.
