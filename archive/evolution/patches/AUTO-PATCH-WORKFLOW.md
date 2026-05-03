# Auto-Patch Workflow

Run when a pattern's `count >= 3`. Each step has guardrail gates — if a gate fails, abort immediately.

## Gate 0: Load Guardrails

Read `archive/evolution/README.md` section "Guardrail Enforcement". Internalize G1-G4.

## Step 1: Pre-Flight Check

Identify target file(s) to patch. Common targets:
- `CLAUDE.md` — add workflow rule or prevention tip
- `MCP memory` — add observation via `mcp__memory__add_observations`
- `archive/evolution/patterns/active/*.md` — update pattern status

**Check**: Using `grep`, verify the proposed patch content does not already exist in the target file.
- If conflict found → **ABORT** and write to `patches/rolled-back/{timestamp}_conflict.md`

**Check**: Verify the patch is an APPEND operation (no DELETE, no MODIFY of existing lines).
- If patch modifies/removes existing content → **ABORT**

## Step 2: Snapshot

```bash
cp <target-file> archive/evolution/patches/applied/{timestamp}_backup_<basename>
```

Verify snapshot exists before proceeding.

## Step 3: Apply Patch

Append the correction/prevention rule to the relevant section of the target file. Only use APPEND — never inline edit.

Example append to CLAUDE.md:
```markdown
- [evolution:rule] Short actionable rule derived from failure pattern
```

## Step 4: Verify

Run >= 3 test cases:
1. Re-trigger the original failing scenario
2. Trigger a similar scenario in the same category
3. Trigger an unrelated scenario (to check for regression)

**Pass condition**: Cases 1 and 2 succeed, Case 3 behavior unchanged.

**If any fail**: Restore from snapshot:
```bash
cp archive/evolution/patches/applied/{timestamp}_backup_<basename> <target-file>
```
Move patch record to `patches/rolled-back/`.

## Step 5: Record

Write a patch record to `patches/applied/{timestamp}_PatchName.md`:

```markdown
# {timestamp}: PatchName

target: path/to/target
pattern_ref: patterns/active/ErrorCategory.md
snapshot: patches/applied/{timestamp}_backup_<basename>

## Diff
[description of what was appended]

## Verification
- [x] Case 1 (original failure): pass
- [x] Case 2 (similar scenario): pass
- [x] Case 3 (regression check): pass

## Status
[verified]
```
