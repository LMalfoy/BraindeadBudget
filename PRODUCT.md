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

## Future Period Handling

The current product centers on monthly budgeting.

The next major budgeting rule should be monthly carryover.

That means the app should eventually treat each new month as inheriting the prior month’s leftover balance, whether that balance is positive or negative.

The rule should be:

`available budget for month N = baseline monthly budget + carryover from month N-1`

Where carryover can be:

- positive if the user underspent in the prior month
- negative if the user overspent in the prior month

This shifts PocketBudget from a hard-reset monthly tracker toward a rolling monthly budget with continuity between periods.

That change should be introduced deliberately, because it affects the meaning of the dashboard’s main budget number.

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
- once a valid numeric amount has been entered, pressing Return or Send should submit the expense directly

## Statistics Perspective Direction

PocketBudget now has two statistics directions with different purposes.

### Budget Spending

This is the behavioral budgeting view.

It focuses on:

- variable day-to-day spending
- category distribution
- budget pace
- temporal pattern
- month comparison
- carryover
- discipline rank

### Total Spending

The current `Total Spending` perspective is a structural recurring-cost view.

It helps the user understand:

- how much monthly income is already committed
- how recurring costs are distributed
- how large the subscription stack is
- whether savings are stable

This view should remain simple and explainable.

Important:

- it should not interfere with the behavioral rank system
- it does not yet represent literal combined total spending
- a later redesign may merge variable and recurring spending into a true all-in spending perspective

## Expense History Requirements

The app should provide a dedicated monthly history view that supports review and correction without crowding the dashboard.

That history view should:

- show all expenses for a selected month
- allow fast navigation between adjacent months
- support direct month/year selection from the month header
- allow editing and deleting expenses there
- include a compact monthly digest

The monthly digest should help the user understand the selected period at a glance, including:

- total spent for the month
- carryover affecting that month
- category spending totals

The dashboard should remain a lightweight overview. The full inspection and correction workflow belongs in monthly history.

The history editing flow should feel consistent with the main add-expense flow.

That means:

- editing should ideally reuse the same visual language as expense entry
- category selection should stay immediate and color-coded
- month selection should feel lightweight and proportional to the task

History should feel like a refined operational screen, not a stack of disconnected subflows.

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

## Statistics Area Direction

The Statistics area is the app's second major product pillar.

Its purpose is not decorative analytics. It should function as a behavioral feedback system that helps the user:

- understand spending habits
- notice unhealthy patterns early
- recognize positive carryover and rollover outcomes
- regulate spending more intentionally over time

Each statistics module should follow these rules:

- keep the visual presentation easy to understand
- include a short plain-language interpretation
- prefer behavioral usefulness over analytical density
- build iteratively on top of the existing budget model

The Statistics area should eventually support two perspectives:

- `Budget Spending`
- `Total Spending`

### Budget Spending

This is the current behavioral view.

It should focus on:

- variable spending behavior
- category usage
- pacing through the month
- carryover and rollover outcomes
- comparisons across recent months
- the qualitative discipline rank

### Total Spending

This should be added as a separate statistics perspective rather than mixed into the behavioral view.

Its purpose is to help the user understand fixed financial structure and monthly constraints, including recurring commitments such as:

- rent
- utilities
- subscriptions
- insurance
- savings contributions
- debt payments

This perspective should not interfere with the behavioral rank system.

Instead, it should answer structural questions such as:

- how much of the month is already committed before day-to-day spending begins
- how large the subscription stack is
- which fixed-cost categories dominate the monthly financial structure
- whether savings are consistently present in the monthly baseline

To keep this understandable, recurring-cost categories should remain intentionally broad:

- Housing / Utilities
- Subscriptions
- Insurance
- Savings
- Debt

The Total Spending perspective should be built in small steps, just like the original Statistics rollout.

Recurring-cost entry should eventually match the quality of the main expense-entry flow.

That means recurring-cost setup should become:

- visually immediate
- category-first
- fast to complete
- consistent with the app's existing expense-entry language

The recurring-cost editor should mirror the add-expense flow as closely as practical, with one intentional difference:

- recurring costs use 5 categories in one row instead of 4

Those categories should remain:

- Housing / Utilities
- Subscriptions
- Insurance
- Savings
- Debt

The category controls should feel like the expense category tiles:

- color-coded
- clearly selected when active
- obvious at a glance

The recurring-cost editor should aim for the same frictionless feel as expense entry rather than reading like a generic form.

The final capstone of the Statistics area should be a qualitative discipline rank.

That rank should:

- be rule-based and deterministic
- avoid false precision and avoid numeric scores
- summarize budgeting discipline in a motivating but fair way
- explain itself transparently through visible reasons

The rank hierarchy should be chess-inspired:

- Pawn
- Knight
- Bishop
- Rook
- Queen
- King

The rank should be driven primarily by behavioral signals:

- budget trajectory
- category distribution
- temporal spending pattern
- month-over-month comparison

And it should be stabilized or adjusted by outcome signals:

- monthly carryover
- leftover budget percentage for the month

After the first complete Statistics arc is in place, the next refinement step should deepen the existing modules rather than add new ones immediately.

Two especially valuable refinements are:

- increasing temporal-pattern sampling so the app can detect more precise within-month spending concentration
- expanding month comparison from a two-month snapshot into a short rolling view across multiple months

These refinements should improve behavioral usefulness without turning the Statistics area into a dense analytics dashboard.

This means:

- stronger visual hierarchy for the remaining budget
- cleaner spacing and readability in the recent expense list
- less redundant UI chrome
- preserving fast access to the primary add-expense action

Polish should improve clarity and ease of use without adding visual complexity for its own sake.

## Product Maturity Direction

After the core budgeting and expense-tracking flows are in place, near-term work should prioritize polish, stability, and trust over adding clever input shortcuts.

That means:

- improving the feel of the existing flows on a real device
- smoothing small dashboard and expense-entry friction points
- reducing visual rough edges
- increasing confidence before broader feature expansion

Smart input ideas such as single-line parsing may still be considered later, but they are not a near-term priority unless real usage clearly demands them.

## Statistics Direction

The second major product pillar of PocketBudget should be a dedicated Statistics area.

This area should not exist as decorative analytics. It should function as a behavioral feedback system that helps the user:

- understand spending behavior
- detect patterns early
- regulate spending more intentionally
- compare current behavior against recent periods

The Statistics area should follow these principles:

- prioritize behavioral usefulness over analytical complexity
- keep charts and insights easy to understand
- require a short plain-language interpretation for every module
- build iteratively in small, low-risk steps
- reuse the existing data model whenever possible

The long-term Statistics modules are:

- Budget Trajectory / Remaining Budget Trend
- Spending by Category
- Spending by Day / Temporal Pattern
- Month-over-Month Comparison
- Carryover Insight
- Budget Discipline Score

The Budget Discipline Score should be a lightweight gamified summary rather than a heavy scoring system.

Carryover Insight should be treated as one of the important inputs into the later Budget Discipline Score.

Positive carryover should be read as evidence of restraint or healthy budgeting continuity.
Negative carryover should be read as a warning signal that the next month is starting under pressure.

The Statistics area should also preserve the same visual discipline as the rest of the app:

- the first module should sit close to the screen title without unnecessary top whitespace
- charts should feel integrated into the screen, not detached from it
- interpretations should stay short and behavior-oriented

The temporal-pattern module should help the user answer:

- when during the month does most spending happen?

The preferred first version is not a complex calendar heatmap. It should be a simple behavioral grouping that is easy to interpret quickly, such as:

- early month
- mid month
- late month

The month-over-month module should help the user answer:

- am I doing better or worse than last month?
- which direction is my spending moving?

This module should stay comparative and simple. It should not become a dense historical analytics surface.

The carryover module should help the user answer:

- did I carry money forward from the previous month?
- am I starting this month with an advantage or a handicap?

This module should be explicit and easy to read, because carryover already affects the real budget model.

The intended thematic progression is:

- Pawn
- Knight
- Bishop
- Queen
- King

That chess-role layer should only be introduced after the underlying statistics modules are already meaningful enough to support a score.

## Stabilization Direction

Before expanding the app with larger new surfaces such as settings or expense history, the product should go through an explicit stabilization pass.

This means:

- fixing small bugs that affect trust or predictability
- tightening rough edges in existing flows
- improving the reliability of validation and test coverage
- avoiding broad code movement unless it clearly reduces risk

Stabilization work should make the current product safer to extend, not just “cleaner” in the abstract.

## Settings Direction

After stabilization, PocketBudget should introduce a dedicated settings area.

The purpose of settings is to:

- move budget editing out of the dashboard’s permanent chrome
- keep app-level actions in one predictable place
- create a clean home for app metadata and later customization

The first version of settings should stay intentionally small and should include:

- access to budget management
- app version information
- author information

If no baseline budget information exists, the budget setup flow should still open automatically without requiring the user to find settings first.

For the current product direction, the author information can explicitly credit:

- Dr. Kevin Sicking
- Codex (GPT-5)

## Expense History Direction

After carryover budgeting, the next major feature surface should be a dedicated monthly expense-history view.

That future area should:

- show all expenses for a selected month
- support easy month and year switching
- allow editing and deleting entries
- feel like a deeper layer beyond the lightweight dashboard preview

The dashboard’s recent-expense area can later serve as the natural entry point into that broader monthly expense view.

## App Navigation Direction

After monthly expense history exists, the app should move toward a clearer multi-surface structure.

The preferred direction is a slim bottom navigation bar with three destinations:

- Home
- History
- Settings

This should help separate the product into three clear layers:

- dashboard for quick monthly overview
- monthly history for full review and correction
- settings for budget management and app information

The bottom bar should:

- be large enough to use comfortably
- stay visually quiet
- avoid stealing focus from the actual page content

Gesture-based navigation can still be explored later, but only after the bottom-navigation structure proves stable.

## Dashboard List Direction

The dashboard should stay an overview, not a working database screen.

That means:

- keep a recent-expense preview on the dashboard
- limit that preview to a small recent set, such as the 10 latest expenses
- keep those rows read-only on the dashboard
- make the dashboard rows slightly smaller and lighter than the monthly history rows

Editing and deletion should belong to the monthly history view, not to the dashboard overview.

## Dashboard Analytics

PocketBudget should provide lightweight visual insight without becoming a heavy analytics app.

The first and most useful overview is:

- a simple chart showing spending by category for the current month

A pie chart is acceptable if it remains readable and quick to grasp. Its purpose is to help the user see where most variable spending is going and support better decisions.

The chart should stay lightweight:

- current month only
- fixed categories only
- easy to read at a glance
- no dense controls or advanced analytics framing

The dashboard should ideally surface a short insight alongside the chart, such as the largest spending category for the current month.

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
- mistakes in recorded expenses can be corrected without confusion
- new development does not frequently break existing behavior

## Functional Requirements

- The app must support multiple monthly income items.
- The app must support multiple recurring monthly expense items.
- The app must calculate a monthly spending budget from those baseline values.
- The app must subtract variable expenses from that calculated monthly spending budget.
- The app must support a small fixed set of simple expense categories.
- The app must show recent expenses on the main screen.
- The app must show a category-based spending overview on the main screen.
- The app must allow the user to remove obviously incorrect recorded expenses.
- The app must validate invalid input such as empty descriptions or non-positive amounts.

## Data Trust Direction

Fast entry increases the chance of small mistakes.

Because of that, the app must eventually support lightweight correction flows for recorded expenses:

- deletion of clearly wrong entries
- simple editing if it can be added without complexity

Correction should be safe and understandable. The app should not make destructive actions feel accidental or hidden.

## Future Expansion Direction

Once the app is polished and stable, the next meaningful expansion areas are:

- browsing expenses by month
- drilling into a category to see its underlying expenses
- period-aware budgeting rules such as monthly carryover

These should come after stabilization, not before.

## Non-Functional Requirements

- The main flows should use standard iOS interactions and stay easy to maintain.
- The app should remain local-first and simple in its data model.
- Features should be deliverable in small slices with focused tests.
- Risky or ambiguous UX ideas should be introduced behind simple fallbacks.
- The project should maintain a dependable verification path so future changes can be checked with reasonable confidence.

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
