Objective
- Consolidate the app before any further feature work by improving code quality, regression safety, and visual consistency across chart-based panels.

High-Level Scope
- Refactor repeated chart and panel structures across Dashboard, Month, and Trends
- Improve regression safety for core budgeting, entry-flow, and selected-month logic
- Define and apply one unified chart/panel layout system

Out of Scope
- New product features
- New screens or navigation changes
- Onboarding redesign
- Settings redesign
- Business-logic changes unless required to preserve existing behavior during cleanup

Phase 1: Refactor / Code Quality / Performance

Primary refactor targets
- Dashboard chart panels in [DashboardView.swift]
- Month chart panels in [ExpenseHistorySheet.swift]
- Trends chart panels in [StatsView.swift]
- Shared chart card styling patterns currently split between:
  - `dashboardCardStyle()`
  - `trendsCardStyle()`
  - local month card backgrounds / paddings

Specific duplication and maintainability issues found
- Repeated swipeable `TabView(.page)` card structures in Dashboard, Month, and Trends
- Repeated title/subtitle/chart/legend stacking logic with slightly different spacing rules
- Repeated pie-chart + legend layouts in Dashboard and Month
- Repeated chart card padding and corner-radius styling
- Repeated category color mapping logic across files
- Repeated chart sizing constants spread locally across screens
- Trend panel subtitle behavior currently reimplemented per panel instead of following one panel system

Performance / render hotspots to review during implementation
- Large screen files with many derived view-local properties:
  - [DashboardView.swift]
  - [ExpenseHistorySheet.swift]
  - [StatsView.swift]
- Inline chart sizing / formatting logic repeated in multiple subviews
- Recomputed legend arrays and chart-derived display state inside large view bodies
- Potential excess view invalidation from local `@State` page-selection logic per card

Planned refactor direction
- Extract shared chart/panel primitives, likely into small reusable view components or modifiers:
  - chart card shell
  - panel header block
  - swipeable chart card shell
  - pie chart + fixed legend layout
  - line/bar chart container with standard spacing
- Consolidate shared color mapping for expense and recurring categories
- Centralize panel sizing constants so chart heights and spacing stop drifting screen-by-screen
- Keep data semantics where they are unless extraction is clearly safe and reduces duplication

Phase 2: Regression Safety / Testing

Test areas to strengthen or explicitly re-check
- Dashboard summary calculations
  - remaining budget
  - over-budget handling
  - available budget semantics
- Month page selected-month behavior
  - selected-month expense set
  - selected-month trajectory
  - selected-month category summaries
- Trends 6-month behavior
  - monthly spending histories
  - category trend histories
  - carryover history
- Entry flows
  - add expense
  - edit expense
  - expense vs income toggle signed-amount behavior
- Filtering behavior
  - selected-month transaction filtering by category

Planned test work
- Add targeted calculation/store tests where coverage is still thin after refactor
- Re-run diagnostics on all touched production files
- Build the project after refactor
- Attempt targeted tests first instead of full-suite runs, because the Xcode harness in this environment has timed out repeatedly

Phase 3: Unified Chart / Panel Layout System

Unified layout rules to introduce

1. Title typography
- One shared main title font and weight for all chart-based panels
- Applies to:
  - Dashboard insight cards
  - Month chart cards
  - Trends chart cards

2. Subtitle typography
- One shared subtitle font, weight, and color for active mode labels / sublabels
- Subtitles must always read as subordinate to panel titles

3. Vertical spacing
- One shared top padding from panel edge to title
- One shared title-to-subtitle spacing
- One shared subtitle-to-chart spacing
- One shared chart-to-legend / chart-to-page-indicator spacing
- One shared bottom padding baseline

4. Chart positioning and sizing
- Standard chart panels should use a shared chart height tier
- Pie-chart panels should use a shared chart height tier
- Comparable panels should place charts at the same vertical position
- Charts should fill the intended area without clipping or excess dead space

5. Edge padding
- One shared horizontal inset for chart panels
- One shared content inset inside chart cards
- Swipe indicators must have deliberate separation from the chart area

6. Legend handling
- Fixed legend-height strategy where category count varies
- Stable pie + legend composition for Month and any similar panels
- Stable line-chart + legend composition for Trends category panels

Concrete implementation candidates
- `UnifiedChartCardStyle`
- `PanelHeaderView(title:subtitle:)`
- `SwipeChartCard`
- `PieLegendPanel`
- `StandardTrendPanel`
- `ChartLayoutMetrics`

Acceptance Criteria
- Dashboard, Month, and Trends chart-based panels feel like one visual system
- Panel titles/subtitles align consistently
- Chart sizes feel deliberate and comparable across screens
- Pie and line/bar chart panels no longer feel individually tuned
- Existing behavior remains intact:
  - dashboard math
  - selected-month behavior
  - 6-month trends
  - add/edit entry flows
  - expense vs income signed entries

Implementation Notes
- Favor consolidation over clever abstraction
- Only extract shared components when at least two screens clearly benefit
- Avoid a “framework inside the app”; keep the shared system lightweight and obvious
- Prefer deleting one-off spacing hacks when a shared rule replaces them
