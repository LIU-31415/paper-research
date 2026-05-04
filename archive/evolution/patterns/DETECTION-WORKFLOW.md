# Pattern Detection Workflow

Run after each task completion. **Always** detect both failure and success patterns.

## Part A: Failure Pattern Detection

Run when outcome is `failure` or `partial`.

### Step A1: Read Recent Logs

```bash
ls -t archive/evolution/logs/ | head -5
```

Read the 5 most recent logs. Extract `error_signal` from each.

### Step A2: Check for Recurrence

If any `error_signal` appears >= 2 times in the 5-log window:

1. Check if a pattern already exists in `archive/evolution/patterns/`
2. Grep patterns by the error signal category:

```bash
grep -l "error_signal:.*KEYWORD" archive/evolution/patterns/*.md
```

### Step A3: Create or Update Failure Pattern

**New pattern**: Create `archive/evolution/patterns/YYYY-MM-DD_ErrorCategory.md`

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

### Step A4: Check Auto-Patch Trigger

If `count >= 3`: trigger Auto-Patch workflow (see `archive/evolution/README.md` Auto-Patch Rules).

If `count < 3`: no action needed. Pattern will be re-evaluated on next failure.

---

## Part B: Success Pattern Detection

Run when outcome is `success` (or `partial` with identifiable success elements).

### Step B1: Extract Success Signals

From the experience log, extract the `success_signals` field. Identify what specifically worked: tool choice, approach pattern, workflow sequence, or communication style.

### Step B2: Check for Recurrence

If same `success_signals` pattern appears >= 2 times in the 5-log window:

```bash
grep -l "success_signals:.*KEYWORD" archive/evolution/patterns/*.md
```

### Step B3: Create or Update Success Pattern

**New pattern**: Create `archive/evolution/patterns/YYYY-MM-DD_Success-ShortName.md`

**Existing pattern**: Read the file, increment `repeat_count` and update `last_seen`.

Success pattern file template:

```markdown
# Success-ShortName

first_seen: YYYY-MM-DD
last_seen: YYYY-MM-DD
repeat_count: N
task_types: [list of task types]

## Winning Approach

1-2 sentence description of what worked.

## Related

- Log: path/to/log
```

### Step B4: Check SOP Extraction

If `repeat_count >= 3`: trigger SOP extraction (create or update an SOP in `archive/evolution/sops/`).

If `repeat_count < 3`: no action. Track on next success.
