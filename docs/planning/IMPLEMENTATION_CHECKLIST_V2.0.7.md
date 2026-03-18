# Implementation Checklist v2.0.7

## Pre-Coding

- confirm placement inside the existing recurring stats section
- confirm whether the list should scroll or cap visible height
- confirm empty-state behavior for no subscriptions

## Coding

- expose a filtered subscription item list from the existing recurring data
- add the compact subscription list UI under `Subscription Load`
- keep layout readable and visually subordinate to the main metric
- avoid changing recurring-cost editing flows

## Testing

- add or refine tests for subscription filtering if needed
- ensure total subscription cost remains correct
- build the project successfully

## Done Criteria

- users can see individual subscriptions directly in stats
- list stays compact and readable
- existing subscription load summary still works
- build is green
