# Statistics Roadmap

## Purpose

The Statistics area is the second major product pillar of PocketBudget.

Its purpose is not to add generic analytics. Its purpose is to help the user:

- understand spending behavior
- spot patterns
- make better budgeting decisions
- feel guided rather than overwhelmed

## Product Rules

- add one meaningful module at a time
- every statistics module must include a short plain-language interpretation
- prefer practical insight over chart variety
- avoid dense dashboards
- keep each iteration explainable and testable

## Two Perspectives

The Statistics area should eventually contain two separate perspectives:

### Budget Spending

This is the existing behavioral statistics view.

It focuses on:

- variable spending behavior
- pacing
- category distribution
- temporal pattern
- month comparisons
- carryover and rollover
- discipline rank

### Total Spending

This is a structural monthly-finance view.

It should focus on recurring commitments and fixed monthly costs rather than day-to-day behavior.

It should include only a very small recurring-cost category model:

- Housing / Utilities
- Subscriptions
- Insurance
- Savings
- Debt

This perspective should not affect the behavioral rank system directly.

## Planned Rollout

### Stats v1: Spending by Category

Scope:

- create the Stats area
- show current-month spending by category
- include one short interpretation
- handle empty states

Why first:

- lowest-risk statistics module
- already supported by existing data
- validates the screen structure and interpretation pattern

### Stats v2: Budget Trajectory

Scope:

- show remaining budget trend or spending pace through the current month
- keep the first stats card visually tight to the screen title
- include interpretation such as:
  - `You are spending faster than planned this month`

Why second:

- first strong behavioral feedback module
- directly connected to the budget-control purpose of the app

### Stats v3: Spending by Day / Temporal Pattern

Scope:

- show when spending tends to happen
- first prefer early / mid / late month grouping rather than a denser weekday view
- include interpretation such as:
  - `Your spending is concentrated at the beginning of the month`

Why third:

- exposes spending habits rather than just totals
- still uses existing data safely

### Stats v4: Month-over-Month Comparison

Scope:

- compare current month against the previous month
- show total spending changes and important category shifts
- include interpretation such as:
  - `You are doing better than last month`

Why fourth:

- stronger historical insight
- easier to understand once the earlier modules already exist

### Stats v5: Carryover Insight

Scope:

- show whether carryover into the current month is positive, neutral, or negative
- include a short interpretation such as:
  - `You carried money forward from last month`
  - `Last month reduced this month’s available budget`

Why fifth:

- carryover is already part of the real budget model
- it should become visible before it is folded into the final score

### Stats v6: Budget Discipline Rank

Scope:

- create one lightweight summary rank based on the earlier statistics modules
- include the carryover signal as an explicit input
- include leftover budget percentage as an explicit input
- keep the model rule-based and transparent
- show the reasons behind the rank directly in the UI
- include a chess-themed role progression:
  - Pawn
  - Knight
  - Bishop
  - Rook
  - Queen
  - King

Why last:

- the rank should summarize real behavioral signals
- it should not precede the modules it depends on

## Immediate Refinement Step

After the first complete rollout is in place, the next practical step is not a brand-new module. It is refinement of two existing modules:

- Spending Pattern should use finer intra-month sampling than only early / mid / late
- Month Comparison should expand into a trailing 6-month view

These changes should sharpen the quality of behavioral feedback while keeping the Stats area understandable.

## Planned Total Spending Rollout

### Total Spending v1: Perspective Split

Scope:

- add a top switch between `Budget Spending` and `Total Spending`
- preserve the existing behavioral view as-is
- create the structural shell for fixed-cost statistics

### Total Spending v2: Fixed Cost Ratio And Distribution

Scope:

- show what share of monthly income is already committed to fixed costs
- show how fixed costs are distributed across the recurring-cost categories
- include short interpretations

### Total Spending v3: Subscription Load And Savings Stability

Scope:

- show subscription count and total monthly subscription cost
- show savings amount and savings share when applicable
- include short interpretations
- support the Total Spending rollout with a clearer recurring-cost setup flow

### Total Spending v4: Recurring Cost Entry Redesign

Scope:

- redesign recurring-cost entry to visually match the add-expense flow
- keep 5 recurring-cost categories visible in one row
- preserve the faster, category-first interaction pattern

### Total Spending v5: Perspective Completion

Scope:

- treat the current `Total Spending` tab as a finished recurring-cost structure view
- tighten wording, interpretations, and empty states where needed
- make the perspective feel complete and intentional before larger product shifts

Important:

- this still does not represent true combined total spending
- variable spending should be folded into a future redesign only after onboarding and image work

## Later Structural Redesign

After the recurring-cost perspective, mid-period onboarding, and the image/icon pass are complete, the product should revisit the statistics information architecture.

At that point, `Total Spending` may need to evolve into one of these forms:

- a true combined-spending perspective
- a three-way split such as `Budget Spending`, `Fixed Costs`, and `Total Spending`
- another structure that keeps behavioral and structural insights clear

That redesign should be planned deliberately rather than appended onto the current fixed-cost rollout.

## Non-Goals For Early Stats

- no speculative machine-learning style predictions
- no overly dense multi-chart dashboard
- no arbitrary hidden scoring system before the underlying modules exist
- no category drill-down until the core Stats area is stable enough to justify it
