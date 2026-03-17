# PocketBudget v0.4 Implementation Checklist

This is the final pre-coding checklist for `v0.4: Dashboard Priority Layout`.

The goal is to improve clarity, polish, and day-to-day usability without expanding the feature surface.

## Execution Order

### 1. Refine Dashboard Header And Summary

- remove redundant `PocketBudget` dashboard headline or title treatment
- make remaining budget the strongest visual element
- keep available budget and spent this month readable but secondary

Definition of done:

- the dashboard immediately communicates what matters most

### 2. Keep Add-Expense Action Strong But Clean

- preserve the bottom add-expense action
- tune spacing, padding, and placement if needed
- ensure it does not crowd the expense list

Definition of done:

- the primary action remains obvious and thumb-friendly

### 3. Bring Back Visible Date And Note Fields

- remove the disclosure pattern in the add-expense sheet
- show date and note directly in the form
- keep category, item, and amount visually dominant

Definition of done:

- the form exposes secondary fields without feeling slower

### 4. Tune Expense List Readability

- refine row spacing
- keep category cues visible but minimal
- improve scanning across several recent expenses

Definition of done:

- the list looks cleaner and is easier to parse quickly

### 5. Tighten Empty States And Copy

- improve dashboard empty-state wording if needed
- remove any copy that feels redundant or noisy

Definition of done:

- the app feels more polished in both filled and empty states

### 6. Update Tests If UI Identifiers Or Flow Change

- keep the main add-expense UI test passing
- add assertions only where the new UI behavior is materially different

Definition of done:

- the polished flow is still regression-protected

### 7. Final Verification

- build the project
- run tests
- do a manual simulator pass focused on dashboard feel and expense-entry polish

Definition of done:

- `v0.4` feels cleaner and more intentional than `v0.3`

## Guardrails

Do not include in `v0.4`:

- charts or pie views
- smart parsing
- expense edit/delete
- category analytics
- broad theming or stylistic experimentation

This iteration is about polish and hierarchy, not feature expansion.

## Exit Criteria For v0.4

`v0.4` is complete when:

- the dashboard hierarchy is clearer
- the main add-expense action remains easy to reach
- date and note are directly visible in the add-expense form
- the recent-expense list is cleaner to scan
- the app feels more polished without becoming more complex
