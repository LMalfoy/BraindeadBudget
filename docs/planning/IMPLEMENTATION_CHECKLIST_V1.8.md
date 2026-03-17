# Implementation Checklist: v1.8

## 1. Comparison Logic

- define the smallest useful month-over-month comparison
- compare current month totals against the previous month
- keep the helper small and testable

## 2. Stats Module

- add one comparison card to Stats
- present the change clearly
- include a short interpretation beneath it

## 3. Empty And Low-Data States

- handle no current-month data
- handle no previous-month data
- avoid misleading comparisons when too little history exists

## 4. Regression Safety

- preserve the category, trajectory, and temporal modules
- avoid changing app navigation or existing flows

## 5. Tests And Verification

- build successfully
- add focused unit tests for comparison logic
- run a UI test for opening Stats
- manually review whether the interpretation is clear and useful
