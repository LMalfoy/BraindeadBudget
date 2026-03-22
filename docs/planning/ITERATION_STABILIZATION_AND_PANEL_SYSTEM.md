# Iteration: Stabilization And Unified Panel System

## Objective

Consolidate the app's chart and panel implementation so the product feels coherent, maintainable, and production-ready without changing its product scope.

This iteration focuses on:

- code quality and maintainability
- regression safety
- visual consistency across chart-based panels
- pragmatic reduction of duplication

This is not a feature iteration.

## Product Constraints

- Do not add new product features.
- Do not change the three-page product architecture.
- Do not redesign onboarding or settings.
- Do not expand analytics beyond what already exists.
- Prefer consolidation over invention.
- Prefer shared layout rules over one-off local fixes.

## In Scope

- Refactor repeated chart and panel layout logic across:
  - Dashboard
  - Month
  - Trends
- Consolidate repeated swipeable chart-card structures.
- Consolidate repeated chart title and subtitle layout rules.
- Consolidate repeated pie chart and legend layout rules.
- Consolidate repeated chart container spacing and sizing rules.
- Improve maintainability where chart panel logic is currently split into one-off local implementations.
- Add or strengthen tests for the core behaviors touched by the refactor.
- Run build and targeted validation after refactoring.

## Out Of Scope

- New charts
- New metrics
- New pages
- Navigation changes
- Settings redesign
- Onboarding redesign
- New dashboard, month, or trends features
- Business-rule changes unless required to preserve already intended behavior

## Refactor Targets

### Primary UI Files

- `PocketBudget/PocketBudget/Features/DashboardView.swift`
- `PocketBudget/PocketBudget/Features/ExpenseHistorySheet.swift`
- `PocketBudget/PocketBudget/Features/StatsView.swift`

### Likely Shared Extraction Targets

Introduce small reusable view structures or shared styling helpers for:

- chart panel container
- chart panel header
- swipeable chart card shell
- pie chart with fixed legend area
- standard line/bar chart panel layout

The goal is not to over-abstract. Extraction should only happen where it removes real duplication and improves consistency.

### Supporting Logic Files

- `PocketBudget/PocketBudget/Data/BudgetStore.swift`

Only touch store logic where needed to support safer testing or to remove duplicated transformation logic used by charts.

## Known Duplication / Inconsistency To Address

- Repeated swipeable `TabView` chart-card patterns across Dashboard, Month, and Trends
- Repeated title/subtitle stacks with slightly different spacing and typography
- Repeated pie chart plus legend compositions with inconsistent legend sizing
- Repeated one-off height and padding tweaks for line and bar charts
- Separate card styling patterns that should feel more unified for chart-based panels

## Unified Chart / Panel Layout Rules

These rules should be applied specifically to chart-based panels across Dashboard, Month, and Trends.

### 1. Title Typography

- Same font size across all chart panel titles
- Same font weight across all chart panel titles
- Same top alignment from the panel edge

### 2. Subtitle Typography

- Same font size for active mode labels or sublabels
- Same regular-weight hierarchy everywhere
- Same secondary text treatment everywhere

### 3. Vertical Spacing

Use the same spacing model for:

- panel edge to title
- title to subtitle
- subtitle to chart
- chart to legend
- chart to page indicators

Avoid one-off per-panel spacing unless technically required.

### 4. Chart Positioning And Scale

- Comparable pie charts should have a consistent visual size
- Comparable line/bar charts should have a consistent visual scale and height
- Charts should sit at a deliberate and stable vertical position within their container
- Charts should fill the available panel space without clipping or colliding with legends or page indicators

### 5. Edge Padding

- Consistent horizontal panel padding
- Consistent chart-to-edge distance
- Consistent bottom protection from swipe dots

### 6. Legend Handling

- Where legend length varies, use planned fixed-height legend areas
- Legends should not shift chart position between swipe views
- Panels should remain stable even when category counts differ

## Performance / Maintainability Goals

- Reduce repeated view-building code in chart panels
- Reduce repeated computed layout structures inside large `body` implementations
- Make chart panels easier to tune from a smaller number of shared layout rules
- Avoid refactoring for abstraction alone; only keep extractions that make the code easier to reason about

## Regression Safety / Test Plan

### Unit / Calculation Focus

Add or improve tests for:

- dashboard summary calculations
- remaining budget and over-budget behavior
- selected-month logic on the Month page
- last-six-month trend calculations
- expense versus income toggle behavior
- transaction filtering behavior

### Likely Test Files

- `PocketBudget/PocketBudgetTests/BudgetCalculationTests.swift`
- `PocketBudget/PocketBudgetTests/BudgetStoreTests.swift`

### Validation Steps

- refresh Xcode diagnostics on edited files
- build the project
- run targeted tests where the harness is reliable enough

If the Xcode test harness times out again, note that clearly and rely on successful build plus strengthened unit coverage.

## Acceptance Criteria

- Dashboard, Month, and Trends chart panels feel visually consistent
- Shared chart panel logic is more centralized and easier to maintain
- Pie chart and legend layouts are stable across varying content lengths
- Chart title and subtitle hierarchy is consistent across the app
- Core calculation and filtering behavior remains correct
- Build succeeds
- The iteration stops for manual UI review before any commit or push

## Review Focus

After implementation, manual review should confirm:

- Dashboard, Month, and Trends feel like one product
- chart titles and subtitles are aligned consistently
- charts are sized consistently and use space well
- legends do not cause layout jumping
- no clipping or overlap occurs
- no core flows regressed:
  - add expense
  - edit expense
  - month switching
  - trend switching
  - transaction filtering
