# Iteration 2.4 Spec

## Title

Total Spending Expansion And Setup UX Polish

## Goal

Extend the `Total Spending` perspective with two practical recurring-cost insight modules while improving the recurring-cost setup experience.

## User Outcome

The user should be able to:

- understand how heavy the current subscription stack is
- see whether savings are consistently part of the monthly structure
- categorize recurring costs more quickly during setup
- edit income and recurring-cost rows with clearer tap affordance

## Scope

### 1. Subscription Load

Add a module that shows:

- count of recurring subscription items
- total monthly subscription cost

The interpretation should stay plain-language, for example:

- `Your subscription stack is currently quite large.`
- `Subscriptions are a small part of your fixed costs.`

### 2. Savings Stability

Add a module that shows:

- total recurring savings amount
- savings as a share of monthly income when income exists

The interpretation should stay calm and clear, for example:

- `You consistently invest part of your income.`
- `Savings are not yet a meaningful part of your monthly structure.`

### 3. Recurring-Cost Setup UX

Improve the recurring-cost editor flow by:

- using five color-coded category tiles instead of a generic picker
- making the recurring-cost category selection feel as immediate as expense entry
- making budget-setup rows feel obviously tappable across the full row width

## Product Rules

- preserve the separation between `Budget Spending` and `Total Spending`
- do not feed these fixed-cost modules into the discipline rank
- keep recurring-cost categories limited to the existing five broad categories
- keep the setup changes visual and local rather than architectural

## Out Of Scope

- fixed-cost trend history
- new recurring-cost categories
- settings redesign
- broader onboarding overhaul
