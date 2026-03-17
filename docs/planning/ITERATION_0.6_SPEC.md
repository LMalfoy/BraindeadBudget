# PocketBudget v0.6 Implementation Spec

## Iteration Goal

Allow the user to correct obviously wrong expense entries safely and simply.

This iteration should focus on deletion first. Editing can be deferred unless it fits naturally without increasing risk.

## Why This Iteration Comes Next

PocketBudget now supports:

- monthly budget setup
- fast expense entry
- category overview

That makes data quality more important. A budgeting app becomes less trustworthy if incorrect entries cannot be fixed.

## Scope

In scope:

- delete an expense from the dashboard list
- ensure totals and category overview update immediately after deletion
- add tests for delete and recalculation behavior
- add or update a UI test for the delete flow

Optional only if still low-risk:

- show a lightweight expense detail surface that supports deletion

Out of scope:

- broad edit flows
- multi-step expense management UI
- undo history
- batch actions
- archive/trash concepts

## Product Decisions

### Primary Correction Action

The first correction feature should be:

- delete an expense

Reason:

- highest value for lowest complexity
- directly solves the trust problem for accidental or duplicate entries

### Edit Support

Editing should be deferred unless it remains very small and clearly safer than leaving it for a later iteration.

Default decision for `v0.6`:

- do not require edit support

### UI Entry Point

Preferred direction:

- use a standard, native interaction such as swipe-to-delete or context-appropriate row actions

If a detail sheet is introduced, it should remain minimal and exist only to support safe deletion or better visibility of row details.

### Safety

Deletion should not feel hidden or overly dangerous.

Depending on the final interaction:

- either rely on a clear native deletion pattern
- or show a confirmation step if accidental taps are too likely

## Screen Changes

### 1. Dashboard Expense List

Required changes:

- expose a delete path for each expense
- ensure row deletion updates the list immediately
- ensure budget summary and category overview react immediately

### 2. Optional Expense Detail Surface

Only if needed:

- show the full title and important details for an expense
- provide a clear delete action

This should remain local and small if implemented.

## Data And Logic Changes

Add a small delete helper for expenses.

Recommended responsibilities:

- remove an expense from persistence
- keep recalculation behavior unchanged apart from the removed data

The existing calculation model should not need architectural change for this.

## Acceptance Criteria

### Functional

- a user can delete an expense
- deleted expenses disappear from the dashboard immediately
- remaining budget updates correctly after deletion
- category overview updates correctly after deletion

### UX

- the delete path is easy to discover
- the interaction does not feel risky or confusing
- the app still feels lightweight after the change

### Engineering

- delete behavior is covered by focused tests
- no unnecessary persistence redesign is introduced
- working flows remain intact

## Test Plan

### Unit Tests

Add tests for:

- deleting an expense from storage
- recalculating totals after deletion
- updating category aggregation after deletion

### UI Tests

Add or update tests for:

- deleting an expense from the dashboard
- verifying the deleted item no longer appears

### Manual Checks

- delete the only expense in the current month
- delete one expense out of several
- verify the category overview changes accordingly
- verify the remaining budget changes accordingly
- verify the delete interaction feels native and clear

## Recommended Implementation Approach

Implement `v0.6` in this order:

1. add delete support in the store
2. add unit tests for deletion and recalculation
3. expose the delete interaction in the dashboard list
4. update UI tests
5. run build and manual verification

This keeps the iteration focused on trust and correction rather than expanding the app surface.
