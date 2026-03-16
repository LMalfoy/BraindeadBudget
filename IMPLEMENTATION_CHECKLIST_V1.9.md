# Implementation Checklist: v1.9

## 1. Carryover Presentation Logic

- define the smallest useful carryover presentation model
- distinguish positive, neutral, and negative carryover clearly
- keep the helper small and testable

## 2. Stats Module

- add one carryover card to Stats
- present the carryover amount clearly
- add a short interpretation beneath it

## 3. Empty And Low-Data States

- handle no previous-month data cleanly
- avoid implying carryover history where none exists

## 4. Regression Safety

- preserve all existing Stats modules
- avoid changing app navigation or budgeting behavior

## 5. Tests And Verification

- build successfully
- add focused tests for carryover presentation logic if needed
- run a UI test for opening Stats
- manually review whether the carryover message is clear and fair
