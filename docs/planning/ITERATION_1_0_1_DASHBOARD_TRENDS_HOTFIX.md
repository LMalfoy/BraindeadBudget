## Objective

Ship the final 1.0.1 polish hotfix by fixing Dashboard Budget Trajectory correctness, improving Daily Safe Spend visibility, and sorting Category Trends legends by value.

## In Scope

- Update app version to `1.0.1`
- Improve Daily Safe Spend presentation in Dashboard
- Fix Dashboard Budget Trajectory start value, y-axis upper bound, and dashed reference line behavior
- Align Dashboard Trajectory styling more closely with Month
- Sort Category Trends legend by descending value

## Out of Scope

- New features
- Structural redesign
- Changes to non-requested screens

## Acceptance Criteria

- Settings version reads `Version 1.0.1 (Build X)`
- Daily Safe Spend is larger, green, and never displays below `0`
- Dashboard Trajectory always includes the true starting budget value
- Dashboard dashed line uses the real start value and decreases by a real per-day step
- Category Trends legends are sorted by descending value
