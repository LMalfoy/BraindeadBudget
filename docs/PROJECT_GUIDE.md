# BudgetRook Project Guide

## Purpose Of This Document

This guide explains how BudgetRook works in plain language.

It is written for people with basic programming knowledge who want to understand:

- what the app does
- how the source files are organized
- how data is stored
- how the budget is calculated
- how the statistics are built
- where to look when changing a feature

This is not a marketing document. It is a practical reading guide for the codebase.

## What The App Does

BudgetRook is a personal budgeting app for one person on one device.

The app helps answer one main question:

`How much money is still available to spend in the current budget period?`

To do that, the app separates money into two kinds of spending:

1. recurring monthly commitments
2. variable day-to-day expenses

Examples:

- recurring commitments:
  - rent
  - subscriptions
  - insurance
  - savings plan

- variable expenses:
  - groceries
  - train ticket
  - coffee
  - restaurant

The app then combines those records into:

- a monthly spending baseline
- a remaining budget
- history and statistics
- a savings-based chess progression

## High-Level App Flow

### 1. First launch

The user sees a short intro and then completes budget setup.

During setup the user enters:

- monthly income items
- recurring monthly costs
- the amount of variable budget still available right now

That last value is important.
The app assumes most users join in the middle of an already active period.
So it stores a real starting anchor instead of inventing fake past expenses.

### 2. Normal daily use

After setup the user mostly interacts with four tabs:

- `Home`
- `History`
- `Stats`
- `Settings`

### 3. Main daily habit

The most common action is:

1. open the app
2. check remaining budget
3. add an expense
4. return to the dashboard

## Project Structure

The important folders are:

- `PocketBudget/App`
- `PocketBudget/Models`
- `PocketBudget/Data`
- `PocketBudget/Features`
- `PocketBudgetTests`
- `PocketBudgetUITests`
- `PocketBudget/Resources/Assets.xcassets`

### `App`

This folder contains app startup and the top-level tab structure.

- `PocketBudgetApp.swift`
  - true entry point of the app
  - creates the SwiftData model container
  - applies light/dark/system appearance

- `ContentView.swift`
  - top-level tab bar
  - wires together Home, History, Stats, and Settings

### `Models`

This folder contains the persistent SwiftData model types.

- `BudgetSettings.swift`
  - app-wide budgeting settings
  - stores currency, budget period anchor day, and the initial budget anchor

- `Expense.swift`
  - normal variable spending records

- `IncomeItem.swift`
  - one monthly income source

- `RecurringExpenseItem.swift`
  - one repeating monthly cost with a fixed category

These files define what is saved to the local database.

### `Data`

- `BudgetStore.swift`

This file is the heart of the app.

It contains:

- persistence operations
- validation
- budget calculations
- history calculations
- chart data preparation
- progression calculations

If you understand `BudgetStore.swift`, you understand most of the app's logic.

### `Features`

This folder contains user-facing screens and feature-specific UI.

- `DashboardView.swift`
  - current budget summary
  - category overview
  - recent expenses
  - first-run onboarding entry point

- `AddExpenseSheet.swift`
  - fast expense entry form

- `BudgetSettingsSheet.swift`
  - onboarding and later budget management

- `SettingsSheet.swift`
  - app-level controls

- `ExpenseHistorySheet.swift`
  - month-based browsing and correction of expenses

- `StatsView.swift`
  - all statistics and progression screens

### `Tests`

- `PocketBudgetTests`
  - unit tests for math and persistence

- `PocketBudgetUITests`
  - UI tests for major user flows

## How Data Is Stored

The app uses `SwiftData`.

The model container is created in:

- `PocketBudget/App/PocketBudgetApp.swift`

The container registers these persistent model types:

- `BudgetSettings`
- `Expense`
- `IncomeItem`
- `RecurringExpenseItem`

### Important storage facts

- data is stored locally on the device
- there is no cloud sync in the current app
- there is no server
- there is no remote database

During UI tests, the app uses an in-memory SwiftData configuration instead of a real persistent store. That keeps tests isolated and repeatable.

## Budget Model

The app's budget model has three important concepts.

### 1. Monthly baseline

The monthly baseline is:

`total income - total recurring costs`

This is the "normal" spending budget before carryover or onboarding anchors are applied.

### 2. Initial available-budget anchor

On first setup the user enters:

`how much variable budget is still available right now`

This is stored in `BudgetSettings`.

The app uses it because:

- users often start mid-period
- we do not want to create a fake "spent so far" expense
- fake backfilled expenses would pollute statistics

### 3. Budget period anchor day

The budget period does not always have to start on day 1 of a month.

The user can choose a custom start day in Settings, for example:

- day 1
- day 15
- day 28

This affects:

- which expenses belong to the current period
- carryover calculation
- history grouping
- statistics
- progression

## Main Calculations

Most calculations live in `BudgetStore.swift`.

### Available monthly budget

`availableMonthlyBudget(...)`

This subtracts recurring monthly costs from total income.

### Previous period carryover

`previousMonthCarryover(...)`

This calculates how much money is carried from the previous budget period.

If the previous period was the initial onboarding period, carryover starts from the user-entered initial available budget instead of the normal monthly baseline.

### Adjusted monthly budget

`adjustedMonthlyBudget(...)`

This is the actual budget available for the active period.

Normally:

`monthly baseline + previous carryover`

But in the initial anchored period:

`initial available budget`

### Remaining budget

`remainingBudget(...)`

This subtracts current-period expenses from the adjusted monthly budget.

## Statistics Model

The app has three statistics perspectives.

### 1. Total Spending

Purpose:

- broad overview
- variable and recurring spending combined

Examples:

- combined spending chart
- total monthly outflow
- top combined spending area

### 2. Budget Spending

Purpose:

- understand day-to-day spending behavior

Examples:

- spending by category
- budget trajectory
- month comparison
- carryover
- spending pattern

### 3. Recurring Spending

Purpose:

- understand monthly financial structure

Examples:

- fixed cost distribution
- fixed cost ratio
- subscription load
- savings stability

The UI for these lives in `StatsView.swift`, but the computed values come from `BudgetStore.swift`.

## Chess Progression

The progression system is not based on spending style.
It is based on budget outcome.

That means:

- spending early is not automatically bad
- one big category is not automatically bad
- what matters is how much budget remains at the end of completed periods

### How progression works

For completed budget periods, the app calculates a saved percentage.

That saved percentage is converted into XP.

XP then advances the user through chess-themed levels:

- Pawn
- Knight
- Bishop
- Rook
- Queen
- King

The progression logic is implemented in `BudgetStore.evaluateBudgetProgression(...)`.

The presentation is handled in `StatsView.swift`.

## Settings

The settings screen is intentionally small and practical.

It contains:

- budget management
- currency
- budget period start day
- light / dark / system appearance
- erase all data
- about information

Most settings changes write through `BudgetStore`.

## First Files To Read

If you are new to the project, read in this order:

1. `PocketBudget/App/PocketBudgetApp.swift`
2. `PocketBudget/App/ContentView.swift`
3. `PocketBudget/Features/DashboardView.swift`
4. `PocketBudget/Features/BudgetSettingsSheet.swift`
5. `PocketBudget/Data/BudgetStore.swift`
6. `PocketBudget/Features/StatsView.swift`
7. `PocketBudget/Features/ExpenseHistorySheet.swift`
8. `PocketBudget/Features/SettingsSheet.swift`

That path gives a good overview from app launch, to onboarding, to logic, to statistics, to supporting screens.

## Where To Change Common Things

### Add a new field to stored settings

Look at:

- `PocketBudget/Models/BudgetSettings.swift`
- `PocketBudget/Data/BudgetStore.swift`
- any screens that read `budgets.first`

### Change how budgets are calculated

Look at:

- `PocketBudget/Data/BudgetStore.swift`

### Change expense-entry UX

Look at:

- `PocketBudget/Features/AddExpenseSheet.swift`
- `PocketBudget/Features/DashboardView.swift`

### Change onboarding

Look at:

- `PocketBudget/Features/DashboardView.swift`
- `PocketBudget/Features/BudgetSettingsSheet.swift`

### Change stats or charts

Look at:

- `PocketBudget/Features/StatsView.swift`
- `PocketBudget/Data/BudgetStore.swift`

### Change settings behavior

Look at:

- `PocketBudget/Features/SettingsSheet.swift`
- `PocketBudget/Data/BudgetStore.swift`

## Test Strategy

The codebase uses two kinds of tests.

### Unit tests

Files:

- `PocketBudgetTests/BudgetCalculationTests.swift`
- `PocketBudgetTests/BudgetStoreTests.swift`

Purpose:

- verify calculations
- verify persistence logic
- catch regressions in budget behavior

### UI tests

File:

- `PocketBudgetUITests/PocketBudgetUITests.swift`

Purpose:

- check the most important real user flows
- onboarding
- add expense
- settings
- stats navigation

## Practical Advice For Future Maintainers

- keep business logic in `BudgetStore` instead of scattering it through views
- keep views focused on presentation and local form state
- add comments only where the logic is genuinely non-obvious
- prefer small, testable iterations over large rewrites
- be careful when changing SwiftData models, because schema changes can affect existing local installs

## Summary

BudgetRook is a local-first budgeting app with:

- SwiftUI for UI
- SwiftData for persistence
- `BudgetStore` as the central logic layer
- a clean split between variable spending, recurring spending, and total spending
- a savings-based progression system layered on top of stable budget calculations

If you keep those ideas in mind, the codebase becomes much easier to navigate.
