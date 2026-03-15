# PocketBudget Product Definition

## Overview

PocketBudget is a personal iOS budgeting app for people who want a quick, reliable view of how much money they still have available this month.

The core idea is simple:

- first define monthly income
- then define fixed recurring monthly commitments
- let the app calculate the true monthly spending budget automatically
- make day-to-day expense entry extremely fast

PocketBudget is not meant to be full accounting software. It is a focused personal budgeting tool for monthly awareness and fast capture.

## Product Goal

Help a single user answer two questions with minimal effort:

1. How much money is actually available to spend this month after income and recurring commitments are accounted for?
2. Where is that remaining budget going?

## Target User

The primary user is someone who:

- manages their personal finances manually
- wants a simple monthly budget, not a complex finance system
- needs a fast iPhone workflow for recording purchases
- values clarity, speed, and confidence over customization

## Core Product Principles

- Easy: the app should be understandable without explanation.
- Fast: recording an expense should take only a few seconds.
- Frictionless: common actions should require as few taps and fields as possible.
- Reliable: the monthly budget calculation must be correct and trusted.
- Focused: the app should do a small number of important things well.
- Low-risk to build: changes should be small, testable, and easy to verify.

## Budgeting Model

PocketBudget should treat budgeting as a two-layer system.

### Layer 1: Monthly Baseline

On first launch, the user should set up:

- monthly income sources
- recurring monthly expenses and commitments

Examples of recurring monthly commitments:

- rent
- electricity
- phone
- internet
- subscriptions
- insurance
- savings plans

The app should then calculate:

`monthly spending budget = total monthly income - total recurring monthly commitments`

This calculated monthly spending budget becomes the number the user tracks against during the month.

### Layer 2: Variable Daily Spending

After the baseline is set, the user logs variable expenses during the month.

Examples:

- groceries
- coffee
- restaurant
- train ticket
- hobby purchase
- pharmacy

These are subtracted from the calculated monthly spending budget to produce the remaining budget.

## Primary User Flow

### First-Time Flow

1. Open the app.
2. Enter one or more monthly income items.
3. Enter recurring monthly expenses and commitments.
4. Review the automatically calculated monthly spending budget.
5. Start logging day-to-day expenses.

### Repeat Daily Flow

1. Open the app.
2. Immediately see remaining budget, recent expenses, and a prominent add-expense action.
3. Add a new expense in a fast, minimal form.
4. Return to the dashboard with updated totals and overview.

## Home Screen Requirements

When the user opens the app, the dashboard should prioritize:

- remaining budget as the most important number
- a list of recent expenses
- an easy-to-reach add-expense button near the bottom of the screen
- a simple visual overview of spending by category

The home screen should feel like a control panel for the month, not a settings page.

The dashboard should avoid redundant branding or decorative text that does not help the user understand or act.

## Expense Entry Requirements

Expense entry is a top product priority.

The add-expense flow should be:

- obvious
- fast
- forgiving
- optimized for repeat use
- usable with one hand on a phone

The ideal default expense form should require only:

- category
- item description
- amount

Date should default to today unless changed.

Advanced or optional details should stay secondary so they do not slow down the main flow.

Secondary fields such as date and note should remain visible when they support quick entry without adding confusion. They should not be hidden behind an extra interaction unless that clearly improves speed.

The category choice should be visually immediate and easy to tap. The preferred pattern is a small set of color-coded category tiles at the top of the form.

The keyboard flow should reduce manual interaction:

- when the add-expense screen opens, the item description field should be ready for input immediately
- submitting the item description should move focus to the amount field
- the amount field should use a numeric keypad

## Categories

PocketBudget should use a small set of simple categories for variable spending.

The categories should cover the spending that remains after recurring expenses have already been handled in setup.

Approved category set for the current product direction:

- Food
- Transport
- Household
- Fun

These categories should remain intentionally broad. The goal is quick classification and clear overviews, not detailed accounting.

Category presentation should stay minimal:

- color should be used as an accent, not as a heavy visual treatment
- expense rows should make the category visible at a glance
- the UI should stay clean and lightweight rather than looking like a dense finance dashboard

## Dashboard Refinement Direction

After the budgeting baseline and fast-entry flow are established, the next priority is dashboard polish.

This means:

- stronger visual hierarchy for the remaining budget
- cleaner spacing and readability in the recent expense list
- less redundant UI chrome
- preserving fast access to the primary add-expense action

Polish should improve clarity and ease of use without adding visual complexity for its own sake.

## Smart Entry Direction

PocketBudget should eventually support a very fast single-line input option for expenses.

Examples:

- `4 marmalade`
- `marmalade 4`

The app should parse likely amount and item values intelligently where possible.

This feature is important, but correctness matters more than cleverness. It should only ship when:

- parsing rules are predictable
- user mistakes are easy to catch
- manual fallback remains simple

## Dashboard Analytics

PocketBudget should provide lightweight visual insight without becoming a heavy analytics app.

The first and most useful overview is:

- a simple chart showing spending by category for the current month

A pie chart is acceptable if it remains readable and quick to grasp. Its purpose is to help the user see where most variable spending is going and support better decisions.

## Current v0.1 Scope

PocketBudget v0.1 currently supports:

- a manually entered monthly budget value
- manual expense entry with title, amount, date, and optional note
- a list of expenses
- total spent and remaining budget for the current month
- local persistence with SwiftData

## Product Gaps Between v0.1 and Target Vision

The current app does not yet support:

- income setup
- recurring monthly commitments
- calculated monthly spending budget
- category-based expense tracking
- a category-first add-expense flow centered on fast one-handed use
- a bottom-positioned primary expense action
- chart-based spending overview on the dashboard
- smart single-line expense parsing

## Success Criteria

The product is succeeding when:

- setup produces a monthly spending budget the user trusts
- expense entry is fast enough to use in everyday situations
- the home screen answers the monthly budget question immediately
- categories help the user see where money is going without adding friction
- new development does not frequently break existing behavior

## Functional Requirements

- The app must support multiple monthly income items.
- The app must support multiple recurring monthly expense items.
- The app must calculate a monthly spending budget from those baseline values.
- The app must subtract variable expenses from that calculated monthly spending budget.
- The app must support a small fixed set of simple expense categories.
- The app must show recent expenses on the main screen.
- The app must show a category-based spending overview on the main screen.
- The app must validate invalid input such as empty descriptions or non-positive amounts.

## Non-Functional Requirements

- The main flows should use standard iOS interactions and stay easy to maintain.
- The app should remain local-first and simple in its data model.
- Features should be deliverable in small slices with focused tests.
- Risky or ambiguous UX ideas should be introduced behind simple fallbacks.

## Non-Goals

PocketBudget is not currently trying to be:

- a bank sync app
- a bookkeeping system
- a multi-user budgeting platform
- a deep financial analytics suite
- a tax, debt, or investment planner

## Decision Filter For Future Work

Before building a feature, ask:

1. Does it improve the correctness of the monthly budget calculation?
2. Does it make expense entry easier or faster?
3. Does it improve visibility into remaining budget or category spending?
4. Can it be shipped as a small, low-risk change?
5. Can it be validated with focused tests and a short manual check?

If the answer to most of these is no, defer it.
