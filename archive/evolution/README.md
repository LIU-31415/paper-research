# Self-Evolution Engine

`last-updated: 2026-05-04 | version: v0.4`

## Architecture

```
External Signal (Frontier Radar)
         ↓
  Gap Analysis ──→ Improvement Proposal ──→ (enters existing pipeline)
                                              ↓
Session End → Experience Log → Pattern Detection ──┬→ Failure: Auto-Patch → Verify
                                                      │                         ↓
                                                      │                   CLAUDE.md / Memory
                                                      │
                                                      └→ Success: Repeat ≥ 2 → SOP Extraction
                                                                                    ↓
                                                                          Phase 2: Skill Evolution
```

## Guardrails (三条红线，不可违反)

1. **只加不减** — Evolution patches only APPEND to files, never DELETE existing content. Old entries get `[deprecated]` mark, never removed.
2. **预检必过** — Every patch must pass pre-flight check: no conflict with existing rules, no safety degradation, rollback snapshot taken.
3. **每改必验** — After patching, run 3 test cases: the original failure + 2 similar scenarios. Failure to pass → automatic rollback.
4. **规则淘汰** — Rules can be marked `[sunset: YYYY-MM-DD]` instead of deleted. A sunset rule stays in the file but is excluded from active enforcement. Only append sunset markers, never remove the original text (compatible with G1).
5. **候选晋升** — `[G6]` Patterns must pass Candidate phase before Active promotion. Candidate → Active requires count >= 3 + no negative user sentiment + no rule conflict. Active → Disabled on user reversal. (See Candidate→Promotion Gate section.)

## Directory

| Path | Purpose |
|------|---------|
| `logs/` | Structured experience logs from each task session |
| `patterns/` | Active and resolved failure/correction patterns + success patterns |
| `sops/` | Phase 2: SOPs extracted from successful trajectories |
| `scans/` | Frontier scan records (standardized per-scan output) |
| `proposals/` | Improvement proposals generated from gap analysis |
| `metrics/` | Per-session KPI records + aggregated trend dashboard |
| `feedback/` | Raw feedback signal records (corrections, retries, praise) |
| `workflows/` | Workflow templates for multi-step execution optimization |

## Log Entry Schema

Each log entry captures one task execution outcome. Format:

```markdown
# YYYY-MM-DD_HHMM: Short Title

type: {research|writing|tech|config|evolution|mixed}
outcome: {success|failure|partial}
duration_min: N
task_summary: One-line description

## Signals
error_signal: Exact error message or failure description (or N/A)
success_signals: What patterns/approach led to positive outcome (or N/A)
user_sentiment: {positive|neutral|negative|unknown} — LLM-judged from user's reply tone after delivery
repeat_count: How many times this exact error appeared
feedback_signals: [list of {correction|retry|interruption|praise|criticism} during this task, or N/A]
auto_evo_applied: {true|false} — whether autonomous evolution triggered at session end

## Token Accounting
est_input_tokens: NK (approximate total input tokens consumed)
est_output_tokens: NK (approximate total output tokens consumed)
retrieval_cost: NK (tokens spent on pre-execution retrieval — 0 if not activated)
tools_used_count: N (total tool calls across all types)
retrieval_roi: {high|medium|low|N/A} — whether retrieval information justified its token cost

> **Token estimation and ROI guidance:** See AGENTS.md Quality Metrics section for per-tool baselines. ROI is determined by: **high** = retrieval found actionable prevention/SOP that changed execution approach; **medium** = found useful context but didn't materially change approach; **low** = consumed tokens with no relevant matches; **N/A** = retrieval not activated.

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

> **user_sentiment filling guide:** Infer from user's reply tone after delivery. **Positive** = explicit praise, "perfect", "great", quick progression to next task. **Neutral** = factual acceptance, no praise or criticism. **Negative** = frustration markers, "not what I wanted", "this is wrong", corrections. **Unknown** = no user reply captured.

## Pattern Detection Rules

1. Same `error_signal` appearing >= 2 times → pattern created
2. Same `task_type` + similar `approach` failing → pattern updated
3. Pattern with no recurrence in 14 days → auto-close as `resolved`

## Candidate→Promotion Gate for Pattern Rules

`[evol:gate]` — patterns must pass a candidate phase before triggering auto-patch, and can be disabled on negative feedback.

### Status Lifecycle

```text
Pattern Detected (count >= 2)
    → Candidate status (annotated in tracking list, no auto-patch)
    → Count reaches 3 AND confidence check passes
        → Promoted to Active (auto-patch eligible)
Count falls back (negative user signal)
    → Disabled (auto-patch blocked, kept for reference)
No recurrence in 14 days while Candidate
    → Auto-close Candidate (no promotion)
```

### Promotion Criteria

A Candidate pattern becomes Active when ALL of:
1. Count >= 3 in any 5-log window
2. No negative user sentiment in the last 2 related logs
3. Confidence check: the proposed prevention rule does not conflict with any existing active rule (pre-flight grep)

### Auto-Disable

If a patch is applied from an Active pattern and the user reverses or corrects it within the same or next session → mark the pattern as `disabled`. Disabled patterns remain for auditing but never trigger auto-patch.

### Relationship to Existing Flow

```text
count >= 2 → Candidate ──┬── count >= 3 + checks → Active → auto-patch eligible
                          │
                          └── 14d stale → auto-close

count >= 3 but user negative → Disabled (kept, not promoted)
```

## Success Pattern Detection

Symmetrical to failure detection — capture what works, not just what breaks.

### Detection Rules

1. Same `success_signals` appearing >= 2 times in a 5-log window → create success pattern
2. Same `task_type` + similar `approach` succeeding → update success pattern (increment count)
3. Success pattern with count >= 3 → auto-tag as SOP candidate

### Success Pattern File

Created at `archive/evolution/patterns/YYYY-MM-DD_Success-ShortName.md`:

```markdown
# Success-ShortName

first_seen: YYYY-MM-DD
last_seen: YYYY-MM-DD
repeat_count: N
task_types: [list of task types where this succeeded]

## Winning Approach

What was done differently. 1-2 sentence actionable summary.

## Related

- Log: path/to/log
```

### SOP Candidate→Promotion Gate

Success patterns go through a probational lifecycle before becoming stable SOPs:

```text
Count >= 2  → Candidate SOP (tag [candidate] in filename or header)
Count >= 3  + explicit approval (manual sign-off or auto-confirm if 3 reoccurrences in 7d)
            → Promoted SOP (remove [candidate] tag)
Count >= 3  but no reoccurrence in 14 days → Auto-close candidate (no promotion)
```

**Rules:**

- Candidate SOPs live in `archive/evolution/sops/` with `[candidate]` in their header
- Promoted SOPs are tagged `[verified]` and available for general use
- Auto-closed candidates are archived (not deleted) — can be revisited if pattern resurfaces

### SOP Extraction Trigger

When count >= 3 after promotion: create a reusable SOP (if one doesn't already exist for this pattern). SOP should be generic enough to apply to future tasks.

## Pattern/SOP Archive Mutation

`[evol:mutation]` — periodically recombine existing patterns and SOPs to discover improved variants, inspired by Darwin Godel Machine (archive + mutation → 20%→50% SWE-bench).

### Mutation Schema

Each mutation record tracks derivation:

```text
parent_pattern: path to original pattern/SOP
mutation_type: {crossover|refinement|simplification}
mutated_fields: [which fields were changed — e.g. prevention, winning_approach]
validation_result: {pass|fail} with test count
status: {candidate|promoted|rejected}
```

### Mutation Trigger

At each drift checkpoint (or manual trigger):
1. Sample 2 existing patterns or SOPs from the active archive
2. Attempt one of:
   - **Crossover**: merge prevention rules from 2 patterns
   - **Refinement**: rewrite a winning approach to be more generic or precise
   - **Simplification**: reduce verbosity while preserving key constraints
3. Validate: the new variant must pass >= 2 test scenarios (the original failure + 1 similar)
4. If pass → promote to SOP candidate with `mutated: true` tag
5. If fail → reject with reason logged

### Lineage Rules

- Each mutation tracks its parent via `parent_pattern` field
- Maximum 3 generations per lineage (original → v2 → v3)
- Beyond 3 → merge into new consolidated entry (same rule as Archive Mutation section)
- Mutations are auditable: every mutation has a clear rationale recorded

## Auto-Patch Rules

1. Pattern identified → generate patch for `CLAUDE.md` or memory
2. **Adversarial pre-check:** Before any patch, simulate 3 adversarial scenarios — what could this patch break? If any scenario hits a known failure pattern → abort or redesign
3. Pre-flight: `grep` target file for conflict, verify no delete ops
4. Snapshot: copy target file to `archive/evolution/{timestamp}_backup/`
5. Apply: append corrective rule/suggestion to target file
6. Verify: run 3 test cases → pass → mark `[verified]`
7. If verify fails → restore from snapshot → mark record as `[rolled-back]`

## External Signal Ingestion

Proactive frontier scanning — ingest signals from external sources (company blogs, research venues) and compare against current system to identify improvement opportunities.

### Scan Protocol

1. **Trigger** — Manual ("扫一下") or when `frontier-radar.md` has entries with `Last Scan` > `Freq`
2. **Scan** — For each source in `frontier-radar.md` registry:
   - If blog: `WebFetch` to get latest posts. **If WebFetch 404s**, retry with `WebSearch` using site-restricted query (e.g. `site:cursor.com/blog after:2026-01-01 agent`)
   - If research: Search via MCP (Semantic Scholar, arXiv) for recent agent-system papers. Try 2-3 query variants per source.
3. **Extract** — Per source, note: finding summary, potential impact on our system, confidence
4. **Gap Analysis** — For each finding:
   - Compare to current system state (grep relevant files, check patterns/ and sops/)
   - Classify severity: P0 / P1 / P2
   - If P0 or P1: **auto-generate improvement proposal** (see below)
5. **Output** — Write standardized scan record to `archive/evolution/scans/YYYY-MM-DD_scan.md`
6. **Log** — Update `frontier-radar.md` Scan Log with findings

### Standardized Scan Output

Each scan run produces a record at `archive/evolution/scans/YYYY-MM-DD_scan.md`:

```markdown
# Frontier Scan — YYYY-MM-DD

## Sources Scanned
- Source A: ✅/❌ (reason if failed)
- Source B: ✅

## Findings
### F1: Short Title
- Source: Source A
- Summary: 1-2 sentence key insight
- Gap: What we don't have / do differently
- Severity: P0/P1/P2
- Proposal: proposal-name.md ✅ / not generated

## Proposals Generated
- [Title](proposals/YYYY-MM-DD_Title.md)

## Scan Log Updated
- frontier-radar.md: ✅
```

### Improvement Proposal Format

Created at `archive/evolution/proposals/YYYY-MM-DD_ShortName.md` for every P0/P1 finding:

```markdown
# Proposal: Short Title

> **Status:** ⏳ Pending Approval
> **Source:** [scan-YYYY-MM-DD](#F1)

**Why this matters:** One-line gap description.

**Proposed change:** What to add/modify. 2-3 sentences.

**Files involved:**
- File A: what changes
- File B: what changes

**Steps:**
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3
```

Proposal pipeline: Pending Approval → Approved → Execute → Completed. Same flow as any upgrade plan.

### Gap Severity

| Level | Signal | Action |
| :---- | :----- | :----- |
| P0 | Industry best practice we're completely missing | Immediate proposal, auto-trigger |
| P1 | Improvement on existing capability | Generate proposal automatically |
| P2 | Interesting but not directly applicable | Log for reference only |

### Scan Directory

| Path | Purpose |
| :--- | :------ |
| `frontier-radar.md` | Source registry + scan log |
| `scans/` | Per-scan standardized output records |
| `proposals/` | Improvement proposals generated from gaps |

## Live Self-Evolution (Mid-Task Adaptation)

`[evol:live]` — detect and correct repeated failure patterns during task execution, not just after.

### Trigger Conditions

Live self-evolution activates when the **same `error_signal` appears >= 2 times within a single task**. Examples:

- Same tool call fails twice with identical error
- Same verification step fails on retry
- Same logical error pattern detected in output

### Inline Fix Flow

When triggered:

1. **Pause** — stop current attempt, log the repeated error
2. **Reflect** — check `archive/evolution/patterns/active/` for known fixes. If pattern exists → apply known prevention; if not → analyze root cause
3. **Switch** — try a **fundamentally different approach** (not a parameter tweak). Log which approach was tried and why it differs
4. **Continue** — resume task with the new approach
5. **Log** — at task end, the experience log entry includes `live_evo_triggered: true` and the inline fix result

### Relationship to Post-Task Evolution

```text
Live Evo (mid-task)     Post-Task Evo (end of task)
     │                         │
     │ catches repeat errors   │ catches structural patterns
     │ during execution        │ across multiple tasks
     │                         │
     └──→ both feed into ←─────┘
              experience log
                   │
                   ↓
            pattern detection
```

If live evo saved the task from a failure → the experience log outcome is still `success` (or `partial` if not fully resolved), but `live_evo_triggered: true` flags it for pattern analysis.

## Self-Supervised Feedback Loop

`[evol:feedback]` — capture implicit user signals during task execution and feed them into the evolution pipeline.

### Feedback Signal Schema

Each signal record captures one user-agent interaction event:

```
signal_type: {correction|retry|interruption|praise|criticism}
timestamp: ISO datetime
context: what was being done when signal occurred
trigger: what the user said/did that constituted the signal
related_log: link to experience log (if applicable)
```

### Signal → Pattern Detection Wiring

Same-type feedback signals feed into pattern detection like error signals:

- Same `signal_type` + same `context` pattern >= 2 times in 5-log window → create feedback pattern
- Pattern includes `suggested_behavior_change` (what the agent should do differently)
- Feedback patterns with count >= 3 trigger the same Candidate→Promotion gate lifecycle

### Signal Directory

| Path | Purpose |
| :--- | :------ |
| `feedback/` | Raw feedback signal records (one per session, if signals present) |

### Relationship to Live Self-Evolution

```
Live Evo catches repeat errors mid-task
    ↓
Feedback Loop captures user corrections mid-task
    ↓
Both → experience log (feedback_signals field)
    ↓
Pattern detection (including feedback patterns)
```

## Workflow Auto-Optimization

`[evol:workflow]` — analyze multi-step task execution sequences and optimize the workflow topology, inspired by SEW (+12% LiveCodeBench via workflow auto-optimization).

### Workflow Template Schema

Templates stored in `archive/evolution/workflows/`:

```markdown
# Workflow: ShortName

task_types: [which task types this template applies to]
tool_order: [typical sequence of tools in priority order]
verification_timing: {after_each|at_end|both}
archive_routing: [which archive entries to create]

## Template Steps
1. Step description with tool expected
2. ...

## Known Deviations
- Deviation: what went wrong → impact → fix
```

### Capture

After each multi-step task, the experience log may include a `workflow_sequence` field in the Outcome Detail section:

```text
workflow_sequence: [tool1, tool2, ...]
workflow_deviations: [if any step was suboptimal, note why]
```

### Optimization Trigger

If the same deviation pattern appears >= 2 times in a 5-workflow window:
1. Flag the deviation as a workflow anti-pattern
2. Generate an improved workflow template as a proposal
3. If the new template is consistently faster/better over 3 uses → promote it to default

### Directory

| Path | Purpose |
| :--- | :------ |
| `workflows/` | Workflow templates + optimization proposals |

## Archive Mutation (Evolutionary Entries)

`[evol:mutation]` — allow archive entries to spawn improved variants while preserving lineage.

### Mutation Format

When an existing archive entry can be improved:

1. Create new entry with same base title + `[v2]` suffix
2. Add `parent: [original entry path]` metadata line
3. Add `mutation: [what changed]` — one-line summary of the improvement
4. Append `[evol:mutation]` tag to original entry, linking to v2

### Rules

- Mutations preserve the original — no destructive edits (compatible with G1)
- Lineage is tracked via metadata, not directory structure
- Mutation without clear improvement rationale is not allowed — must explain what was wrong with original
- Maximum 3 generations per lineage (original → v2 → v3). Beyond that → merge into new consolidated entry

## Autonomous Evolution (Session-End Background)

`[evol:auto]` — run pattern detection and apply improvements autonomously at session end, without requiring manual "进化" invocation.

### Trigger

Autonomous evolution activates at session end when ALL of:
1. The task is non-trivial (not a single file edit or read-only operation)
2. An experience log was written for this session
3. No catastrophic failure occurred in the session (outcome is `success` or `partial`, not `failure`)

### Scope Limits (Safety)

- **In scope:** Pattern detection against existing logs, candidate→active promotion (if criteria met), auto-patch to CLAUDE.md behavioral guards, quality metrics recording
- **Out of scope:** Archive mutations (new directories, SOP creation), proposal generation, user-facing file creation. These still require manual "进化" invocation.

### Execution Flow

```text
Session end → write experience log
    → Auto-evo trigger check
        → If pass: run pattern detection on last 5 logs
            → If count >= 3 pattern found AND no conflicts
                → Apply auto-patch (respecting G1-G6 guardrails)
                → Update pattern status, write auto-evo log
        → Record quality metrics for this session
    → Done (user never needs to know unless a patch was applied)
```

### Record Keeping

Each auto-evo event is recorded at `archive/evolution/logs/` with:
- `auto_evo: true` in the log entry
- `auto_evo_result: {applied|skipped|blocked}`
- If applied: `patch_target: file_path`, `patch_action: summary`

## Entropy Scan (Proactive Staleness Detection)

Go beyond passive 6-month staleness checks with proactive scanning.

### Trigger

Every time an archive write operation occurs (topic entry, output, session), additionally:

1. Select 3 random entries from any topic file
2. Check their `last-reviewed` or creation date
3. If any selected entry is > 3 months old → append `[last-reviewed: YYYY-MM-DD]` to the entry (no action needed from user — just update the stamp)
4. If any selected entry is > 6 months old → flag it with `[stale-check: YYYY-MM-DD]` and present to user for review

### Escalation Rules

- Random selection uses a simple round-robin across topic files (not true randomness — ensures even coverage)
- Entries already reviewed within 1 month are excluded from selection
- Stale entries flagged but not reviewed within 7 days get escalated to `[stale-warn]` automatically
