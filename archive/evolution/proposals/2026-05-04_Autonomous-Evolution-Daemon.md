# Proposal: Autonomous Evolution Daemon

> **Status:** ⏳ Pending Approval
> **Source:** [scan-2026-05-04](#F2)

**Why this matters:** RoboPhD shows autonomous agent evolution (70→1500 lines, 18 iterations) with ELO-based selection, where "evolved Haiku exceeds naive Sonnet." Our "进化" pipeline is manual-triggered and requires human approval at step 5. We have no background evolution that continuously improves the system without user intervention.

**Proposed change:** Add an autonomous evolution mode that runs pattern detection and applies improvements without requiring manual "进化" invocation. This runs as a session-end background task for non-trivial sessions: after writing the experience log, the system automatically runs pattern detection and, for patterns with count >= 3, generates + applies patches autonomously (respecting all existing guardrails).

**Files involved:**
- `AGENTS.md`: Add "Autonomous Evolution" section with trigger conditions and scope limits
- `archive/evolution/README.md`: Add autonomous mode description to architecture
- `archive/evolution/`: Add auto-evolution log dir

**Steps:**
- [ ] Define autonomous evolution trigger (session-end for non-trivial tasks)
- [ ] Add scope limits (only patch CLAUDE.md guards, no archive mutations without user)
- [ ] Implement auto-apply for count >= 3 patterns
- [ ] Add auto-evolution record keeping
- [ ] Update experience log schema with `auto_evo_applied: bool` field
