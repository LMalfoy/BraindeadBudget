# Iteration v3.1 Spec

## Title
Budget Period Anchor Setting

## Goal
Give users explicit control over when their budget period resets each month, without adding broader budgeting complexity.

## Scope
- add a budget period anchor setting in Settings
- let the user choose the day of month that starts their budget period
- keep the existing budget model intact as much as possible
- make the setting understandable in plain language

## Product Rules
- the budget period anchor defines the monthly reset day for the user’s budgeting cycle
- the setting must be easy to understand and easy to change
- the app should continue to support the existing onboarding anchor model
- this setting should not introduce a custom calendar system beyond a monthly anchor day

## UI Direction
- place the setting in the `Budget` section of Settings
- label it clearly, e.g. `Budget Period Starts`
- provide a simple day-of-month picker or stepper-like control
- include short helper text explaining that this controls when a new budget period begins

## Explicitly Out Of Scope
- weekly budgeting
- custom period lengths
- category customization
- further settings expansion

## Verification Targets
- settings screen shows the budget period anchor control
- chosen anchor day persists
- budget calculations use the selected anchor day
- history/stats should continue to behave predictably after anchor changes
