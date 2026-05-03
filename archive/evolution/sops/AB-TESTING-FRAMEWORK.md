# A/B Testing Framework for Skill Evolution

Compare SOP-guided execution vs baseline to verify improvement before promoting a SOP.

## When to A/B Test

- New SOP extracted from >= 3 successful trajectories
- Significant behavior change suggested (tool change, step reordering, new verification step)
- Weekly: batch test SOPs in `sops/pending/` that haven't been validated

## Protocol

### Group A: Baseline (no SOP)

For a standard task of the target type:

```markdown
# A/B Test: {SOP Name}
date: YYYY-MM-DD
task: One-line representative task description

## Group A (Baseline — SOP not loaded)
outcome: {success | failure | partial}
duration_min: N
error_count: N
approach_difference: Was the approach significantly different from the SOP?

## Group B (With SOP)
outcome: {success | failure | partial}
duration_min: N
error_count: N
sop_followed: {all | most | partial | none}
```

### Metrics

| Metric | How to Measure |
|--------|---------------|
| Task success | outcome field |
| Efficiency | duration_min (lower = better) |
| Stability | error_count (lower = better) |
| Adherence | How closely SOP was followed |

### Decision

- B outperforms A on >= 2 metrics → promote SOP to `sops/` (remove `pending/` prefix)
- A ≈ B on all metrics → keep SOP, mark `[needs-more-data]`
- A outperforms B → archive SOP to `sops/archived/` with reason

## Limitation

AB tests on different but similar tasks, not identical ones. Results are indicative, not statistically rigorous. This is acceptable because:
1. The cost of a false-positive SOP adoption is low (append-only, easily reverted)
2. The value is in capturing heuristics, not proving causality
