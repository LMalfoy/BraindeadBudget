# Iteration: Onboarding, Setup Clarity, And Palette Consistency Polish

## Objective

Improve onboarding smoothness, setup clarity, and category color consistency without changing the overall app architecture.

## In Scope

- Keep onboarding at 3 swipe-first screens
- Remove the duplicate large onboarding headline from page content
- Make the final `Start Setup` button a stable bottom element that does not disturb swipe behavior
- Remove the summary row `Available Right Now`
- Rename the editable setup field to `Budget Available for this Period`
- Group `budget period start day` and `budget available for this period` under `Personalization`
- Slightly strengthen the curated 9-color palette without drifting into neon tones
- Ensure chart-based category visualizations pull from the shared palette consistently

## Out Of Scope

- No navigation redesign
- No new product features
- No settings redesign beyond copy and entry UX polish
- No new analytics
- No onboarding branching or complex permission flow

## Target Files

- `PocketBudget/App/ContentView.swift`
- `PocketBudget/Features/DashboardView.swift`
- `PocketBudget/Features/BudgetSettingsSheet.swift`
- `PocketBudget/Features/ExpenseHistorySheet.swift`
- `PocketBudget/Features/StatsView.swift`
- `PocketBudget/Features/SettingsSheet.swift`

## Acceptance Criteria

- Onboarding pages show only the top title plus explanatory text
- Swiping to the last onboarding page remains smooth and the full `Start Setup` button area is tappable
- Setup no longer shows a duplicate `Available Right Now` summary field
- `Budget Available for this Period` is the only editable period-budget field
- `Personalization` groups the period start day with the period-budget override
- Category charts across Dashboard, Month, and Trends use the shared palette consistently
- Build succeeds
- Stop for manual review before any commit or push
