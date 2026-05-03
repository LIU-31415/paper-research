# Self-Evolution Engine

`last-updated: 2026-05-03 | version: v0.1`

## Architecture

```
Session End → Experience Log → Pattern Detection → Auto-Patch
                                                 ↓
                    SOP Extraction → Skill Evolution (Phase 2)
```

## Guardrails (三条红线，不可违反)

1. **只加不减** — Evolution patches only APPEND to files, never DELETE existing content. Old entries get `[deprecated]` mark, never removed.
2. **预检必过** — Every patch must pass pre-flight check: no conflict with existing rules, no safety degradation, rollback snapshot taken.
3. **每改必验** — After patching, run 3 test cases: the original failure + 2 similar scenarios. Failure to pass → automatic rollback.

## Directory

| Path | Purpose |
|------|---------|
| `logs/` | Structured experience logs from each task session |
| `patterns/active/` | Currently tracked failure/correction patterns |
| `patterns/resolved/` | Fixed patterns with verification evidence |
| `patches/applied/` | Successfully applied patches (snapshot + diff) |
| `patches/rolled-back/` | Rolled back patches with root cause |
| `sops/` | Phase 2: SOPs extracted from successful trajectories |

## Log Entry Schema

Each log entry captures one task execution outcome. Format:

```markdown
# YYYY-MM-DD_HHMM: Short Title

type: {research|writing|tech|config|evolution|mixed}
outcome: {success|failure|partial}
duration_min: N
task_summary: One-line description

## Signals
error_signal: Exact error message or failure description
repeat_count: How many times this exact error appeared

## Context
intent: What user asked for
approach: What was tried (3-5 word summary)
tools_used: [tool1, tool2, ...]

## Outcome Detail
- What worked / didn't work
- Key decision point

## Resolution (if failure)
root_cause: One-line root cause
fix_summary: How it was fixed
prevention: What should prevent recurrence
```

## Pattern Detection Rules

1. Same `error_signal` appearing >= 2 times → pattern created
2. Same `task_type` + similar `approach` failing → pattern updated
3. Pattern with no recurrence in 14 days → auto-close as `resolved`

## Auto-Patch Rules

1. Pattern identified → generate patch for `CLAUDE.md` or memory
2. Pre-flight: `grep` target file for conflict, verify no delete ops
3. Snapshot: copy target file to `patches/applied/{timestamp}_backup/`
4. Apply: append corrective rule/suggestion to target file
5. Verify: run 3 test cases → pass → mark `[verified]`
6. If verify fails → restore from snapshot → move to `rolled-back/`
