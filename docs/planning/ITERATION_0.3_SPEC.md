# PocketBudget v0.3 Implementation Spec

## Iteration Goal

Make daily expense entry fast enough to use without hesitation.

This iteration should improve the add-expense flow, make category selection immediate, and move the primary expense action to an easy-to-reach position on the dashboard.

## Why This Iteration Comes Next

`v0.2` established the monthly budget baseline. `v0.3` should now improve the main repeated habit in the app:

"I spent money, I want to record it quickly, and I want the app to get out of my way."

## Scope

In scope:

- add fixed categories to expenses
- redesign the add-expense form around category, item name, and amount
- keep date and note as optional secondary fields
- improve focus and keyboard flow for fast entry
- move the add-expense action to the bottom of the dashboard for better one-handed access
- show category in expense rows using minimal color-coded accents
- update tests for the new expense model and flow

Out of scope:

- smart single-line input parsing
- dashboard charts
- expense edit/delete flows
- broad visual redesign outside the expense-entry path

## Product Decisions

### Categories

The category set for `v0.3` is fixed to:

- Food
- Transport
- Household
- Fun

These categories should cover the majority of day-to-day variable spending while staying easy to understand.

### Category Presentation

The add-expense screen should show the categories as four colored selectable tiles near the top of the form.

Design constraints:

- easy to tap
- minimal text
- immediately scannable
- visually distinct without making the screen noisy

Recommended color direction:

- Food: green
- Transport: blue
- Household: orange
- Fun: pink

### Add-Expense Form

The primary data entry path should be:

1. choose category
2. type item name
3. type amount
4. save

Secondary fields:

- date
- note

These should remain available but visually lower priority.

### Keyboard And Focus Behavior

When the add-expense sheet opens:

- the item name field should be ready for immediate typing
- pressing return on the item name field should move focus to the amount field
- the amount field should use a numeric keypad

The interaction should feel optimized for quick repeat use.

### Dashboard Add Button

The dashboard should place the add-expense action near the bottom of the screen where it is easy to reach with the right thumb.

This should feel like the main action of the app without overwhelming the rest of the layout.

## Data Model Changes

### `Expense`

Add a category field to `Expense`.

Recommended implementation:

- use a small enum or raw string-backed enum
- keep serialization simple
- provide display label and color mapping in one place

The category should be required for all new expenses in `v0.3`.

## Store Changes

Update expense persistence and validation so that:

- every expense has a valid category
- existing title and amount validation still applies
- category becomes part of the save path and any future edit path

## Screen Changes

### 1. Add Expense Sheet

Required changes:

- add category selection at the top
- make category selection quick and prominent
- keep item name and amount central in the layout
- keep date and note secondary
- support the focus behavior described above

### 2. Dashboard

Required changes:

- move the add-expense action to the bottom area
- keep the rest of the dashboard stable unless needed for layout support

### 3. Expense Row

Required changes:

- show category in a lightweight way
- use restrained color coding
- do not make the row visually busy

Possible patterns:

- small colored chip
- category label with accent color
- colored leading marker

## Acceptance Criteria

### Functional

- a user can create an expense with one of the four categories
- new expenses persist category correctly
- the expense list reflects category visually
- the add-expense action is reachable from the bottom area of the dashboard

### UX

- category is the first and easiest choice in the add-expense flow
- item name can be entered immediately after opening the sheet
- submitting item name moves focus to amount
- date and note remain available without slowing down the main path
- category colors improve scanning without making the interface cluttered

### Engineering

- the category model is simple and testable
- validation remains explicit and easy to follow
- tests are updated for the new required category field

## Test Plan

### Unit Tests

Add or update tests for:

- saving an expense with a valid category
- rejecting invalid expense data if category support introduces new validation
- ensuring existing budget calculations still work after the expense model change

### UI Tests

Add or update tests for:

- adding an expense with a selected category
- verifying the add-expense flow still works end-to-end
- verifying the bottom add-expense action is present

### Manual Checks

- open add-expense and confirm the item field is ready quickly
- verify return moves from item to amount
- verify amount uses the numeric keyboard
- verify category tiles are easy to tap
- verify the dashboard button is comfortable to reach one-handed

## Recommended Implementation Approach

Implement `v0.3` in this order:

1. add the expense category model
2. update store APIs and tests
3. redesign the add-expense sheet
4. update the dashboard add-expense action placement
5. update expense row presentation
6. run manual and automated checks

This keeps the model and validation work stable before touching the UI.
