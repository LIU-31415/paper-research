# Proposal: Self-Supervised Feedback Loop

> **Status:** ⏳ Pending Approval
> **Source:** [scan-2026-05-04](#F1)

**Why this matters:** Cursor's Bugbot achieves 78% resolution rate on 110K+ repos by converting user feedback into reusable rules. OpenAI Codex self-improves by monitoring its own training runs. Our system learns only from post-session logs — we miss the richest signal: **what happens during a session**.

**Proposed change:** Add a feedback ingestion layer that captures implicit user signals during task execution (corrections, retries, interruptions, explicit praise/criticism) and feeds them into the evolution pipeline as structured data, parallel to the existing experience log path.

**Files involved:**
- `AGENTS.md`: Add "Feedback Ingestion" protocol section
- `archive/evolution/README.md`: Extend architecture diagram to include feedback loop path
- `archive/evolution/logs/`: Add `feedback_signals` field to log entry schema
- New: `archive/evolution/feedback/` directory for raw feedback signal records

**Steps:**
- [ ] Define feedback signal schema (correction, retry, interruption, praise, criticism)
- [ ] Add feedback capture procedure to AGENTS.md behavioral directives
- [ ] Update experience log schema with `feedback_signals` field
- [ ] Wire feedback signals into pattern detection (if same correction type >= 2 in 5-window)
- [ ] Add feedback directory to evolution README directory table
