# PocketBudget Roadmap

## Planning Approach

PocketBudget should grow through small, low-risk iterations. Each iteration should produce one clear product improvement, remain testable, and avoid bundling multiple major changes together.

The roadmap below reflects the updated product direction:

- calculate the monthly spending budget from income and recurring commitments
- make expense entry extremely easy
- show remaining budget and category insights immediately on launch

## Current State: v0.1

Implemented now:

- manual monthly budget setting
- manual expense entry
- current month summary
- local persistence
- baseline unit tests for storage and month-based calculations

Main gaps versus target product:

- no onboarding or first-run setup
- no income tracking
- no recurring monthly commitments
- no calculated spending budget
- no expense categories
- no chart-based overview
- no ultra-fast expense entry mode
- no edit or delete flow for recorded expenses

## Roadmap Themes

- Build a trustworthy monthly budget baseline
- Remove friction from daily expense capture
- Make the dashboard instantly useful
- Keep implementation small and testable

## Proposed Iterations

### Iteration 0.2: Budget Foundation Setup

Goal:
Replace the single manual budget number with a calculated monthly spending budget.

Scope:

- first-run setup flow
- support one or more monthly income items
- support recurring monthly commitment items
- calculate monthly spending budget from income minus recurring commitments
- update tests around budget calculation behavior

Why this matters:

- this is now the product’s most important calculation
- it defines the number the rest of the app depends on

Risk:
Medium

Validation:

- unit tests for monthly budget calculation logic
- unit tests for edge cases such as zero or multiple income items
- manual test of first-run setup and recalculation after editing values

### Iteration 0.3: Frictionless Expense Entry v1

Goal:
Make adding daily expenses much faster and simpler.

Scope:

- redesign add-expense flow around category, item, and amount
- use four fixed categories: Food, Transport, Household, and Fun
- make category selection the first and easiest interaction in the form
- keep date and note as secondary optional fields
- improve keyboard flow so the item field is ready immediately and submit moves to amount
- move the add-expense action to a bottom, thumb-friendly position
- show category visually in the expense list with restrained color coding

Why this matters:

- fast daily entry is the main product habit loop
- the app only works if recording an expense feels easy enough to do every time

Risk:
Low to medium

Validation:

- manual repeated-entry testing
- regression tests for validation behavior
- UI test for adding an expense with category and amount
- manual one-handed reachability check on common phone sizes

### Iteration 0.4: Dashboard Priority Layout

Goal:
Make the home screen immediately useful and action-oriented.

Scope:

- prioritize remaining budget visually
- show recent expenses clearly
- tighten empty states and first-run guidance
- refine the dashboard layout after the new bottom add-expense action is in place
- remove low-value visual noise such as redundant screen headlines
- keep date and note visible in the add-expense form while preserving a fast main flow
- improve list spacing, hierarchy, and readability without adding clutter

Why this matters:

- the app should answer the budget question instantly on open
- the primary action should always be obvious
- the app should feel polished, not just functional

Risk:
Low

Validation:

- manual UI review on common device sizes
- UI test for dashboard visibility and primary add-expense action
- manual pass on the add-expense form to confirm secondary fields remain easy to access

### Iteration 0.5: Category Overview

Goal:
Show where variable spending is going.

Scope:

- aggregate current-month expenses by category
- add a simple dashboard chart, likely a pie or donut chart
- highlight largest spending category clearly
- keep the chart limited to the current month and the four fixed categories
- ensure the chart supports the existing clean dashboard layout

Why this matters:

- category feedback turns tracking into decision support
- it helps the user spot the biggest spending bucket quickly

Risk:
Medium

Validation:

- unit tests for category aggregation
- manual visual checks for small and large category sets
- ensure chart does not crowd the dashboard
- verify zero-expense and single-category states remain readable

### Iteration 0.6: Expense Correction Basics

Goal:
Let the user fix mistakes in recorded spending.

Scope:

- delete an expense
- optionally add a simple detail sheet if it supports the delete flow cleanly
- defer full edit support unless it remains small and stable
- ensure totals update immediately after changes
- add safe destructive-action confirmation if needed

Why this matters:

- fast entry increases the chance of small mistakes
- trust requires that errors can be corrected

Risk:
Low

Validation:

- unit tests for delete and recalculation behavior
- UI test for the basic correction flow
- manual check that dashboard totals update correctly
- manual confirmation that deletion does not feel accidental or unclear

### Iteration 0.7: Polish Pass

Goal:
Refine the existing experience on real devices and remove rough edges without expanding the feature surface.

Scope:

- tighten dashboard spacing and panel alignment
- remove small redundant UI where it does not help comprehension
- refine chart presentation if needed
- smooth expense-entry interaction details discovered during real-device use
- address small polish notes that fit naturally within the current screens

Why this matters:

- the app is already useful, so quality improvements now have high leverage
- polishing before more feature work reduces future churn

Risk:
Low

Validation:

- manual real-device review on iPhone
- regression test pass
- targeted fixes for issues discovered during real usage

### Iteration 0.8: Final Stabilization

Goal:
Do a final bug-fix, refactor, and stability pass before the next feature expansion.

Scope:

- fix remaining small bugs
- do a careful low-risk cleanup pass
- improve test reliability
- remove narrow rough edges discovered during v0.7 review
- verify that the existing core flows are dependable on simulator and device

Why this matters:

- this creates a stronger base for the next larger feature set
- it reduces the risk of stacking new features onto shaky UX details

Risk:
Low

Validation:

- full test pass
- manual regression testing across the main flows
- confirm no known critical friction remains in the core app
- confirm the existing automated test suite is still worth trusting or narrow it if needed

### Iteration 0.9: Settings Area

Goal:
Move app-level controls out of the dashboard and into a dedicated settings surface.

Scope:

- move budget editing into settings
- keep first-run budget setup behavior when no baseline exists
- add app/version/about information
- include author credits for Dr. Kevin Sicking and Codex (GPT-5)
- leave room for future customization options

Why this matters:

- the dashboard should focus on action and status, not app configuration
- settings become easier to extend later without cluttering the home screen

Risk:
Low to medium

### Iteration 1.0: Carryover Budgeting

Goal:
Carry monthly budget state forward so each month reflects the true leftover balance from the previous one.

Scope:

- roll positive remainder forward
- roll negative overspending forward
- calculate the active month as baseline plus previous month carryover
- keep dashboard totals understandable after this model change

Why this matters:

- it makes the budget more realistic
- it gives continuity between months instead of hard resets

Risk:
Medium

Validation:

- unit tests for positive carryover, negative carryover, and zero-carryover cases
- manual checks around month boundaries
- confirm dashboard wording still matches the calculation model

### Iteration 1.1: Monthly Expense History

Goal:
Provide a full month-based expense view for review, editing, and deletion.

Scope:

- dedicated history screen
- adjacent month navigation
- full expense list for the selected month
- edit and delete from that view
- keep dashboard totals and carryover in sync after changes

Why this matters:

- the dashboard only shows a lightweight preview
- users need a reliable correction and review surface

Risk:
Medium

Validation:

- unit tests for month filtering and expense updates
- UI tests for opening history and correcting expenses there
- manual verification that dashboard numbers react correctly after edits

### Iteration 1.2: Bottom Navigation

Goal:
Give the app a clearer structure now that it has multiple primary surfaces.

Scope:

- slim bottom navigation bar
- Home, History, and Settings tabs
- keep the dashboard read-only
- limit dashboard expense preview to the 10 most recent items
- keep editing and deletion inside monthly history

Why this matters:

- it separates overview, correction, and configuration cleanly
- it reduces dashboard clutter without hiding important functionality

Risk:
Low to medium

Validation:

- UI tests for tab navigation
- regression tests for add, edit, delete, and settings access
- manual review of tab-bar size and visual weight on iPhone

### Iteration 1.3: History Upgrade And Entry-Flow Polish

Goal:
Make monthly history substantially more informative while smoothing one small but frequent expense-entry interaction.

Scope:

- allow direct month/year selection from the history month header
- add a compact monthly digest to history
- show period totals that help explain the selected month
- keep edit/delete in history as-is
- let Return or Send submit an expense once the amount is valid

Why this matters:

- history becomes a stronger decision surface instead of just a long list
- expense entry removes one unnecessary confirmation tap in a common path

Risk:
Medium

Validation:

- unit tests for any new month-selection helpers or digest calculations
- UI tests for opening the picker and navigating history
- UI/manual validation for keyboard submit behavior in the add-expense flow

### Iteration 1.4: History Screen Polish

Goal:
Tighten the monthly history experience so it feels more consistent and less visually heavy.

Scope:

- reuse the add-expense style editor when editing from history
- remove redundant section chrome from the history list
- make the month/year picker lighter and smaller than the current full-page presentation
- preserve the current history capabilities and data behavior

Why this matters:

- the history screen is now important enough that rough edges stand out
- polish here improves trust without expanding the product surface

Risk:
Low to medium

Validation:

- manual checks that history editing still works correctly
- UI tests for opening and using history after the presentation change
- regression checks that edit/delete behavior remains unchanged

### Iteration 1.5: Statistics Foundation

Goal:
Create the Statistics area and deliver the first useful behavioral module without overextending the feature.

Scope:

- add a dedicated Stats surface to the app structure
- implement only current-month Spending by Category
- include a short plain-language interpretation
- handle empty states cleanly
- keep the design aligned with the rest of the app

Why this matters:

- it opens the second major product pillar
- it validates the statistics screen structure and interpretation pattern
- it adds insight without committing to the full analytics roadmap at once

Risk:
Medium

Validation:

- unit tests for any extracted statistics helpers
- UI test for reaching the Stats area
- manual review of chart readability and interpretation clarity

### Iteration 1.6: Budget Trajectory

Goal:
Add the first pacing-oriented statistics module so the user can judge whether spending is on track through the current month.

Scope:

- add a Budget Trajectory / Remaining Budget Trend module to Stats
- include a short plain-language interpretation
- keep the chart simple and easy to understand
- tighten the Stats screen top spacing so the first module sits directly below the title

Why this matters:

- it is the first statistics module that reflects spending behavior over time
- it moves the app from static breakdowns toward active budgeting guidance

Risk:
Medium

Validation:

- unit tests for any extracted trajectory helpers
- UI test for opening Stats after the new module is added
- manual review of trend readability and interpretation quality

### Iteration 1.7: Temporal Pattern

Goal:
Show when spending tends to happen during the month so users can spot timing habits, not just totals.

Scope:

- add one temporal spending module to Stats
- group current-month spending into a simple time-of-month pattern
- include a short plain-language interpretation
- keep the module easy to understand at a glance

Why this matters:

- category explains where spending goes
- trajectory explains how fast it declines
- temporal pattern explains when spending pressure tends to happen

Risk:
Medium

Validation:

- unit tests for the temporal grouping helper
- UI test for opening Stats after the module is added
- manual review that the interpretation remains clear and useful

Validation:

- manual review of onboarding-to-settings behavior
- verify budget editing still works correctly
- ensure the dashboard becomes simpler rather than harder to navigate

### Iteration 1.0: Full Carryover Budgeting

Goal:
Carry the previous month’s remaining balance into the next month’s available budget.

Scope:

- calculate prior-month remainder
- carry both positive and negative balances into the next month
- update the dashboard budget number to reflect baseline plus carryover
- keep the carryover rule limited and explicit
- verify the rule works across month boundaries without changing the rest of the product surface

Why this matters:

- this changes the meaning of the app’s most important number
- it makes the budgeting model more realistic and continuous across months

Risk:
Medium

Validation:

- unit tests for positive and negative carryover
- unit tests for month-boundary calculations
- manual verification with realistic month-to-month scenarios

### Iteration 1.1: Expense History

Goal:
Let the user browse and manage expenses by month.

Scope:

- dedicated expense-history sheet
- month/year navigation
- month-specific expense list
- edit/delete from that history view

Why this matters:

- users need a complete view of a given month, not only recent dashboard rows
- this becomes more valuable once carryover makes month boundaries more important

Risk:
Medium

Validation:

- manual testing across multiple months
- verification that edits and deletes update related dashboard values correctly
- confirm the history navigation remains easy to understand

### Iteration 1.2: Bottom Navigation Structure

Goal:
Introduce a slim bottom navigation bar that cleanly separates overview, history, and settings.

Scope:

- add bottom navigation with Home, History, and Settings
- keep the bar small and visually quiet
- keep the dashboard focused on summary plus recent expenses
- limit the dashboard recent-expense preview to a small recent set
- keep dashboard recent expenses read-only
- keep edit/delete behavior inside monthly history only
- slightly reduce the visual weight of dashboard expense rows

Why this matters:

- the app now has multiple real surfaces and needs clearer navigation
- separating overview, history, and settings should make the product easier to understand and extend

Risk:
Medium

Validation:

- manual navigation checks across all three tabs
- verify monthly history remains the only correction surface
- confirm the dashboard feels cleaner and less crowded

### Iteration 1.3: Gesture Navigation Polish

Goal:
Explore whether navigation between dashboard, history, and settings can later feel even smoother through gesture polish.

Scope:

- consider history-opening gestures from the dashboard
- consider less persistent settings exposure if it remains clear
- only build on top of the stable bottom-navigation structure

Why this matters:

- gesture polish is more sensible once the app structure is already clear

Risk:
Medium

Validation:

- manual real-device testing on iPhone
- confirm gestures do not conflict with ordinary scrolling
- retain clear explicit navigation if gestures feel ambiguous

### Post-1.0 Candidates

Potential next feature directions after stabilization:

- category drill-down into underlying expenses
- period-aware budgeting rules such as monthly carryover

### Deferred Idea: Smart Single-Line Entry

Goal:
Reduce entry friction further with intelligent parsing if real usage eventually justifies it.

Scope:

- support single-line expense input such as `4 coffee` or `coffee 4`
- parse amount and item with clear fallback behavior
- keep manual structured entry available

Why this matters:

- this may eventually make the app feel faster
- but it is lower priority than polish, stability, and visibility features right now

Risk:
Medium to high

Validation:

- unit tests for parsing rules and ambiguous inputs
- manual testing with realistic examples
- clear failure behavior when parsing confidence is low

## Suggested Category Set For Early Versions

Start simple:

- Food
- Transport
- Household
- Fun

These can change later, but the first version should optimize for speed and clarity rather than perfect categorization.

## What To Avoid For Now

These ideas are likely too broad for the near term:

- bank integrations
- recurring expense auto-import
- advanced forecasting
- shared or family budgets
- large analytics dashboards
- major architecture rewrites

## Release Discipline

For each iteration:

1. Define a single user-visible outcome.
2. Keep the data model changes as small as possible.
3. Add or update tests for calculation and persistence logic.
4. Verify manually in the simulator.
5. Do not combine foundation work, UI redesign, and smart parsing into one release.
