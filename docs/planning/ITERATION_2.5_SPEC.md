# Iteration 2.5 Spec

## Title

Recurring Cost Entry Redesign

## Goal

Redesign recurring-cost entry so it matches the visual language and interaction quality of the main add-expense flow.

## User Outcome

When the user adds or edits a recurring cost, the experience should feel:

- immediate
- category-first
- consistent with expense entry
- easy to complete quickly

## Scope

### 1. Category-First Layout

- move recurring-cost category selection to the top of the editor
- render all 5 recurring-cost categories in one horizontal row
- keep category selection visible at all times during the edit flow

### 2. Add-Expense Visual Language

- match the tile-based look and selected-state clarity of the main add-expense sheet
- use meaningful icons and color coding
- keep the form visually simple and light

### 3. Preserve Existing Behavior

- do not redesign recurring-cost persistence logic
- do not change the underlying category set
- preserve current save and edit behavior

## Product Rules

- recurring-cost entry should feel like a sibling of add-expense, not a generic settings form
- all 5 categories must be available in one row
- the UI should remain clear on phone-sized screens
- do not widen scope into a general setup-screen overhaul

## Out Of Scope

- new recurring-cost categories
- recurring-cost analytics changes
- income entry redesign
- stats-screen redesign
