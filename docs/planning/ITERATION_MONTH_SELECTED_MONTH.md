Objective
- Refine the Month page so every summary, chart, breakdown, and transaction list is based on the selected month/period instead of the current real-world month.

In Scope
- Month navigation with previous/next arrows
- Tappable month label that opens a month/year picker
- Selected-month data flow for all Month page content
- One swipeable category chart card with:
  - variable spending by category
  - recurring spending by category
  - total spending by category
- Selected-month budget trajectory
- Recurring breakdown list for subscriptions and insurance
- Transaction filter buttons and filtered transaction list for the selected month

Out of Scope
- Dashboard changes
- Trends changes
- New analytics beyond the specified Month page content
- Achievement/progression/gamification work
- Editing redesign for recurring items or transactions

Acceptance Criteria
- The Month page shows a selected month label like "March 2026"
- Previous/next arrows update the selected month
- Tapping the month label opens a month/year picker and updates the page after selection
- All Month page sections update from the selected month/period, not from Date.now
- The swipeable category card contains exactly three views:
  - Variable Spending by Category
  - Recurring Spending by Category
  - Total Spending by Category
- Budget Trajectory reflects the selected month/period
- The recurring breakdown includes only Subscriptions and Insurance, each with total and item list
- The transaction filter updates the selected-month transaction list only

UI / Product Constraints
- Keep the page minimal and month-specific
- Avoid interpretive insights or extra analytics
- Preserve the product distinction:
  - Dashboard = where do I stand right now?
  - Month = what happened in this selected month?
  - Trends = multi-month development
