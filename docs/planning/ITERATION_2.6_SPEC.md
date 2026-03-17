# Iteration 2.6 Spec

## Title

Total Spending Completion

## Goal

Finish the current recurring-cost statistics perspective so it feels coherent, complete, and ready to pause while the roadmap shifts to onboarding correctness and image work.

## Context

The app now has a second statistics perspective under `Total Spending`, but that perspective is still a recurring-cost structure view rather than literal combined total spending.

That is acceptable for now, as long as the current perspective feels intentional and polished.

The broader redesign toward true total spending should happen later, after:

- mid-period onboarding
- image/icon work

## Scope

- review the current `Total Spending` view for obvious incompleteness
- tighten wording and interpretations where needed
- improve empty-state messaging if it still feels placeholder-like
- make sure the recurring-cost modules read as one coherent fixed-cost perspective
- preserve the existing separation from the behavioral rank system

## Explicit Non-Goals

- do not redesign the overall statistics information architecture
- do not merge variable and recurring spending yet
- do not change the behavioral rank logic
- do not start onboarding redesign here
- do not introduce new complex financial models

## Success Criteria

- `Total Spending` no longer feels like a temporary shell
- the fixed-cost modules read as one intentional perspective
- empty and low-data states feel clean and understandable
- the implementation remains small and low-risk
