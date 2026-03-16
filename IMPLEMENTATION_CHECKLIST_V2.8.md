# Implementation Checklist v2.8

## Objective

Restructure Statistics around a default total-spending overview with separate budget and recurring sub-pages.

## Checklist

- define the new perspective labels and order
- make `Total Spending` the default perspective
- rename the current recurring-cost perspective to `Recurring Spending`
- preserve the current behavioral modules under `Budget Spending`
- create the first lightweight true total-spending overview
- keep the overview visually primary and simple
- position the current progression card lower in the page until the new progression system replaces it
- verify the revised navigation and visible sections in focused UI tests

## Definition Of Done

- the Stats landing page shows the broad total-spending overview first
- `Budget Spending` and `Recurring Spending` are clearly subordinate perspectives
- the current structure no longer confuses recurring spending with literal total spending
