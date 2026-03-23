## Objective

Polish naming consistency on the Month page, make Monthly Trends visually comparable, stabilize Category Trends layout, and ensure chart formatting respects the selected currency.

## In Scope

- Month page category card title/subtitle cleanup
- Replace swipe-based Monthly Trends with one combined comparison chart
- Improve Category Trends legend/dot separation and axis stability
- Centralize chart currency/axis formatting so graphs use the selected currency
- Optionally prioritize `EUR` and `USD` near the top of currency selection

## Out of Scope

- New product features
- Structural redesign of Dashboard, Month, or Trends
- Changes to onboarding, setup flow, or non-chart cards
- New analytics or new chart types beyond the combined monthly comparison chart

## Acceptance Criteria

- Month page category card uses:
  - title: `Spending by Category`
  - swipe subtitle: `Variable Spending`, `Recurring Spending`, `Total Spending`
- Trends page Monthly Trends becomes one 6-month chart with 3 bars per month:
  - Variable Spending
  - Recurring Spending
  - Total Spending
- Monthly Trends includes a small legend below the chart
- Category Trends no longer lets the legend collide with swipe dots
- Category Trends axis scaling feels more deliberate and stable across modes
- Chart axes and chart-specific monetary labels use the selected currency instead of a hardcoded euro symbol
- Currency picker still allows all currencies and can surface `EUR` and `USD` near the top

## UI Constraints

- Keep current page structure
- Preserve chart panel styling and title/subtitle hierarchy
- Keep category palette consistent with the existing app theme
- Favor simple, readable comparison over decorative chart treatments
