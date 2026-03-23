## Objective

Finalize onboarding and setup explanations for the 1.0 release by simplifying the onboarding flow, removing inconsistent terminology, and aligning UI labels with the explanatory copy.

## In Scope

- Reduce onboarding to 2 screens
- Replace onboarding copy with the final 1.0 wording
- Add short explanation texts under setup sections
- Rename the setup personalization section to `Budget available for this period`
- Align the explanatory copy with the actual setup label
- Show `Version 1.0 (Build X)` using the bundle version/build values
- Set the build number to the current git commit count

## Out of Scope

- New features
- Layout redesign
- Product structure changes
- Any other settings or onboarding flow changes

## Acceptance Criteria

- Onboarding has exactly 2 screens
- Screen 1 title is `Budget Rock`
- Screen 2 title is `How your monthly budget works`
- Only the second screen shows `Start Setup`
- Setup sections include the requested explanatory texts
- Section title becomes `Budget available for this period`
- Settings shows `Version 1.0 (Build X)`
- Xcode build number matches the current git commit count
