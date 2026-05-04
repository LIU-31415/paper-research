# Proposal: Workflow Auto-Optimization

> **Status:** ⏳ Pending Approval
> **Source:** [scan-2026-05-04](#F3)

**Why this matters:** SEW (+12% LiveCodeBench) shows that evolving the workflow topology itself outperforms just evolving rules. Our system evolves what we do (rules/SOPs) but not how we sequence tasks.

**Proposed change:** After a multi-step task completes, analyze the execution sequence — tool order, verification timing, archive routing decisions — and compare against a "workflow template" library. If a different sequence would have been more efficient, generate a workflow optimization proposal. Templates stored at `archive/evolution/workflows/`.

**Files involved:**
- `archive/evolution/README.md` — Add Workflow Auto-Optimization section
- `archive/evolution/workflows/` — New directory for workflow templates
- `archive/evolution/logs/` — Log schema may need a `workflow_sequence` field

**Steps:**
- [ ] Step 1: Create `archive/evolution/workflows/` directory with initial template schema
- [ ] Step 2: Add `workflow_sequence` capture to experience log schema (tool order + timing)
- [ ] Step 3: Add post-task workflow analysis step (compare actual vs template)
- [ ] Step 4: Add workflow optimization proposal trigger (consistent deviation from best template)
- [ ] Step 5: Validate — run a multi-step task, verify workflow sequence is captured and analyzed
