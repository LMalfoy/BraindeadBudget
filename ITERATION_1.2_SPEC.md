# PocketBudget v1.2 Implementation Spec

## Iteration Goal

Use `v1.2` to introduce a slim bottom navigation bar and clarify the roles of the app’s main screens.

The purpose of this iteration is not to add more features. It is to make the existing surfaces easier to understand and move between.

## Why This Iteration Comes Next

PocketBudget now has three real product areas:

- dashboard overview
- monthly expense history
- settings

At this point, navigation should become explicit and stable before any further interaction experiments.

## Scope

In scope:

- add bottom navigation with Home, History, and Settings
- keep the navigation bar slim and unobtrusive
- keep the dashboard as a read-only overview surface
- show only a limited recent-expense preview on the dashboard
- make dashboard expense rows slightly smaller and lighter
- keep edit/delete behavior inside monthly history only

Out of scope:

- gesture-based navigation
- history month-picker modal
- history statistical digest
- chart drill-down
- major visual redesign beyond what is required for clearer structure

## Product Decisions

### Surface Roles

Each main area should have one clear role.

Decision:

- Home = overview
- History = monthly review and correction
- Settings = configuration and app info

### Dashboard Scope

The dashboard should not be a second full ledger.

Decision:

- show recent expenses only
- cap the preview to a small set, recommended: 10
- do not support edit/delete from the dashboard

### Navigation Weight

The bottom bar should support the app without dominating it.

Decision:

- keep icons and labels minimal
- keep sizing comfortable but restrained

## Acceptance Criteria

### Functional

- the user can move between Home, History, and Settings using the bottom bar
- the dashboard shows a limited recent-expense preview
- monthly history remains the place for editing and deletion

### UX

- the app feels more structured and easier to understand
- the bottom bar does not pull focus away from page content
- dashboard expense rows feel lighter than history rows

### Engineering

- the change remains compatible with existing budget, history, and settings logic
- existing tests or focused replacements still verify the main flows

## Test Plan

### Automated Checks

- build the project
- update UI tests for tab-based navigation if needed
- preserve tests for expense add/delete and settings/history access

### Manual Checks

- navigate repeatedly between all three tabs
- verify the dashboard remains read-only
- verify editing and deleting still work from monthly history
- confirm the recent-expense limit and row sizing feel appropriate

## Recommended Implementation Approach

Implement `v1.2` in this order:

1. introduce the bottom-navigation shell
2. plug the existing screens into it
3. limit and restyle the dashboard recent-expense preview
4. verify correction flows still live only in history

This keeps the iteration structural and low-risk.
