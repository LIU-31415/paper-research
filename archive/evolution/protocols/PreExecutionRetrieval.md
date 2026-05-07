# Pre-Execution Knowledge Retrieval Protocol

> `[evol:protocol]` — Search existing patterns, SOPs, and archive knowledge before starting any complex task.

## Trigger

Activate this protocol when a task is classified as **complex** (before the first execution tool call).

Task type classification: `{research|writing|tech|config|evolution|mixed}`

## Retrieval Sequence

Execute in order. Stop at any step if the match is sufficient to answer the task directly.

### Step 1 — Search Known Pitfalls

Read `archive/evolution/patterns/*.md` for patterns whose `task_types` match the current task type.

For failure patterns → note `error_signal` and `suggested_prevention` into context.
For success patterns → note `winning_approach` for reference.

### Step 2 — Search Relevant SOPs

Read `archive/evolution/sops/*.md` for SOPs whose `type:` or `task_types:` match.

For each match → read the Step Sequence and Common Pitfalls sections. Load into context as active reference.

### Step 3 — Search Archived Knowledge

Per `archive/RULES.md` Topic Routing Rules:
- research → `archive/topics/Research-Notes.md`
- writing → `archive/topics/Writing-Outputs.md`
- tech/config → `archive/topics/Tech-Solutions.md` + `archive/topics/Tool-Config.md`
- mixed → read `archive/INDEX.md` first to decide
- evolution → check existing logs in `archive/evolution/logs/` for prior similar tasks

### Step 4 — Search Workflow Templates

Read `archive/evolution/workflows/INDEX.md`. If a workflow template matches the task type, load its Template Steps as execution guidance.

## Knowledge Injection Format

After retrieval, inject a structured summary into context:

```markdown
## Pre-Retrieval Context for [{task_type}]

### Known Pitfalls
- [{name}]: {prevention} (last: {date})

### Relevant SOPs
- [{name}]: {steps} steps, {pitfalls_captured}

### Archived Knowledge
- {file}: {count} relevant entries

### Workflow Template
- [{name}]: {steps}, verification: {timing}
```

## Token Budget Control

### Per-Step Budget

| Step | Max Tools Calls | Est. Input Tokens | Stop Condition |
|------|---------------|-------------------|----------------|
| Step 1 (Pitfalls) | 1 Glob + 1 Read | ~0.5K | No match → proceed |
| Step 2 (SOPs) | 1 Glob + 1 Read | ~1-2K | Workflow found → use it |
| Step 3 (Archive) | 1 Read | ~0.5-2K | Answer found → skip rest |
| Step 4 (Workflows) | 1 Read | ~0.5K | Always optional |
| **Total** | **Max 6** | **~2.5-5K** | Can abort anytime |

### Hard Limits

- **Max 6 tool calls** total across all retrieval steps — if exceeded, proceed with partial context
- **Total retrieval should not exceed ~5K input tokens** — if estimated cost exceeds this, stop after Step 2 (only pitfalls + SOPs)
- Skip retrieval entirely for **simple tasks** (complexity score 4-5): single file read, single file edit ≤5 lines, single Bash command
- Fail open: if a file/directory doesn't exist, skip it silently — never block the task

### Efficiency Check

After retrieval, estimate whether the information found was worth the token cost:

- If retrieval consumed >3K tokens but found **zero relevant matches** → note in experience log: `retrieval_roi: low — {tokens_used}K tokens, 0 matches`
- If the same retrieval result could have been obtained in fewer steps → adjust the sequence next time (skip early steps when task type has low match rate)
- Two consecutive `retrieval_roi: low` for the same task type → consider removing an early retrieval step for that type

## Logging

If a retrieved pitfall match prevented a failure during execution, record in the experience log:

```
pitfall_prevention: true — matched pattern "{name}" prevented "{error_signal}"
```
