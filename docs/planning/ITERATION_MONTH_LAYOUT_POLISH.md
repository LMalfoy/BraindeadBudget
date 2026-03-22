Objective
- Refine the Month page layout for consistency and small UI improvements without changing behavior.

In Scope
- Stabilize the three category chart pages so title and pie chart stay at the same vertical position
- Use a fixed-height legend area sized for up to 9 items
- Add more whitespace around the budget trajectory chart
- Enrich recurring breakdown summaries with total amount and item count
- Restyle transaction filters to match the Add Expense category selector more closely

Out of Scope
- Any new Month-page functionality
- Changes to selected-month data semantics
- Dashboard changes
- Trends changes
- Store logic changes unless strictly required for layout-only support

Acceptance Criteria
- Swiping between the three category chart pages does not vertically shift the title or pie chart
- Legend area remains stable even when the item count differs
- Budget trajectory card feels less cramped
- Recurring breakdown shows both total monthly cost and item count
- Transaction filters use icon + color styling consistent with Add Expense
