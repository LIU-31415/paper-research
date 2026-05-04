# Agent Behavioral Directives

> This file contains behavioral protocols and self-evolution rules for the AI agent.
> **Profile & config:** See [CLAUDE.md](CLAUDE.md)
> **Archive rules:** See [archive/RULES.md](archive/RULES.md)

---

## Self-Evolution Protocol (Phase 1 — Experience Log + Auto-Patch)

At the end of each **non-trivial task** (anything beyond a single file edit):

1. Write one experience log entry to `archive/evolution/logs/YYYY-MM-DD_HHMM_ShortTitle.md`
2. Follow the schema in `archive/evolution/README.md` — capture
   `outcome`, `error_signal`, `root_cause`
3. If outcome is `failure` or `partial`: run pattern detection

**Failure Pattern Detection** (run when outcome is failure):

- Read `archive/evolution/logs/` last 5 entries
- If same `error_signal` appears >= 2 times in any 5-window → write to `archive/evolution/patterns/active/YYYY-MM-DD_ErrorCategory.md`
- Pattern format: `error_signal`, count, first_seen, last_seen, suggested_prevention
- If pattern already exists → increment count + update last_seen

**Auto-Patch Trigger** (run when pattern count >= 3):

1. Load guardrails from `archive/evolution/README.md`
2. Pre-flight: verify no conflicts, no delete operations
3. Snapshot target file to `patches/applied/{timestamp}_backup/`
4. Apply: append corrective rule to the relevant section
5. Verify: run 3 test cases → pass → `[verified]`; fail → restore from backup
6. Write patch record

**Guardrail Enforcement** (mandatory before any patch):

- `[G1]` ONLY append — never modify or delete existing content
- `[G2]` Pre-flight grep for conflicts; if found → abort and log
- `[G3]` Snapshot must exist before applying any changes
- `[G4]` After patch, verify >=3 cases; if any fail → restore snapshot
- `[G5]` Rule sunset — mark `[sunset: date]` instead of deleting rules; see evolution/README.md

## Evolution Trigger Protocol

User commands that activate the frontier scan + self-improvement pipeline:

| User says | Pipeline | Output |
|:--|:--|:--|
| `扫一下` | Scan pending sources + update Scan Log | Updated frontier-radar.md |
| `扫一下，合并出提升计划` | Scan → gap analysis → generate proposals | Proposal files + plan doc |
| `进化` | **Full pipeline**: Scan all pending → gap analysis → generate proposals → present for approval → **execute approved proposals on the spot** | Complete: scanned + proposed + applied + verified |

### `进化` Pipeline (Full Auto)

When user says "进化":

1. **Scan** — iterate all sources in frontier-radar.md registry where `Last Scan` is missing or exceeds `Freq`
2. **Analyze** — for each finding, run gap analysis vs current system (grep CLAUDE.md, AGENTS.md, archive/evolution/README.md, archive/RULES.md, sops/)
3. **Propose** — generate improvement proposals for P0/P1 findings
4. **Present** — show consolidated plan with priority matrix
5. **Execute** — after user approval (or if user pre-approved via "全部开始"): apply each proposal as file changes, run verification, update logs
6. **Log** — write experience log entry with outcome

**Important:** Step 5 (execute) only proceeds after explicit user approval. The user must say some form of "go ahead" / "开始" / "批准" before any files are modified. Exception: if user says "进化" and the scan finds only P2 items (no P0/P1), auto-close with zero changes.

## Quality Metrics — Session-End KPI Capture

After each non-trivial task (alongside experience log writing), record a lightweight KVP metrics entry:

```markdown
ts: YYYY-MM-DD_HHMM
outcome: {success|partial|failure}
user_sentiment: {positive|neutral|negative}
correction_count: N (how many times user corrected output)
retry_count: N (how many tool retries occurred)
duration_min: N
tools_used: [tool list]
tools_success_rate: N% (successful tool calls / total tool calls)
```

Record at `archive/evolution/metrics/YYYY-MM-DD_metrics.json` (one JSON object per file).

Trend aggregation is maintained in `archive/evolution/metrics/INDEX.md` — updated on write with 7-day and 30-day rollups.

## Feedback Ingestion Protocol

Capture implicit user signals during task execution and feed them into the evolution pipeline.

### Signal Types

| Signal | Detection | Action |
|--------|-----------|--------|
| Correction | User explicitly corrects output (e.g. "no, that's wrong", "change X to Y") | Log `correction` with context |
| Retry | User says "try again", "let me rephrase", or similar re-do indicator | Log `retry` with what was retried |
| Interruption | User stops mid-output to redirect | Log `interruption` with redirect context |
| Praise | User says "perfect", "great", "exactly" | Log `praise` — positive reinforcement signal |
| Criticism | User says "this is bad", "not what I wanted" (without specific correction) | Log `criticism` — triggers pattern review |

### Capture Procedure

1. When a signal is detected during task execution, append to an in-memory list
2. At session end, write any collected signals to `archive/evolution/feedback/YYYY-MM-DD_HHMM_signals.md`
3. Set `feedback_signals` field in the experience log
4. If same signal_type + context >= 2 in 5-window → feeds into pattern detection

## Autonomous Evolution (Session-End)

After non-trivial sessions, the system runs autonomous evolution as a background step:

1. Write experience log (as before)
2. Run pattern detection on last 5 logs
3. If count >= 3 pattern found with no conflicts → apply auto-patch to CLAUDE.md behavioral guards (respecting G1-G6 guardrails)
4. Record quality metrics
5. Set `auto_evo_applied: {true|false}` in the experience log

### Scope Limits

- **Auto-patch target:** Only CLAUDE.md behavioral guards. No archive mutations, no new directories, no file creation beyond the metrics/ and feedback/ recording paths.
- **Only for patterns with count >= 3** that pass the Candidate→Promotion gate (see `archive/evolution/README.md`).
- **Manual evolution** ("进化") is still required for: archive mutations, proposal generation, workflow optimization, SOP creation.

## Quick Reference

- **Archive rules:** [archive/RULES.md](archive/RULES.md)
- **Self-Evolution Engine:** [archive/evolution/README.md](archive/evolution/README.md)
- **Frontier Radar:** [archive/evolution/frontier-radar.md](archive/evolution/frontier-radar.md)
