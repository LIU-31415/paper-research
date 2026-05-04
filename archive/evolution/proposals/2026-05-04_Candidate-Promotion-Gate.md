# Proposal: Candidate→Promotion Gate for Pattern Rules

> **Status:** ⏳ Pending Approval
> **Source:** [scan-2026-05-04](#F1)

**Why this matters:** Our patterns go count>=3 → direct auto-patch with no intermediate validation. Bugbot shows candidate→promotion gating with live validation gives 78% resolution rate.

**Proposed change:** Add a "candidate" status between pattern detection and auto-patch. When pattern count reaches 2, mark it as candidate. Candidates get annotated in a tracking list but don't trigger auto-patch until count reaches 3 AND a confidence check passes. Add auto-disable on negative signal (user reverses or corrects the patch).

**Files involved:**
- `archive/evolution/README.md` — Add Candidate Gate section to pattern detection rules
- `archive/evolution/patterns/` — Add candidate pattern status (frontmatter field)
- `CLAUDE.md` — Reference candidate gate in Self-Evolution Protocol

**Steps:**
- [ ] Step 1: Add `status: {candidate|active|disabled}` to pattern file frontmatter schema
- [ ] Step 2: Update Auto-Patch Rules to check for active status before triggering
- [ ] Step 3: Add candidate→active promotion criteria (count >= 3 + no user negative sentiment)
- [ ] Step 4: Add auto-disable rule (user reverses patch → mark as disabled)
- [ ] Step 5: Validate — simulate a pattern flow through all states
