# Implementation Checklist v2.0.6

## Pre-Coding

- confirm exact dashboard placement for the streak indicator
- decide whether zero streak is hidden or shown neutrally
- confirm reuse of existing safe-spend streak logic
- identify the cleanest dashboard data path for exposing the streak

## Coding

- add streak value to the dashboard data flow
- add a compact blue flame indicator to the dashboard overview card
- add the circular count badge anchored to the flame icon
- keep spacing and layering clean in both appearances
- avoid introducing duplicate streak calculations

## Testing

- add or refine streak-related calculation tests if needed
- build the project successfully
- manually verify dashboard layout and readability

## Done Criteria

- streak indicator appears in the dashboard overview card
- indicator reads clearly and stays visually secondary
- no dashboard behavior regresses
- build is green
