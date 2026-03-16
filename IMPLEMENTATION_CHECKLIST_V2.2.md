# Implementation Checklist: v2.2

## 1. Perspective Navigation

- add a top switch for:
  - `Budget Spending`
  - `Total Spending`
- keep the interaction simple and visually light

## 2. Budget Spending Preservation

- render the current behavioral statistics exactly as before under `Budget Spending`
- avoid changing existing calculations or card logic

## 3. Total Spending Shell

- add a clean placeholder structure for `Total Spending`
- include a short explanatory introduction or empty-state message
- make the shell feel intentional, not like a broken screen

## 4. Regression Safety

- preserve current Stats navigation
- preserve current tests where possible
- avoid touching non-Stats flows

## 5. Tests And Verification

- add or update a UI test for switching between the two Stats perspectives
- verify the existing Stats modules still appear under `Budget Spending`
- build successfully
