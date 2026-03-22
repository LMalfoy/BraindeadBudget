# Iteration: Onboarding And Color Polish

## Objective

Add a lightweight first-run onboarding tutorial and make the app's green/status colors more coherent without changing the overall app architecture.

## In Scope

- Replace the current minimal onboarding intro with a swipeable 4-5 screen tutorial
- Keep the existing first-run flow:
  - tutorial first
  - then continue into the existing budget setup flow
- Introduce a small shared app color palette for:
  - positive green
  - secondary green
  - warning red
  - neutral gray
  - panel background
- Apply the shared green palette where it clearly improves consistency:
  - Dashboard positive CTA / positive budget states
  - Add Expense save button
  - onboarding primary CTA
  - budget setup actions for income / recurring costs where appropriate

## Out Of Scope

- No navigation redesign
- No new product features
- No settings redesign
- No new analytics
- No onboarding branching or complex permission flow

## Target Files

- `PocketBudget/App/ContentView.swift`
- `PocketBudget/Features/DashboardView.swift`
- `PocketBudget/Features/BudgetSettingsSheet.swift`
- `PocketBudget/Features/AddExpenseSheet.swift`

## Acceptance Criteria

- First-time users see a swipeable onboarding tutorial before budget setup
- The tutorial contains the requested screens and copy in a concise, friendly tone
- The final onboarding action enters the existing setup flow
- Positive and setup-related greens feel visually consistent across the touched screens
- No neon or overly aggressive green remains in the affected primary actions
- Build succeeds
- Stop for manual review before any commit or push
