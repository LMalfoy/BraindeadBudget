# Implementation Checklist: v2.0

## 1. Rank Evaluation Layer

- define a `BudgetDisciplineRank` type
- define readable signal/result types
- evaluate behavioral base signals as `strong`, `neutral`, or `weak`
- resolve a base rank from those signals
- apply carryover and leftover-budget modifiers in a small, explicit way

## 2. Sparse-Data Safety

- define a conservative fallback when data is too thin
- avoid extreme ranks when history is incomplete
- make sparse-data explanations visible in the UI

## 3. Explanation Layer

- produce a short summary sentence
- produce a short list of human-readable reasons
- ensure the reasons clearly match the resulting rank

## 4. Stats UI

- add a rank card to the Stats screen
- show rank title, summary, and reasons
- keep the visual treatment aligned with the existing Stats cards
- do not add chess image assets yet unless they are already ready and licensed

## 5. Regression Safety

- preserve all existing Stats modules
- avoid changing navigation or budgeting behavior
- keep the implementation local to the Statistics area and evaluation helpers

## 6. Tests And Verification

- add focused unit tests for rank resolution
- add focused unit tests for sparse-data behavior
- add a UI test that verifies the rank module appears in Stats
- manually review whether several realistic scenarios produce fair, understandable ranks
