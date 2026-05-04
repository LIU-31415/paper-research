# Proposal: Archive Evolution — Pattern/SOP Mutation

> **Status:** ⏳ Pending Approval
> **Source:** [scan-2026-05-04](#F2)

**Why this matters:** Darwin Godel Machine (81 citations, 20%→50% SWE-bench) shows that maintaining an archive of agents and sampling+mutation produces rapid improvement. Our pattern/SOP archive is passive — stored but never recombined.

**Proposed change:** Add a periodic "mutation pass" over the pattern and SOP archive. At each drift checkpoint (or manual trigger), sample 2 existing patterns/SOPs and attempt a crossover or refinement: merge their prevention rules, try a combined approach, or simplify. Validated mutations get promoted to new SOP candidates.

**Files involved:**
- `archive/evolution/README.md` — Add Pattern/SOP Mutation section
- `archive/evolution/patterns/` — Add mutation meta field to track derivation lineage
- Reference: `archive/evolution/sops/` — mutated SOPs get distinct version markers

**Steps:**
- [ ] Step 1: Define mutation schema — which fields can mutate (prevention, winning_approach, task_types)
- [ ] Step 2: Add mutation trigger at drift checkpoint (every checkpoint run 1 mutation)
- [ ] Step 3: Add mutation validation rule (new variant must pass >=2 test scenarios)
- [ ] Step 4: Add lineage tracking (which pattern/SOP was the parent)
- [ ] Step 5: Verify — run a manual mutation on 2 existing patterns, check output quality
