# Implementation Checklist v2.7

## Objective

Make onboarding realistic by requiring a current available budget anchor for the user’s first active period.

## Checklist

- inspect the current onboarding/setup flow
- identify the smallest safe place to ask for current available budget
- add a required onboarding field for the current available variable budget
- store the initial active-period anchor without fabricating expenses
- update budget calculations so the current active period can start from that anchor
- preserve normal carryover logic for later periods
- verify that the first-period anchor does not distort statistics with fake historical data
- add or update tests for:
  - first-period anchored remaining budget
  - later-period carryover continuity
  - first-run onboarding validation

## Definition Of Done

- onboarding always asks for current available budget
- the first period uses a real anchor instead of a guessed reset state
- no fake expense backfill is used
- the build stays green and the targeted tests provide real signal
