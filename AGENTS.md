# Agent Behavioral Directives

> This file contains behavioral protocols and self-evolution rules for the AI agent.
> **Profile & config:** See [CLAUDE.md](CLAUDE.md)
> **Archive rules:** See [archive/RULES.md](archive/RULES.md)

---

## Plugin Loading Protocol (Session Start)

At session start, two loading paths run:

### Built-in Plugins (`plugins/built-in/*/plugin.yaml`)

Multi-contribution plugin manifests (SOPs, guards, knowledge, workflows):

1. **Scan** — Glob `plugins/built-in/*/plugin.yaml`
2. **Parse** — For each manifest, validate: `id`, `version`, `trust` fields mandatory
3. **Activate** — For each activated plugin, resolve contribution file paths (relative to plugin dir) and classify:
   - `sops` → note in SOP registry (available SOPs for task execution)
   - `guards` → append to behavioral directives for this session
   - `knowledge` → inject into memory context
   - `workflows` → register workflow templates
4. **Log** — Output loaded plugin summary

### Community Skills (`plugins/community/*/SKILL.md`)

Native Claude Code skills — auto-discovered and loaded by the `Skill` tool. Agent's role is lifecycle management:

- `discovered` → present for review → user approval → INDEX.md `enabled`
- `enabled` → `Skill` tool discovers on next session start
- `disabled` → agent skips the community dir during session start scan

**Community trust flow:**

- Skills in `plugins/community/` start as `discovered` → require review prompt → user approval → `enabled`
- Disabled community skills are skipped during scan (log: "Skill [id] — disabled, skipping")

**Protocol detail:** See [plugins/PLUGINS.md](plugins/PLUGINS.md) | [Skill Import SOP](../archive/evolution/sops/Skill-Import.sop.md)

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
est_input_tokens: NK (estimated total input tokens consumed)
est_output_tokens: NK (estimated total output tokens consumed)
retrieval_cost: NK (tokens spent on pre-execution retrieval, 0 if skipped)
```

> **Token estimation method:** Rough per-tool baseline — Read ~0.5-2K, Write/Edit ~0.5-1K, Bash ~0.5-1K, Agent dispatch ~2-4K overhead, Glob/Grep ~0.2K. Multiply by call count per tool type. Not precise, good enough for trend analysis.

Record at `archive/evolution/metrics/YYYY-MM-DD_metrics.json` (one JSON object per file).

Trend aggregation is maintained in `archive/evolution/metrics/INDEX.md` — updated on write with 7-day and 30-day rollups. Added trend: **token_efficiency** — output tokens per unit of user value (proxied by outcome × user_sentiment).

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
4. **Run memory tier audit** — Check auto-memory files for stale entries; downgrade Hot→Warm→Cold per fade thresholds; update MEMORY.md index accordingly (see `archive/evolution/sops/Memory-Tier-Maintenance.md`)
5. Record quality metrics
6. Set `auto_evo_applied: {true|false}` in the experience log

### Scope Limits

- **Auto-patch target:** Only CLAUDE.md behavioral guards. No archive mutations, no new directories, no file creation beyond the metrics/ and feedback/ recording paths.
- **Only for patterns with count >= 3** that pass the Candidate→Promotion gate (see `archive/evolution/README.md`).
- **Manual evolution** ("进化") is still required for: archive mutations, proposal generation, workflow optimization, SOP creation.

## Quick Reference

- **Archive rules:** [archive/RULES.md](archive/RULES.md)
- **Self-Evolution Engine:** [archive/evolution/README.md](archive/evolution/README.md)
- **Frontier Radar:** [archive/evolution/frontier-radar.md](archive/evolution/frontier-radar.md)

---

## Complex Task Protocols (v0.5)

Routing triggers for pre-execution knowledge retrieval, task decomposition, sub-agent dispatch, and pitfall avoidance. Detailed protocols are in `archive/evolution/protocols/` — load on demand.

### Trigger Mapping

| Condition | Protocol File | When to Load |
| --- | --- | --- |
| Complex task starts (score 7-9 or ambiguous) | [PreExecutionRetrieval.md](archive/evolution/protocols/PreExecutionRetrieval.md) | Before first execution tool call — search patterns/SOPs/archive for prior knowledge |
| Complexity evaluation ≥ 7 | [TaskDecomposition.md](archive/evolution/protocols/TaskDecomposition.md) | Need to break task into 3-5 sub-tasks before executing |
| Sub-agent dispatch needed | [SubAgentDispatch.md](archive/evolution/protocols/SubAgentDispatch.md) | Dispatching Agent tool with prompt template + PUA injection |
| Mid-execution milestone | [PitfallAvoidance.md](archive/evolution/protocols/PitfallAvoidance.md) | At milestone checkpoints — match current state against known failure patterns |

### Protocol Lifecycle

- These protocols are loaded **on demand** — never at session start
- Simple tasks (score 3-4) skip all protocols entirely
- Workflow templates in `archive/evolution/workflows/INDEX.md` complement these protocols with step-by-step execution sequences
