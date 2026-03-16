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

## Three Perspectives

The Statistics area should now evolve into three separate perspectives:

### Total Spending

This should become the default Statistics landing page.

It should provide:

- a complete monthly financial overview
- a combined spending chart that includes both variable and recurring costs
- one or two high-level synthesis cards only

This page should feel broad and simple, not overloaded.

### Budget Spending

This is the behavioral statistics view.

It focuses on:

- variable spending behavior
- pacing
- category distribution
- temporal pattern
- month comparisons
- carryover and rollover

### Recurring Spending

This is the structural monthly-finance view.

It focuses on recurring commitments and fixed monthly costs.

It should include only a very small recurring-cost category model:

- Housing / Utilities
- Subscriptions
- Insurance
- Savings
- Debt

It should remain separate from behavioral performance judgment.

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

### Stats v6: Savings-Based Chess Progression

Scope:

- replace the current behavior-based discipline summary
- move progression lower on the page beneath the top overview
- base progression on budget outcome rather than spending style
- reward how much budget is saved by the end of the period
- use chess-themed piece tiers and sublevels

Why last:

- progression should sit on top of a stable statistics architecture
- it should reward real budgeting results, not arbitrary style metrics

## Immediate Refinement Step

After the first complete rollout is in place, the next practical step is not a brand-new module. It is refinement of two existing modules:

- Spending Pattern should use finer intra-month sampling than only early / mid / late
- Month Comparison should expand into a trailing 6-month view

These changes should sharpen the quality of behavioral feedback while keeping the Stats area understandable.

## Planned Recurring Spending Rollout

### Recurring Spending v1: Perspective Split

Scope:

- create a separate structural view for recurring costs
- preserve the behavioral view as-is
- keep the recurring-cost statistics isolated from the future total-overview page

### Recurring Spending v2: Fixed Cost Ratio And Distribution

Scope:

- show what share of monthly income is already committed to fixed costs
- show how fixed costs are distributed across the recurring-cost categories
- include short interpretations

### Recurring Spending v3: Subscription Load And Savings Stability

Scope:

- show subscription count and total monthly subscription cost
- show savings amount and savings share when applicable
- include short interpretations
- support the Total Spending rollout with a clearer recurring-cost setup flow

### Recurring Spending v4: Recurring Cost Entry Redesign

Scope:

- redesign recurring-cost entry to visually match the add-expense flow
- keep 5 recurring-cost categories visible in one row
- preserve the faster, category-first interaction pattern

### Recurring Spending v5: Perspective Completion

Scope:

- treat the current recurring-cost perspective as a finished structure view
- tighten wording, interpretations, and empty states where needed
- make the perspective feel complete and intentional before larger product shifts

Important:

- this still does not represent true combined total spending
- variable spending should be folded into a future redesign only after onboarding and image work

## Next Structural Redesign

After the recurring-cost perspective, mid-period onboarding, and the image/icon pass are complete, the product should revisit the statistics information architecture directly.

The target structure should be:

- `Total Spending` as the default overview
- `Budget Spending` as the behavioral sub-page
- `Recurring Spending` as the structural sub-page

## Progression Redesign

The old discipline-rank approach should be replaced.

The new progression system should:

- ignore harmless style differences such as early spending or category concentration
- reward budget savings outcome instead
- use cumulative progress across periods
- use chess piece tiers plus named sublevels
- allow strong months to produce multiple level-ups when deserved

### Proposed Shape

- `Pawn` tier with 5 sublevels
- `Knight` tier with 5 sublevels
- `Bishop` tier with 5 sublevels
- `Rook` tier with 5 sublevels
- `Queen` tier with 5 sublevels
- `King` as one final unlocked state

The visible UI should use Roman numerals for the sublevels and attach a named chess motif to each one.

Current direction:

- Pawn I: Isolated Pawn
- Pawn II: Doubled Pawn
- Pawn III: Connected Pawn
- Pawn IV: Passed Pawn
- Pawn V: Pawn on the Sixth Rank

- Knight I: Corner Knight
- Knight II: Developing Knight
- Knight III: Central Knight
- Knight IV: Outpost Knight
- Knight V: Royal Forking Knight

- Bishop I: Locked Bishop
- Bishop II: Bishop Outside Pawn Chain
- Bishop III: Fianchetto Bishop
- Bishop IV: Long Diagonal Bishop
- Bishop V: Bishop Pair

- Rook I: Sleeping Rook
- Rook II: Connected Rooks
- Rook III: Open File Rook
- Rook IV: Seventh Rank Rook
- Rook V: Rook Battery

- Queen I: Undeveloped Queen
- Queen II: Developed Queen
- Queen III: Centralized Queen
- Queen IV: Dominant Queen
- Queen V: Forking Queen

- King: Crowned King
  - "The king is a fighting piece."
  - Jose Raul Capablanca

Each sublevel should also include a short chess quote with attribution.

The progression input should be the saved budget percentage at period end.

The early direction for thresholds is:

- Pawn levels: 5% progress steps
- Knight levels: 6% progress steps
- Bishop levels: 7% progress steps
- Rook levels: 8% progress steps
- Queen levels: 9% progress steps
- King: final top state unlocked by a 10% level threshold

The exact math should be implemented clearly and defensibly in code, but the product intent is:

- better savings produce more progression
- a strong month can advance more than one sublevel
- progression should feel cumulative, not like a volatile monthly rating

This progression layer should sit below the overview rather than leading the Statistics page.

## Non-Goals For Early Stats

- no speculative machine-learning style predictions
- no overly dense multi-chart dashboard
- no arbitrary hidden scoring system before the underlying modules exist
- no category drill-down until the core Stats area is stable enough to justify it
