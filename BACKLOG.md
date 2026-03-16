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
- On the main dashboard, a quick downward scroll toward the expense list can later become the cue that opens the monthly expense-history page.
- That future transition should feel like moving from the lightweight recent-expense preview into the full month-based list.
- Add a dedicated settings area in a later version so budget editing and app-level controls are not always exposed as a top-left dashboard action.
- In that future settings area, the budget setup screen should still open automatically when no budget information exists.
- Use that future settings area for version info, author/app info, and later customization options.
- The settings entry point on the dashboard can later stay hidden by default and only reveal itself when the user pulls the dashboard down.
- In a future period-based budgeting version, a negative remainder from one month should carry over into the next month’s available budget.
- Example: if March ends at `-200`, April should begin with that `200` deducted from the new month’s budget.
- Future branding direction: rename the app to `Budget Rook` or simply `Rook`.
- Future app icon direction: use a black rook on a white background.
- Future symbol direction: use the Lichess rook style if the asset/license is confirmed safe for app use.
- In monthly history, tapping the month header should later open a direct month/year picker while the adjacent-month arrows remain available.
- Monthly history should later include a compact digest for the selected month, including total spent, carryover, and category totals.
- Editing an expense from monthly history should later reuse the same add-expense style sheet, including the colored category tiles.
- The `Monthly Expenses` section title in history is redundant and can be removed in a later cleanup pass.
- The month/year picker opened from the history header should later feel smaller and lighter; the current full-page presentation is too visually large for only two controls.

## Usage Rule

Only pull items from this list into an active iteration when:

- they fit the current scope naturally, or
- they clearly improve the current product without destabilizing working flows

This file is for future work notes, not a commitment that every item must land soon.
