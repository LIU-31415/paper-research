# Personal AI Agent Profile

## User Profile

- **Name:** 超哥 (address as 超哥)
- **Role:** User of this AI agent system
- **Domain:** Knowledge work, research, writing, development
- **Languages:** Chinese (native), English (academic/technical)
- **Tools:** Claude Code, VSCode

## Workflow Preferences
- Interaction: Concise, result-oriented
- Output: Chinese-English mixed, English for tags/filenames, Chinese for detailed content
- Archive: Only record essential conclusions, not full conversation

## Archive System Rules

### Topic Routing Rules
Load topic files by task type — never load irrelevant content:

| Task Type | Files to Load | Don't Load |
|-----------|--------------|------------|
| Writing | `archive/topics/Writing-Outputs.md`, (+ `Research-Notes.md` if needed) | Tech-Solutions.md, Tool-Config.md |
| Research | `archive/topics/Research-Notes.md` | Writing, Tech, Tool |
| Tech/Coding | `archive/topics/Tech-Solutions.md` + `archive/topics/Tool-Config.md` | Research, Writing |
| Mixed (e.g. "write a paper about X tech") | Read `archive/INDEX.md` first (~0.5K) to decide | — |
| Unknown | Read `archive/INDEX.md` first | — |
| Full knowledge (user says "based on all my knowledge") | Load ALL topics | — |

### Task Disambiguation

When task type is ambiguous (e.g., contains both tech and research elements):

1. Ask user to clarify: "这是技术实现还是调研方向？还是两者都有？"
2. If user confirms mixed → follow Mixed routing rule
3. Only route after user confirmation — never guess

### Auto-Archive Triggers (Mixed Mode)
- Research completed → write to `archive/topics/Research-Notes.md`
- Research output produced → save full deliverable to `archive/outputs/YYYY-MM-DD_Topic.md`
- Writing output produced → write to `archive/topics/Writing-Outputs.md`
- Tech problem solved → write to `archive/topics/Tech-Solutions.md`
- Tool/config setup → write to `archive/topics/Tool-Config.md`
- Session summary → write to `archive/sessions/YYYY-MM-DD_Title.md`
- User says "记一下" / "这个存档" / "save this" → manual trigger

### Archive Structure

```text
archive/
├── INDEX.md          ← 索引（始终加载）
├── topics/           ← 知识提炼（结论、模型、空白）
├── outputs/          ← 调研结果、工作流完整交付件
├── sessions/         ← 操作流水账
└── references/       ← 参考文档、工作流定义
```

### Dedup & Conflict Rules
- Before writing, read existing content in the target topic file
- Only write NEW content — skip duplicates
- If new content is more precise → update/improve existing entry
- If new content CONTRADICTS existing → ask user to confirm, never silently overwrite
- If user confirms/verifies existing conclusion → add `[verified]` mark
- **Staleness check**: if modifying a topic file, scan entries older than 6 months → prompt user with `[last-reviewed: YYYY-MM-DD]`; if confirmed valid, update stamp; if outdated, mark `[deprecated: YYYY-MM-DD]` and add new entry

### Knowledge Graph Rules
- New project/technology → create Entity + Observations
- Dependency/connection between known entities → create Relation
- Information conflict → prompt user to confirm

### Format Rules
- Title: `YYYY-MM-DD: Short English Title`
- Tags: `#tag1 #tag2`
- Content: One-sentence conclusion first, then 3-5 bullet points
- Keep minimal — only reusable conclusions
- Staleness: entries older than 6 months get a `[last-reviewed: YYYY-MM-DD]` stamp; deprecated entries get `[deprecated: YYYY-MM-DD]`
- Always update `archive/INDEX.md` after changes
- MCP server setup → see `archive/references/MCP-Setup.md`
- External references → see `archive/references/README.md`
- Self-evolution system → see `archive/evolution/README.md`

---

### Self-Evolution Protocol (Phase 1 — Experience Log + Auto-Patch)

At the end of each **non-trivial task** (anything beyond a single file edit):

1. Write one experience log entry to `archive/evolution/logs/YYYY-MM-DD_HHMM_ShortTitle.md`
2. Follow the schema in `archive/evolution/README.md` — capture `outcome`, `error_signal`, `root_cause`
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
