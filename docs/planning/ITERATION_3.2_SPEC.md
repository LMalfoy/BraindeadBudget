# Iteration 3.2 Spec

## Title

Product Guidance And Explainers

## Goal

Improve first-time clarity and reduce user confusion by adding short, focused explanations at the highest-friction moments.

## Scope

- add a short intro screen before first onboarding/setup
- explain in a few sentences how BudgetRook works
- add an info button to the chess progression panel
- show a short explanation of how progression is earned
- add an info button in `About`
- show a short explanation of what the app does and how the three stats perspectives differ

## Out Of Scope

- onboarding redesign beyond the intro copy
- long tutorials or multi-page walkthroughs
- changes to progression math
- changes to statistics logic

## Product Rules

- all explanatory text must be short and readable on one screen
- the onboarding intro should appear only before the first setup flow
- the progression explanation should focus on saved budget, XP, and level gains
- the about explanation should describe the app at a high level, not restate every feature

## Why This Matters

- the app has grown more capable, so a small amount of explanation now has high leverage
- the chess progression is thematic, but needs a quick explanation to feel fair and understandable
- a short intro can make first-run setup feel more intentional and less abrupt

## Risk

Low

## Validation

- manual test of the first-run intro flow
- UI test for opening the progression info
- UI test for opening the about info
- verify that explanatory sheets remain short and dismiss cleanly
