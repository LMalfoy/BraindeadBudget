# Implementation Checklist: v2.1

## 1. Temporal Pattern Refinement

- define a finer intra-month bucketing model with about 10 periods
- keep the interpretation layer separate from the chart buckets
- ensure the wording still resolves to human-readable timing language

## 2. Month Comparison Expansion

- define a trailing 6-month comparison series
- update the comparison module to render the broader view clearly
- keep the interpretation focused on direction rather than raw chart complexity

## 3. Discipline Rank Compatibility

- confirm the discipline-rank logic still receives coherent temporal and comparison signals
- avoid changing rank behavior unless the refined inputs clearly justify it

## 4. Regression Safety

- preserve all existing Stats cards and ordering unless the refinement requires a small local adjustment
- avoid touching navigation or non-Stats flows

## 5. Tests And Verification

- add focused unit tests for temporal bucketing
- add focused unit tests for the 6-month comparison helper
- add or update focused Stats UI tests
- manually review that the Stats screen stays readable on phone-sized layouts
