# Pitfall-Aware Execution

> `[evol:protocol]` — Proactively check current actions against known failure patterns at each execution milestone.

## Milestone Definition

Milestones are points where a pitfall check runs. Interval depends on task complexity:

| Complexity | Milestone Interval |
|------------|-------------------|
| 3-4 (Simple) | No milestones — protocol not activated |
| 5-6 (Moderate) | After each logical phase of execution |
| 7-9 (Complex) | After each tool call that modifies files (Write/Edit/Bash with side effects) |

## Check Protocol

At each milestone:

1. **Extract signature** — What tool was used? What file was modified? What error occurred (if any)?
2. **Match against patterns** — Read the last 3 active patterns from `archive/evolution/patterns/*.md`. Check if current `error_signal` or action signature matches any known pitfall.
3. **If match found:**
   - Read the full matched pattern file
   - Apply the `suggested_prevention` immediately
   - Record: `pitfall_triggered: true — matched "{pattern_name}"`
4. **If no match but new error occurred:**
   - Log the error in working memory
   - If same error repeats within task → trigger Live Self-Evolution (defined in AGENTS.md Self-Evolution Protocol)

## Prevention Application

| Prevention Type | How to Apply |
|----------------|-------------|
| Tool choice | Switch to the recommended tool |
| Approach | Pause, describe pattern's recommended approach, follow it |
| Ordering | Reorder steps per pattern's suggested sequence |
| Verification | Run the pattern's verification check before proceeding |
| Abort | If pattern indicates unrecoverable path → abort and log |

## Logging

At task end, include in the experience log:

```yaml
pitfall_checks_run: N       # milestones checked
pitfall_matches: N           # patterns matched
pitfall_preventions: N       # prevention actions taken
pitfall_prevention_success: {true|false|partial}
```

If a matched pitfall was averted and task outcome is `success`, increment the pattern's count (reinforcing successful prevention). If outcome is still `failure`, the pattern's prevention rule may need revision.
