# Iteration: Calendar Month And Recurring Timeline

## Objective

Simplify the budgeting model so that budget periods always equal calendar months, and make recurring costs behave like month-based timeline data instead of a single global constant.

## In Scope

- Remove the custom budget period start option from setup and settings
- Make all budget period calculations use calendar months only:
  - first day of month
  - last day of month
- Update month and trend calculations so trajectory charts always cover the full calendar month
- Rework recurring cost persistence/lookup so recurring costs apply from the month they were defined forward
- Ensure past months without stored recurring data do not invent recurring costs retroactively

## Out Of Scope

- No UI redesign beyond removing now-invalid controls
- No new analytics
- No new budgeting concepts
- No new navigation

## Risks / Notes

- `RecurringExpenseItem` is currently modeled as a globally active record, not a month-scoped timeline record
- This likely requires adding an effective month / start month field and updating query helpers accordingly
- Existing data should be treated so current recurring setup begins in the current month, not all historical months

## Target Files

- `PocketBudget/Models/RecurringExpenseItem.swift`
- `PocketBudget/Models/BudgetSettings.swift`
- `PocketBudget/Data/BudgetStore.swift`
- `PocketBudget/Features/BudgetSettingsSheet.swift`
- `PocketBudget/Features/SettingsSheet.swift`
- `PocketBudget/Features/DashboardView.swift`
- `PocketBudget/Features/ExpenseHistorySheet.swift`
- `PocketBudget/Features/StatsView.swift`
- relevant tests under `PocketBudgetTests/`

## Acceptance Criteria

- Users can no longer configure a custom budget period start day
- Budget calculations and period-based charts all use calendar months only
- Month and Dashboard trajectory charts always span the full selected/current month
- Recurring costs only appear starting from the month they were created or changed
- Past months without recorded recurring data show no assumed recurring costs
- Future months inherit the latest known recurring configuration
- Build succeeds
- Stop for manual review before any commit or push
