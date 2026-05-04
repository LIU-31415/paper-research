# Proposal: Quality Metrics Dashboard

> **Status:** ⏳ Pending Approval
> **Source:** [scan-2026-05-04](#F3)

**Why this matters:** SWE-chat found only 44% of coding agent code survives into commits, and agent code introduces more security vulnerabilities. We have no metrics to track our own effectiveness — we can't measure if we're improving. What gets measured gets managed.

**Proposed change:** Add a lightweight quality metrics tracking system that logs key performance indicators at session end and surfaces them in a simple dashboard (a metrics file). Track KPIs per session: task outcome, user sentiment, correction count, retry count, duration ratio, tool success rate.

**Files involved:**
- New: `archive/evolution/metrics/YYYY-MM-DD_metrics.json` (per-session KVP)
- New: `archive/evolution/metrics/INDEX.md` (aggregated rollup + trend)
- `archive/evolution/README.md`: Add metrics directory reference

**Steps:**
- [ ] Define KPI schema (outcome, sentiment, corrections, retries, duration_min, tools_success_rate)
- [ ] Add session-end KPI capture procedure to AGENTS.md
- [ ] Create INDEX.md aggregator that computes 7-day/30-day trends
- [ ] Wire into evolution README
