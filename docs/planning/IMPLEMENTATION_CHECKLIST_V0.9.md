# PocketBudget v0.9 Implementation Checklist

This is the final pre-coding checklist for `v0.9: Settings Area`.

The goal is to separate app-level controls from the dashboard without changing the core product loop.

## Execution Order

### 1. Add a Settings Entry Point

- choose a small, clear dashboard entry point for settings
- remove or replace the always-visible budget button as part of this change

Definition of done:

- the user has one clear path into settings

### 2. Introduce the Settings Surface

- add a dedicated settings screen or sheet
- keep the initial layout intentionally small

Definition of done:

- settings exist as a distinct app-level area

### 3. Move Budget Management Into Settings

- expose budget editing from settings
- keep first-run onboarding unchanged when no budget exists

Definition of done:

- users update budget data through settings after initial setup

### 4. Add Basic App Information

- show app version
- show author credits for Dr. Kevin Sicking and Codex (GPT-5)

Definition of done:

- settings include lightweight app metadata

### 5. Verify Core Behavior

- first-run setup still opens automatically
- expense entry still works
- dashboard remains focused on current-month information

Definition of done:

- adding settings does not disturb the main workflow

### 6. Final Verification

- build the project
- run unit tests
- run targeted UI tests around settings and setup access

Definition of done:

- `v0.9` cleanly introduces settings without regressions

## Guardrails

Do not include in `v0.9`:

- history view implementation
- category drill-down
- new budget rules
- broad dashboard redesign
- deep customization menus

This iteration is for a small settings surface only.

## Exit Criteria For v0.9

`v0.9` is complete when:

- settings exist and feel separate from the dashboard
- budget management is reachable there
- onboarding still works without friction
- app info is visible in one predictable place
