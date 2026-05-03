# Archive Memory System Initialization

type: tech/archive
generated: 2026-05-03
updated: 2026-05-03
source_logs: [archive/sessions/2026-05-02_Archive-System-Setup.md, archive/sessions/2026-05-02_Architecture-Hardening-And-UI-Discussion.md]

## Step Sequence

1. **Phase 1: Define Architecture**
   - Choose memory layers: CLAUDE.md (always-injected) + topics (demand-loaded) + MCP KG (semantic) + sessions (query-only)
   - Define token budget per layer (total 4-9K target)
   - Document in PRD.md before coding

2. **Phase 2: Create CLAUDE.md**
   - Write user profile (name, role, domain, languages, tools)
   - Define topic routing rules table: task type → files to load / don't load
   - Define auto-archive triggers (research/writing/tech done → write to topics)
   - Define dedup & conflict rules
   - Define format rules

3. **Phase 3: Create Directory Structure**
   - `archive/INDEX.md` — master index
   - `archive/topics/{Research,Writing,Tech,Tool}-*.md` — one per domain, with tags frontmatter
   - `archive/sessions/` — chronological session archives
   - `archive/outputs/` — full deliverables
   - `archive/references/` — config docs, external links

4. **Phase 4: Wire Up MCP (optional)**
   - Configure `.mcp.json` with memory server
   - Optionally add domain-specific MCPs (Semantic Scholar, arXiv)
   - Register in `.claude/settings.local.json`

5. **Phase 5: First Archive Entry**
   - Write a session file for the current setup session
   - Write a topic entry summarizing the system
   - Update INDEX.md

## Tool Checklist

- `Write`: Create all archive files
- `Edit`: Update existing files
- `mcp__memory__*`: Create entities and relations for KG

## Success Criteria

- [ ] CLAUDE.md contains complete user profile + routing rules
- [ ] All 4 topic files exist with proper format
- [ ] INDEX.md references all files
- [ ] At least 1 session entry written
- [ ] Task routing works: tech task loads Tech-Solutions only, research loads Research-Notes only

## Common Pitfalls

- Token budget creep: topics grow too large → periodic pruning needed (keep last 20 entries)
  → Prevention: Staleness check at 6 months, mark deprecated entries
- Routing confusion on mixed tasks
  → Prevention: Task Disambiguation rule — ask user before guessing
