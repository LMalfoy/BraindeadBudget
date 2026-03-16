# Implementation Checklist: v1.6

## 1. Stats Layout Polish

- remove the extra top spacing on the Stats screen
- keep the first card visually aligned with the rest of the app

## 2. Trajectory Module

- define the smallest useful trajectory view for the current month
- prefer a simple line or progress-style chart
- derive the interpretation from real current-month pacing

## 3. Empty And Low-Data States

- handle no-expense and sparse-data states cleanly
- avoid showing a misleading trend when there is too little data

## 4. Regression Safety

- preserve the existing category module
- avoid changing dashboard, history, or settings behavior

## 5. Tests And Verification

- build successfully
- add focused tests for any extracted trajectory calculations
- run a UI test for opening Stats
- manually review the spacing and interpretation quality
