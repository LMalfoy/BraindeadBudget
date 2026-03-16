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

### Stats v5: Budget Discipline Score

Scope:

- create one lightweight summary score based on the earlier statistics modules
- include a chess-themed role progression:
  - Pawn
  - Knight
  - Bishop
  - Queen
  - King

Why last:

- the score should summarize real behavioral signals
- it should not precede the modules it depends on

## Non-Goals For Early Stats

- no speculative machine-learning style predictions
- no overly dense multi-chart dashboard
- no arbitrary scoring system before the underlying modules exist
- no category drill-down until the core Stats area is stable enough to justify it
