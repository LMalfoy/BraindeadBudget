# Iteration: Global Chart Polish

## Objective

Improve visual consistency and professional polish across chart-based panels without changing product scope or adding features.

## In Scope

- Better vertical balance inside chart panels
- Fixed-height, scrollable legend handling for pie-chart panels
- Unified whole-number euro formatting for graph Y-axes
- Dashboard top card outer padding consistency

## Out Of Scope

- New features
- New analytics
- Navigation changes
- Product structure changes
- Business-logic changes

## Target Files

- `PocketBudget/Features/DashboardView.swift`
- `PocketBudget/Features/ExpenseHistorySheet.swift`
- `PocketBudget/Features/StatsView.swift`

## Layout Rules

- Chart panel content should feel vertically centered as a block:
  - title
  - chart
  - legend or page indicators
- Pie legends show at most 5 items without scrolling
- If more than 5 items exist, the legend area scrolls inside a fixed-height container
- Graph Y-axes use whole-number euro labels only
- Dashboard summary card uses the same outer inset rhythm as the other dashboard panels

## Acceptance Criteria

- Dashboard chart modes feel vertically balanced against each other
- Month and Trends pie-chart panels keep a stable chart position despite legend length changes
- Pie legends remain fixed in height and become scrollable after 5 items
- Relevant graph panels show whole-number euro Y-axis labels consistently
- Dashboard top card no longer has a visually thinner top edge in light mode
- Build succeeds
- Stop for manual review before commit or push
