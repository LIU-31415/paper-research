# Tool Config

`tags: #tools #config`

_工具配置、环境搭建、软件设置归档于此。新内容置顶。_

---

## 2026-05-03: GitHub CLI (gh) Setup on Windows

`tags: #github #gh-cli #setup #windows`

**结论：** 在 Git Bash (MINGW64) 环境下通过 winget 安装 gh CLI v2.92.0 并完成 GitHub 认证（账号 LIU-31415）。

### 要点

- winget 将 gh.exe 装到 `C:\Program Files\GitHub CLI\`，不在 MINGW64 默认 PATH 内，需在 `~/.bashrc` 中 `export PATH="$PATH:/c/Program Files/GitHub CLI"`
- 认证用 `gh auth login -w`（web device flow），token 存 Windows keyring，持久化不丢失
- 未安装 gh 时 curl 调 GitHub API 是等价替代方案

→ 相关：[Session](../../archive/sessions/2026-05-03_gh-CLI-Setup.md)

---

## 2026-05-02: AI Agent Memory System

`tags: #archive #memory #claude-code`

**结论：** 在 Claude Code 中建立分层记忆系统，通过在 CLAUDE.md 中定义规则 + 文件系统组织 + MCP 知识图谱实现知识复利。

### 文件结构

```text
agent/
├── CLAUDE.md              ← 用户画像 + 归档规则（始终注入）
├── archive/
│   ├── INDEX.md           ← 索引目录
│   ├── topics/            ← 主题知识库（按任务类型定向加载）
│   │   ├── Research-Notes.md
│   │   ├── Writing-Outputs.md
│   │   ├── Tech-Solutions.md
│   │   └── Tool-Config.md
│   └── sessions/          ← 会话时间轴（仅显式查询）
└── .vscode/settings.json
```

### 核心规则

- 按任务类型路由：写作只读 Writing-Outputs，技术只读 Tech-Solutions + Tool-Config
- 混合归档：AI 自动存档 + 用户说"记一下"手动触发
- 去重：写入前检查已有内容，仅新内容写入
- 冲突：新旧矛盾时提示用户确认，不静默覆盖

→ 相关：[CLAUDE.md](../../CLAUDE.md) · [Session](../../archive/sessions/2026-05-02_Archive-System-Setup.md)

---

## 2026-05-03: MCP 学术检索服务配置 (Semantic Scholar + arXiv)

`tags: #mcp #semantic-scholar #arxiv #literature-search #research`

**结论：** 在项目 `.mcp.json` 中配置两个学术 MCP 服务，授权后可在文献调研中直接调用，替代通用 WebSearch 做论文检索。

### 配置清单

- **Semantic Scholar MCP** (`uvx semantic-scholar-mcp`) — 全学科论文搜索、引用网络、24 个工具
- **arXiv MCP** (`npx @futurelab-studio/latest-science-mcp`) — 材料物理预印本搜索
- **WebSearch/WebFetch 保留** — 三路并发，不做替换

### 文件变更

| 文件 | 操作 |
|------|------|
| `.mcp.json`（新建） | 定义两个 MCP 服务 |
| `.claude/settings.local.json` | 加入 `enabledMcpjsonServers` 白名单 |
| `archive/references/Literature-MultiAgent-Workflow.md` | v0.3 更新 Phase 1 |

→ 工作流：[Literature-MultiAgent-Workflow.md](../references/Literature-MultiAgent-Workflow.md)
→ 配置：[.mcp.json](../../.mcp.json)

`tags: #archive #enhancement #mcp #staleness`

**结论：** 针对四层记忆架构的三个薄弱环节做了加固：添加 Task Disambiguation 避免路由误判、引入 `[last-reviewed]` 机制处理知识过期、创建 MCP-Setup.md 让 Layer 2 可落地。

### 变更清单

- **CLAUDE.md**: 新增 Task Disambiguation 节（模糊任务先问用户再路由）；Dedup 规则加入过期检查（>6个月提示 review）；Format Rules 加入 staleness 格式要求；新增 External References 节指向 MCP 和引用文档
- **INDEX.md**: 增加 `Recent Entries` 子表追踪各 topic 最新条目；Sessions/References 改为表格结构
- **MCP-Setup.md**（新建）: Memory Server 配置方法 + 与 Archive 的关系对比表

→ 相关：[CLAUDE.md](../../CLAUDE.md) · [MCP-Setup.md](../../archive/references/MCP-Setup.md) · [INDEX.md](../../archive/INDEX.md)
