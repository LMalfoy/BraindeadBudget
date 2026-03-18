# Iteration 2.0.4 Spec

## Title

Achievements Beta

## Goal

Introduce a lightweight achievements system that adds motivation and positive reinforcement without bloating the product or making it feel game-first.

## Scope

- add a compact achievements preview card inside the statistics / progression area
- tapping the preview should open a dedicated achievements detail page
- display locked and unlocked achievements distinctly
- each achievement should be tappable and show:
  - title
  - description
  - unlock condition
  - unlocked state and unlock date if applicable
- evaluate and persist a first curated set of 10 achievements
- show a small in-app unlock notification when a new achievement is earned
- include only the minimum safe-spend streak logic needed to support `Steady Hand`

## Initial Achievement Set

- `Architect of Order`
  - unlock when initial setup is completed
- `First Step`
  - unlock when the first expense is logged
- `Habit Builder`
  - unlock when 100 expenses are logged
- `Steady Hand`
  - unlock when safe-spending streak reaches 7 days
- `Surgical Precision`
  - unlock when a completed spending period finishes within ±5% of the available budget for that period
- `Room to Breathe`
  - unlock when completed-period budget remainder is at least 10%
- `Financial Cushion`
  - unlock when completed-period budget remainder is at least 30%
- `Spartan Mode`
  - unlock when completed-period budget remainder is at least 50%
- `Course Correction`
  - unlock after three consecutive periods of decreasing spending
- `Checkmate`
  - unlock when the user reaches `King` in chess progression

## Out Of Scope

- final badge artwork
- large animation system
- social sharing
- top-level navigation changes
- a separate achievements tab
- a large achievement gallery beyond the first curated set

## UI / UX Expectations

- the achievements preview should stay secondary to the main progression content
- the preview may show unlocked count and a few recent badges, but should remain compact
- detail page should feel curated, not like a grind checklist
- locked badges should remain visible but muted
- unlock feedback should be rewarding and small, not intrusive

## Data Changes

- add persistence for unlocked achievements and unlock dates
- add modular unlock evaluation logic triggered by measurable events
- avoid unverifiable achievements or anything that implies bank-validated savings

## Tests

- verify preview card placement and navigation to the detail page
- verify locked/unlocked rendering
- verify badge detail display
- verify unlock conditions for the initial achievement set
- verify unlock notifications appear once per new achievement
- verify no navigation clutter or regression in the stats/progression area

## Why This Matters

- achievements can reinforce good budgeting habits when they remain meaningful and limited
- this adds long-term motivation without changing the app's core product identity
- a clean beta system now makes future badge art and expansion straightforward
