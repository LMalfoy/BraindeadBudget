# PocketBudget Backlog

Future improvements and final polish notes that remain relevant after the current core feature work.

## Final Product Issues

- Add a smooth expense editing flow that reuses the add-expense style where practical.
- Make dashboard expense rows tappable later if that helps surface edit/detail actions cleanly.
- Keep history month navigation lightweight; the month picker should feel smaller and less visually heavy.
- Consider removing any remaining redundant history labels if they do not add meaning.
- Review dark mode carefully across all major screens and sheets.
- Do a final pass on empty states, copy, spacing, and modal dismissal behavior.
- Confirm the chess asset attribution and licensing notes remain correct for shipped assets.
- Review automated UI tests and keep only the ones that are reliable enough to trust.
- Remove stale planning artifacts and obsolete iteration leftovers from the repo when convenient.

## Explicit Non-Goals

These ideas are intentionally deferred or dropped for now:

- custom spending categories
- custom category colors
- broader app customization controls
- another large redesign of the Statistics architecture

## Usage Rule

Only pull items from this list into an active iteration when:

- they clearly improve product quality, or
- they remove friction without destabilizing working flows
