# Iteration 2.9 Spec

## Title

Savings-Based Chess Progression

## Goal

Replace the current behavior-based budget discipline model with a savings-based chess progression system that rewards the budgeting outcome that actually matters.

## Context

The current discipline model still carries assumptions that are no longer aligned with the product direction.

Examples:

- heavy spending in one category is not automatically bad
- spending early in the month is not automatically bad
- behavioral style should be visible in statistics, but not used as the main achievement signal

The progression layer should instead reward how well the user actually preserves budget by the end of the period.

## Core Product Rule

Progression should be driven primarily by saved budget percentage at period end.

This should be cumulative across periods and feel like achievement progression, not a volatile monthly judgment.

## Target Structure

Use chess-themed tiers and sublevels:

- Pawn
- Knight
- Bishop
- Rook
- Queen
- King

The non-final tiers should contain multiple sublevels.

## Product Behavior

- stronger savings produce more progression
- one strong month may produce multiple level-ups
- poor months should not reward progress
- harmless spending style differences should not reduce progress

## UI Direction

- keep the progression panel below the top total-spending overview
- make the current piece and sublevel understandable
- explain progress simply
- avoid fake precision as the main identity

## Scope

- replace the current discipline logic with a savings-based progression evaluator
- redesign the existing discipline panel accordingly
- keep the implementation deterministic and testable
- preserve the broader Stats architecture introduced in the previous iteration

## Explicit Non-Goals

- do not redesign the whole Stats screen again
- do not add many extra reward mechanics
- do not add punitive regression unless explicitly chosen later
- do not mix in the later stats-order refinements yet

## Success Criteria

- the progression system matches the product philosophy better than the old discipline rank
- the result feels motivating rather than arbitrary
- the implementation is simple enough to explain clearly
