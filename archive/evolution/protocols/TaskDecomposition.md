# Task Decomposition Framework

> `[evol:protocol]` — Decompose complex tasks into verifiable sub-tasks before execution.

## Complexity Scoring

Score each task on 4 dimensions. Sum for total (4-12).

| Dimension | Low (1pt) | Medium (2pts) | High (3pts) |
|-----------|-----------|---------------|-------------|
| File count | 1 file | 2-4 files | 5+ files |
| Tool count | 1-2 tools | 3-5 tools | 6+ tools |
| Ambiguity | Single clear goal | Multiple clear sub-goals | Vague or open-ended |
| **Token cost** | ~1-3K (single read/search) | ~3-8K (multi-file edit) | ~8-15K+ (research/agent dispatch) |

> **Token cost estimation guide:** Estimate by summing: each Read (~0.5-2K), each Write/Edit (~0.5-1K), each Agent dispatch (~2-4K overhead), each Bash (~0.5-1K). Whole-session context window ~32K usable — treat >15K as High.

### Routing by Score

| Score | Classification | Action |
|-------|---------------|--------|
| 4-5 | Simple | Execute directly. No decomposition. |
| 6-8 | Moderate | Optional decomposition if task spans multiple domains. |
| 9-12 | Complex | **Mandatory decomposition.** Follow full protocol below. |

## Decomposition Protocol (Score ≥7)

### 1. Break Down

Split the task into **3-5 sub-tasks**. Each sub-task must fit this template:

```markdown
## Sub-Task N: {Short Name}

goal: One-sentence description
file_domain: Which files/directories this touches
tools_expected: [tool1, tool2, ...]
token_budget: Estimated input tokens (e.g., ~3K for search, ~5K for multi-file edit)
verification: Specific observable criterion for completion
depends_on: [list of sub-task indices this depends on]
```

> **Token budget guidance:** A sub-task crossing >8K estimated input tokens should be flagged for further splitting. Agent dispatch sub-tasks add ~2-4K overhead per dispatch — factor this into the budget.

### 2. Order by Dependency

1. Build a dependency graph from `depends_on` fields
2. Group 1: sub-tasks with no dependencies (parallelizable)
3. Group 2: sub-tasks whose dependencies are all in Group 1
4. Continue until all sub-tasks are assigned

### 3. Validate

- [ ] All sub-tasks together cover the full original request? (no gaps)
- [ ] Any sub-task still scoring ≥7? If yes → recurse decomposition
- [ ] Each verification criterion is observable? (not vague)
- [ ] Dependency graph has no cycles? (can't have A→B→A)

### 4. Present

Show the decomposition to the user before executing. Compatible with CLAUDE.md's "先规划再执行" rule — use `EnterPlanMode` if the overall task warrants it.

## Execution Order

Groups execute sequentially (Group 1 → Group 2 → ...). Within a group, sub-tasks can be dispatched in parallel via `Agent` tool if independent.

After each sub-task: verify against its criterion before proceeding to dependents.

## Re-Evaluation

If a sub-task reveals unexpected complexity mid-execution, re-score it in isolation. If its score ≥7, recursively decompose it before continuing.
