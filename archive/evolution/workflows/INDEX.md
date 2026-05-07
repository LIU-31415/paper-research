# Workflow Templates

> **Purpose:** Optimized execution sequences for multi-step tasks, inspired by SEW (+12% LiveCodeBench via workflow auto-optimization).
> **Last updated:** 2026-05-05

Schema and protocol defined in `../README.md` (Workflow Auto-Optimization section).

## Available Templates

### 1. Evolution Workflow ("进化")

**task_types:** [evolution]
**tool_order:** [Glob, Grep, Read, Write, Edit, Bash]
**verification_timing:** after_each
**archive_routing:** [logs, proposals, patterns]

#### Steps

1. **Scan** — Iterate pending sources in `frontier-radar.md`. For each source: WebFetch or WebSearch for latest content. Extract 1-2 sentence findings.
2. **Analyze** — For each finding, run gap analysis vs current system (grep CLAUDE.md, AGENTS.md, README.md, RULES.md, sops/). Classify severity: P0/P1/P2.
3. **Propose** — Generate improvement proposals for P0/P1 findings.
4. **Present** — Show consolidated plan with priority matrix to user.
5. **Execute** — After user approval, apply each proposal: pre-flight guardrails → snapshot → append → verify (3 cases).
6. **Log** — Write experience log entry with outcome.

#### Evolution Pitfalls

- User has previously criticized proposals without execution → **Prevention:** Step 5 (Execute) is mandatory. Pipeline must run end-to-end.
- Over-scoping → **Prevention:** Cap at 3 sources per session.

---

### 2. Research Workflow

**task_types:** [research]
**tool_order:** [mcp__semantic-scholar__search_papers, mcp__semantic-scholar__get_paper, WebFetch, Read, Write]
**verification_timing:** at_end
**archive_routing:** [topics/Research-Notes.md, outputs/]

#### Steps

1. **Pre-retrieval** — Check `archive/topics/Research-Notes.md` for existing entries on the topic. If existing answer exists → present, skip search. If partial → note what's known vs needed.
2. **Search** — Query Semantic Scholar: 2-3 query variants. Use `fields: [title, year, authors, abstract, externalIds]` for compact results.
3. **Read** — For top 3-5 papers: fetch full text. Extract: core finding, methodology, relevance.
4. **Synthesize** — Compare across papers. Identify consensus, contradictions, gaps.
5. **Archive** — Write to `archive/topics/Research-Notes.md`: conclusion-first, 3-5 bullets. If deliverable requested: save full version to `archive/outputs/`.
6. **Cross-reference** — Check `Tech-Solutions.md` for related technical implementations that could apply.

#### Research Pitfalls

- arXiv 429 rate limit → **Prevention:** Semantic Scholar primary, arXiv fallback.
- Paper not accessible → **Prevention:** Search preprint/alternative; note access limitation.
- Finding contradicts archive → **Prevention:** Flag for user confirmation per dedup rules.

---

### 3. Tech Task Workflow

**task_types:** [tech, config]
**tool_order:** [Read, Grep, Glob, Edit, Write, Bash]
**verification_timing:** both
**archive_routing:** [topics/Tech-Solutions.md, topics/Tool-Config.md]

#### Steps

1. **Pre-retrieval** — Check `archive/topics/Tech-Solutions.md` and `Tool-Config.md`. If exact solution exists → apply, skip rest. If similar exists → adapt.
2. **Understand** — Read relevant files. Identify all files needing modification (Glob). Check dependencies (Grep for imports).
3. **Design** — If 3+ files involved → EnterPlanMode first. Document: approach, files, verification criteria.
4. **Implement** — One file at a time (or parallel if independent). After each file: Pitfall-Aware check.
5. **Verify** — Syntax check → functional check → regression check (existing behavior preserved).
6. **Archive** — Write to `archive/topics/Tech-Solutions.md`: problem, approach, key snippet (max 10 lines), verification result.

#### Tech Pitfalls

- Over-engineering → **Prevention:** Minimum-change rule, smallest diff to achieve goal.
- Windows PATH issues → **Prevention:** Verify tool availability; add to `~/.bashrc`.
- Mid-execution pitfall match → **Prevention:** Stop, apply `suggested_prevention`, continue.

---

## Template Lifecycle

| Status | Label | Condition |
|--------|-------|-----------|
| Candidate | `[candidate]` | Proposed from deviation analysis |
| Active | (none) | 3 successful uses with consistent results |
| Deprecated | `[deprecated: date]` | Replaced by superior variant (file preserved) |
