# Pattern Detection Workflow

Run this when a task outcome is `failure` or `partial`.

## Step 1: Read Recent Logs

```bash
ls -t archive/evolution/logs/ | head -5
```

Read the 5 most recent logs. Extract `error_signal` from each.

## Step 2: Check for Recurrence

If any `error_signal` appears >= 2 times in the 5-log window:

1. Check if a pattern already exists in `archive/evolution/patterns/active/`
2. Grep patterns by the error signal category:

```bash
grep -l "error_signal:.*KEYWORD" archive/evolution/patterns/active/*.md
```

## Step 3: Create or Update Pattern

**New pattern**: Create `archive/evolution/patterns/active/YYYY-MM-DD_ErrorCategory.md`

**Existing pattern**: Read the file, increment `count` and update `last_seen`.

Pattern file template:

```markdown
# ErrorCategory

first_seen: YYYY-MM-DD
last_seen: YYYY-MM-DD
count: N
error_signal: exact error message
task_types: [list of task types where this occurred]

## Suggested Prevention

One-line actionable prevention rule.

## Related

- Log: path/to/log
- Log: path/to/log
```

## Step 4: Check Auto-Patch Trigger

If `count >= 3`: trigger Auto-Patch workflow (see `archive/evolution/README.md` Auto-Patch Rules).

If `count < 3`: no action needed. Pattern will be re-evaluated on next failure.
