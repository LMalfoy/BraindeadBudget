# Implementation Checklist v2.9

## Objective

Implement the first savings-based chess progression model.

## Checklist

- define a readable progression model in code
- map saved-budget outcome to chess tiers and sublevels
- allow multiple sublevel gains from strong months when appropriate
- keep the logic deterministic and transparent
- remove or bypass the old behavior-based discipline evaluation from the primary UI
- redesign the progression card below the total overview
- explain progress clearly in the card
- add focused tests for:
  - no progress in weak months
  - ordinary progress in moderate savings months
  - multiple level-ups in strong savings months

## Definition Of Done

- progression is based on budget outcome, not spending style
- the Stats screen still feels coherent
- the implementation is testable and understandable
