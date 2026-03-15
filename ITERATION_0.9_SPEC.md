# PocketBudget v0.9 Implementation Spec

## Iteration Goal

Use `v0.9` to introduce a dedicated settings surface without changing the core budgeting behavior.

The purpose of this iteration is to make the dashboard cleaner and establish a stable home for budget management and basic app information.

## Why This Iteration Comes Next

PocketBudget now has a stable core loop:

- setup
- expense entry
- dashboard review
- category overview
- deletion/correction basics

The next logical step is not more dashboard complexity. It is separating app-level controls from the monthly control surface.

## Scope

In scope:

- add a settings entry point from the dashboard
- add a dedicated settings screen or sheet
- move budget-management access into that settings area
- include basic app metadata such as version and author credits
- keep onboarding behavior unchanged when no baseline budget exists

Out of scope:

- deeper customization
- expense history
- category drill-down
- new budgeting rules
- visual redesign beyond what is required for the new settings surface

## Product Decisions

### Settings Purpose

The settings area should be small and obvious.

Decision:

- settings are for app-level actions and information
- the main dashboard remains focused on monthly budgeting and expense tracking

### Budget Setup Access

Budget setup should still be impossible to miss on first launch.

Decision:

- keep the existing automatic onboarding/full-screen setup behavior when no baseline exists
- after setup, budget editing should live inside settings rather than as a persistent dashboard control

### App Information

The first version of settings should include lightweight app information.

Decision:

- show app version
- show author credits
- list both:
  - Dr. Kevin Sicking
  - Codex (GPT-5)

## Acceptance Criteria

### Functional

- a user can open settings from the main dashboard
- a user can reach budget management from settings
- first-run onboarding still appears automatically when baseline data is missing

### UX

- the dashboard no longer needs to expose budget editing as a constant top-left action
- settings feel separate from the monthly workflow
- app information is easy to find but does not dominate the screen

### Engineering

- existing setup, expense, dashboard, and deletion flows still behave the same
- changes remain local and low-risk

## Test Plan

### Automated Checks

- build the project
- run unit tests
- run targeted UI tests for:
  - first-run onboarding
  - opening settings
  - reaching budget management from settings

### Manual Checks

- launch with no baseline data and verify onboarding still opens
- complete setup, then re-open budget management through settings
- confirm version and author information are visible in settings

## Recommended Implementation Approach

Implement `v0.9` in this order:

1. add the settings entry point
2. introduce the settings surface
3. move budget-management access there
4. add app metadata
5. verify onboarding still bypasses settings when the app has no baseline data

This keeps the iteration disciplined and avoids turning settings into a broad feature branch.
