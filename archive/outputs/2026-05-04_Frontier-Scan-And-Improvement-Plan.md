# Frontier Scan & Unified Improvement Plan

`generated: 2026-05-04 | sources: 8 (5 fresh + 3 re-evaluated) | status: ⏳ Pending Approval`

---

## Executive Summary

Scanned 8 external signal sources across industry (OpenAI, DeepMind, Meta, Cursor, Anthropic) and research (arXiv, Semantic Scholar). Identified **6 actionable gaps** vs our current system, consolidated into **4 high-priority improvement proposals** and **2 medium-priority proposals**.

Current system baseline: Self-Evolution Engine v0.3 — experience logs → pattern detection → auto-patch/SOP extraction, plus frontier radar for external signal ingestion.

---

## Scan Coverage

| Source | Status | Method | Key Finding |
|--------|--------|--------|-------------|
| OpenAI Blog | ✅ new | WebSearch (fallback) | Harness Engineering — 10× throughput with 0 hand-written code |
| DeepMind Blog | ✅ new | WebFetch | AlphaEvolve — evolutionary code agent in production |
| Meta AI | ✅ new | WebSearch (fallback) | Self-Play SWE-RL — bug injection + repair via self-play |
| arXiv cs.AI | ✅ new | WebSearch (fallback, MCP 429) | Live-SWE-agent 75.4%, HGM, SEW |
| arXiv cs.CL | ✅ new | WebSearch (fallback) | Self-Improving Coding Agent (+53% SWE-bench) |
| Anthropic Blog | ✅ revisit | cached | (existing in registry) |
| Cursor Blog | ✅ revisit | cached | Bugbot — candidate→promotion gate |
| Semantic Scholar | ✅ revisit | cached | Darwin Godel + SEW (already proposed) |

---

## Findings & Gap Analysis

### F1: Context Engineering — AGENTS.md + docs/ Pattern
- **Source:** OpenAI Harness Engineering (Feb 2026)
- **Summary:** OpenAI's 5-month experiment used AGENTS.md (~100 lines) as agent map, `/docs/` as single source of truth, strict layered architecture with one-way deps enforced by linters
- **Gap:** Our system has only CLAUDE.md as agent context. No AGENTS.md, no structured `docs/` directory, no architecture constraint enforcement
- **Severity:** P1
- **Current state:** CLAUDE.md holds both profile info and self-evolution protocol — mixed concerns, no layering

### F2: Live Self-Evolution During Runtime
- **Source:** Live-SWE-agent (arXiv 2511.13646), Self-Improving Coding Agent (arXiv 2504.15228)
- **Summary:** Agents that autonomously modify their own code during execution — 75.4% SWE-bench Verified, 17-53% gain from self-reflection + code edit
- **Gap:** Our self-evolution is strictly post-task (experience log → pattern → patch). No runtime self-modification
- **Severity:** P1
- **Current state:** Evolution only fires at session boundaries, never mid-task

### F3: Self-Play Verification (Bug Injection → Fix Loop)
- **Source:** Meta Self-Play SWE-RL (arXiv 2512.18552)
- **Summary:** LLM dual-role (bug injection + bug solving) — +10.4 SWE-bench, no human-labeled data needed
- **Gap:** No automated adversarial verification. Our pattern detection only catches errors after they happen
- **Severity:** P1
- **Current state:** Reactive error detection only — no proactive bug injection / adversarial testing

### F4: Candidate→Promotion Gate for SOPs
- **Source:** Cursor Bugbot (blog)
- **Summary:** Success patterns go through candidate→promotion gate — only patterns with proven track record get promoted to active rules
- **Gap:** Our SOP extraction triggers at count >= 3, but there's no explicit promotion gate or candidate probation period
- **Severity:** P1
- **Current state:** SOP extraction is auto-triggered, no quality gate before promotion

### F5: Evolutionary Archive Mutation
- **Source:** Darwin Godel Machine (Semantic Scholar), DeepMind AlphaEvolve
- **Summary:** Archive entries can spawn variants through mutation + selection — AlphaEvolve discovered algorithms deployed in prod
- **Gap:** Archive is append-only, no mechanism to evolve/improve entries over time
- **Severity:** P2 (useful but requires careful design to avoid information loss)

### F6: Entropy Management / Automated Tech Debt Scan
- **Source:** OpenAI Harness Engineering
- **Summary:** Automated "garbage collection" agents that periodically scan for stale docs, code drift, entropy
- **Gap:** No stale detection beyond the 6-month staleness check in archive rules
- **Severity:** P2 (nice to have, lower ROI)

---

## Consolidated Improvement Proposals

### P1-1: Context Engineering System (AGENTS.md)
- **Why:** One CLAUDE.md mixes user profile, routing rules, archive config, self-evolution protocol, quick ref — every task loads everything
- **Proposed structure:**
  ```
  CLAUDE.md          ← User profile + Quick ref only (~20 lines)
  AGENTS.md          ← Agent behavioral directives (rules, routing, protocols)
  docs/              ← Project documentation (architecture, patterns, guides)
  archive/           ← Knowledge base (unchanged)
  ```
- **Steps:**
  - [ ] Extract behavioral rules from CLAUDE.md → AGENTS.md
  - [ ] Create `docs/` directory for architecture docs
  - [ ] Update CLAUDE.md to reference AGENTS.md + docs/
  - [ ] Verify: ask agent a routing question → routes correctly

### P1-2: Live Self-Evolution (Mid-Task Adaptation)
- **Why:** Current evolution fires only post-task — misses opportunity to self-correct during execution
- **Proposed change:** Add `[evol:live]` marker to enable runtime detection loops:
  - Before each tool call, check for repeated failure pattern
  - If same error_signal repeats within task → trigger inline fix (not post-task patch)
- **Files involved:**
  - `CLAUDE.md`: add Live Self-Evolution Protocol section
  - `archive/evolution/README.md`: add live evolution to architecture diagram
- **Steps:**
  - [ ] Define trigger conditions (same error × 2 within task)
  - [ ] Define inline fix flow (log → reflect → try alternative → continue)
  - [ ] Verify: inject duplicate error, confirm inline fix triggers

### P1-3: SOP Candidate→Promotion Gate
- **Why:** Current SOP extraction at count >= 3 has no quality gate — bad SOPs can propagate
- **Proposed change:** Add probational period to SOP lifecycle:
  ```
  Count >= 2 → Candidate SOP (tagged [candidate])
  Count >= 3 + explicit approval → Promoted SOP (remove [candidate] tag)
  Count >= 3 but no reoccurrence in 14d → Auto-close
  ```
- **Files involved:**
  - `archive/evolution/README.md`: update SOP extraction trigger rules
  - `archive/evolution/sops/`: candidate SOPs marked `[candidate]`
- **Steps:**
  - [ ] Add candidate status to SOP lifecycle
  - [ ] Implement 14-day auto-close for candidates
  - [ ] Verify: count=2 → candidate, count=3+approval → promoted

### P1-4: Proactive Adversarial Verification
- **Why:** All error detection is reactive — no mechanism to proactively inject and catch issues
- **Proposed change:** Add pre-commit verification step that anticipates failure modes:
  - Before writing archive entries, check for contradictions with existing entries
  - Before patching, simulate the patch against 3 test cases (already in G4 — formalize as adversarial step)
- **Files involved:**
  - `archive/evolution/README.md`: add adversarial verification step to auto-patch flow
- **Steps:**
  - [ ] Formalize the pre-patch verification as "adversarial simulation" in guardrails
  - [ ] Define scope: archive writes, pattern detection, SOP extraction
  - [ ] Verify: attempt contradictory archive entry → caught by adversarial check

### P2-1: Archive Mutation (Evolutionary Entries)
- **Why:** Archive is a static knowledge base — no evolution of existing entries
- **Proposed change:** Allow `[evol:mutation]` tags that spawn variant entries from existing ones, tracked via mutation lineage
- **Steps:**
  - [ ] Define mutation format (parent link + diff)
  - [ ] Add mutation support to archive rules
  - [ ] Verify: create mutation, confirm parent lineage preserved

### P2-2: Entropy Scan (Staleness Automation)
- **Why:** 6-month staleness check is passive — no active scanning
- **Proposed change:** Make staleness check proactive: on any archive write, scan 3 random old entries for staleness
- **Steps:**
  - [ ] Add proactive staleness scan to archive write workflow
  - [ ] Define coverage rule (3 random entries per write)
  - [ ] Verify: write new entry → confirm old entries scanned

---

## Existing Proposals (from earlier scan)

These 3 proposals from the `2026-05-04_1700` scan remain valid:

| Proposal | File | Relation to this plan |
|----------|------|----------------------|
| Archive-Evolution-Mutation | [proposal](proposals/2026-05-04_Archive-Evolution-Mutation.md) | Maps to P2-1 above (Archive Mutation) |
| Candidate-Promotion-Gate | [proposal](proposals/2026-05-04_Candidate-Promotion-Gate.md) | Maps to P1-3 above (Candidate→Promotion Gate) |
| Workflow-Auto-Optimization | [proposal](proposals/2026-05-04_Workflow-Auto-Optimization.md) | Standalone — multi-agent topology optimization |

**Workflow Auto-Optimization** is kept as standalone P1 proposal (not merged into above plan) because it requires infrastructure changes beyond the scope of this evolution system.

---

## Priority Matrix

| Proposal | Impact | Effort | Priority |
|----------|--------|--------|----------|
| P1-1: Context Engineering | High (immediate routing improvement) | Low (restructure files) | **#1** |
| P1-3: Candidate→Promotion Gate | Medium (quality) | Low (rule change) | **#2** |
| P1-4: Adversarial Verification | Medium (prevention) | Low (formalize existing G4) | **#3** |
| P1-2: Live Self-Evolution | High (capability) | Medium (new protocol) | **#4** |
| P2-1: Archive Mutation | Medium (evolution) | Medium | **#5** |
| P2-2: Entropy Scan | Low (maintenance) | Low | **#6** |

**Tier 1 (this sprint):** P1-1, P1-3, P1-4 — high impact, low effort, quick wins
**Tier 2 (next sprint):** P1-2 — high impact but needs more design
**Tier 3 (backlog):** P2-1, P2-2 — nice to have

---

## Verdict

```
Sources scanned:  8/8  ██████████ 100%
Proposals generated: 6 (4 P1 + 2 P2)
Quick wins (Tier 1): 3 — can execute immediately
```

> Ready for review. Approve Tier 1 proposals to begin execution.
