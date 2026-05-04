# Archive System Rules

> Centralized archive rules — extracted from CLAUDE.md for maintainability.
> CLAUDE.md references this file via short routing index.

---

## Topic Routing Rules

Load topic files by task type — never load irrelevant content:

| Task Type | Files to Load | Don't Load |
|-----------|--------------|------------|
| Writing | `archive/topics/Writing-Outputs.md`, (+ `Research-Notes.md` if needed) | Tech-Solutions.md, Tool-Config.md |
| Research | `archive/topics/Research-Notes.md` | Writing, Tech, Tool |
| Tech/Coding | `archive/topics/Tech-Solutions.md` + `archive/topics/Tool-Config.md` | Research, Writing |
| Mixed (e.g. "write a paper about X tech") | Read `archive/INDEX.md` first (~0.5K) to decide | — |
| Unknown | Read `archive/INDEX.md` first | — |
| Full knowledge (user says "based on all my knowledge") | Load ALL topics | — |

## Task Disambiguation

When task type is ambiguous (e.g., contains both tech and research elements):

1. Ask user to clarify: "这是技术实现还是调研方向？还是两者都有？"
2. If user confirms mixed → follow Mixed routing rule
3. Only route after user confirmation — never guess

## Auto-Archive Triggers

- Research completed → write to `archive/topics/Research-Notes.md`
- Research output produced → save full deliverable to `archive/outputs/YYYY-MM-DD_Topic.md`
- Writing output produced → write to `archive/topics/Writing-Outputs.md`
- Tech problem solved → write to `archive/topics/Tech-Solutions.md`
- Tool/config setup → write to `archive/topics/Tool-Config.md`
- Session summary → write to `archive/sessions/YYYY-MM-DD_Title.md`
- User says "记一下" / "这个存档" / "save this" → manual trigger
- **Any complete deliverable regardless of type** → save to `archive/outputs/YYYY-MM-DD_Topic.md` **in addition to** the topic-specific file above

## Archive Structure

```
archive/
├── INDEX.md          ← 索引（始终加载）
├── RULES.md          ← 本文件，存档规则
├── topics/           ← 知识提炼（结论、模型、空白）
├── outputs/          ← 调研结果、工作流完整交付件
├── sessions/         ← 操作流水账
└── references/       ← 参考文档、工作流定义
```

## Dedup & Conflict Rules

- Before writing, read existing content in the target topic file
- Only write NEW content — skip duplicates
- If new content is more precise → update/improve existing entry
- If new content CONTRADICTS existing → ask user to confirm, never silently overwrite
- If user confirms/verifies existing conclusion → add `[verified]` mark
- **Staleness check**: if modifying a topic file, scan entries older than 6 months → prompt user with `[last-reviewed: YYYY-MM-DD]`; if confirmed valid, update stamp; if outdated, mark `[deprecated: YYYY-MM-DD]` and add new entry

## Knowledge Graph Rules

- New project/technology → create Entity + Observations
- Dependency/connection between known entities → create Relation
- Information conflict → prompt user to confirm

## Adversarial Pre-Write Check

Before writing any archive entry, run a lightweight adversarial check:

1. **Contradiction scan:** grep existing topic entries for contradictory claims. If found → prompt user to confirm, never silently overwrite
2. **Redundancy check:** grep for semantic duplicates. If the same conclusion exists → skip write (or improve existing)
3. **Severity check:** is this entry a material new finding or a minor detail? Minor details don't get standalone entries — append as bullet to relevant existing entry

## Format Rules

- Title: `YYYY-MM-DD: Short English Title`
- Tags: `#tag1 #tag2`
- Content: One-sentence conclusion first, then 3-5 bullet points
- Keep minimal — only reusable conclusions
- Staleness: entries older than 6 months get a `[last-reviewed: YYYY-MM-DD]` stamp; deprecated entries get `[deprecated: YYYY-MM-DD]`
- Always update `archive/INDEX.md` after changes
- MCP server setup → see `archive/references/MCP-Setup.md`
- External references → see `archive/references/README.md`
- Self-evolution system → see `archive/evolution/README.md`

## Topic Sharding Rule

When a topic file exceeds **120 lines**, split by sub-theme:

1. **Split**: extract topically cohesive entry groups into new files: `Topic-Subtheme.md`
2. **Cross-ref**: leave a redirect note at the original location: `→ 2025+ PFAS entries moved to [Research-PFAS.md](Research-PFAS.md)`
3. **Index**: update `archive/INDEX.md` with new file entries
4. **Threshold**: don't wait till 200+ lines — proactive split at 120 keeps Read costs low
