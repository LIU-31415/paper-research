# v4.0 P1规则历史快照

状态：historical，非现行执行规则。现行规则见 [研究执行门槛](../protocols/research-gates.md)。

保存2026-10-12修复前受影响文件的完整文本（仅规范换行和行尾空白），便于追溯；不覆盖已有历史版本。

## SKILL.md

````text
name: paper-research
description: >
  Use when the user wants to research a topic, search for papers, fact-check, or
  synthesize information — especially Chinese "研究一下", "帮我调研", "查资料",
  "查一下", "搜索", "调研", "深度研究", "文献搜索", "论文调研", "这个结论可靠吗",
  "帮我查", "引导我的研究", "查文献", or English "research", "literature review",
  "what's the latest on". Two modes: Quick for fast answers (5min), Deep for
  systematic academic research with full APA reports. SKIP only for simple file
  lookups. This is the PRIMARY handler for ANY research/lookup/fact-check task.
---

# Research Protocol

> **Source of truth for all search/research workflows.** 主入口，根据用户需求自动路由到对应模式。

`version: v4.0 | created: 2026-05-04 | updated: 2026-06-05 | status: active`

---

## Mode Selection

> 搜索任务跨度很大——从"查一个事实"到"产出 APA 7.0 系统综述"。一种流程无法适配所有场景。Quick Mode 轻量快速（多源并行搜索+5分钟合成），Deep Mode 提供完整的学术质量保障（6 阶段管线+并行评审）。

| 用户意图 | 模式 | 加载文档 |
|---------|------|---------|
| 快速查询 / 事实核查 / 简单搜索 | **Quick Mode** | → 读取 `protocols/quick-mode.md` |
| 深度研究 / 系统综述 / 论文调研 | **Deep Mode** | → 读取 `protocols/deep-mode.md` |

**不确定？** 先走 Quick。如果结果需要深挖，在 Step 7 建议切换到 Deep。

---

## Mode Routing

协议文件采用按需加载（渐进式披露）——不同模式只加载自己需要的文档，避免上下文过载。

1. **判断模式**：根据 Mode Selection 表判断用户意图

2. **加载协议**：
   - 判断为 **Quick** → 立即 Read `skills/paper-research/protocols/quick-mode.md`，严格遵循 Step 1-8
   - 判断为 **Deep** → 立即 Read `skills/paper-research/protocols/deep-mode.md`，严格遵循 Phase 1-6

3. **执行过程中按需加载跨模式协议**：
   - 获取到文献全文且满足条件时 → Read `skills/paper-research/protocols/hierarchical-reading.md`
   - 收集到 sub-agent claim-table 后 → Read `skills/paper-research/protocols/verification.md`
   - 合成/报告完成后，最终输出前 → Read `skills/paper-research/protocols/verification.md`

4. **铁律**：
   - 任何情况下不跳过协议步骤
   - 不做 vibe citing，每条引用独立验证
   - 每步完成后确认启动条件和完成清单

---

## 极简搜索（无需加载子文档）

处理"查一个事实/快速验证"等简单任务时，可以不加载 `quick-mode.md`，直接执行以下精简流程：

```
用户查询 → 并行 WebSearch(1-2 queries) → WebFetch top 3 → 交叉比对 → 输出结果
```

**适用条件**：用户问题不需要学术文献、不涉及多源 cross-validation、不需要长篇合成。
**不适用**：任何涉及"研究/综述/论文/文献/可靠性验证"的请求 → 必须走完整 Mode Routing 加载子文档。

---

## Protocol Index

| 文件 | 内容 | 何时加载 |
|------|------|---------|
| `protocols/quick-mode.md` | Quick Mode 完整 Step 1-8 | 选择 Quick 时立即 Read |
| `protocols/deep-mode.md` | Deep Mode 完整 Phase 1-6 + Socratic + Anti-Patterns | 选择 Deep 时立即 Read |
| `protocols/hierarchical-reading.md` | 分层阅读 4 步 + Sub-agent 并行分发 | 获取文献全文且满足触发条件时 |
| `protocols/verification.md` | 统一验证：data 模式（核对）+ report 模式（审查） | 收集到 sub-agent claim-table 后（data）或合成完成后（report） |
| `protocols/source-reliability.md` | 源可靠性矩阵 + Session-Log 格式（跨会话学习） | Session 结束时（Quick Step 9 / Deep Phase 6 后） |
| `agents/literature-reader.md` | Sub-agent 分层阅读分派模板 | 文献数 ≥ 2 时分层阅读 |
| `agents/bibliography-agent.md` | Bibliography 搜索扇出规范 | Deep Mode Phase 2 搜索 |

---

## 变量映射

> 所有子协议文件 (protocols/) 中使用的目录前缀变量集中定义于此。子文件中的硬编码目录名应与本表保持一致。

| 变量 | Quick Mode 值 | Deep Mode 值 | 用途 |
|------|:-----------:|:-----------:|------|
| `{research-topic}` | *(由查询关键词确定)* | *(由 RQ Brief 确定)* | 项目根目录下的唯一目录名（英文短横线格式） |
| `{mode_prefix}` | `01-` | `02-` | investigation 目录前缀 |
| `{ana_prefix}` | `02-` | `03-` | analysis 目录前缀 |
| `{report_prefix}` | `03-` | `06-` | 最终报告目录前缀 |

**完整性示例（Quick Mode）**：
```
{research-topic} = "fe3o4-heterostructure-review"
{research-topic}/01-investigation/       (mode_prefix=01-)
{research-topic}/02-analysis/            (ana_prefix=02-)
{research-topic}/03-report/              (report_prefix=03-)
```

**跨模式切换映射**：从 Quick 切换到 Deep 时，`01-` 目录前缀不变（可复用已有 investigation），但 `02-`（analysis）在 Deep 中对应 `03-`。切换时需创建 Deep Mode 缺失目录（`01-scoping/`, `04-composition/`, `05-review/`, `06-report/`），**不重命名已有目录**。

### 变量定义（子文件参考）

- `protocols/hierarchical-reading.md` 定义了 `{mode_prefix}` 和 `{ana_prefix}` 的具体取值
- `protocols/verification.md` 定义了 `{mode_prefix}` 和 `{ana_prefix}` 及原文回溯路径

---

## Version History

| Date | Version | Change |
|:---|:---|:---|
| 2026-06-05 | **v4.0** | 语义重构：references/ → protocols/；合并 CrossSource+Content → verification.md；kebab-case 命名；Agent 模板提取到 agents/；最小可行流程；三视角审查修复 |
| 2026-06-04 | v2.8 | Dynamic Workflows 并行拓扑 + Phase 2/5 扇出-验证-归并三原则 |
| 2026-06-04 | v2.7 | Quick Mode: add Step 1.5 WebSearch-first refinement, Keyword Engineering, Fan-Out Search, Chinese paper fallback; Deep Mode: Phase 2 search dispatch spec |
| 2026-05-27 | v2.6 | 移除 Google Scholar，简化为 WebSearch + OpenAlex + Semantic Scholar |
| 2026-05-27 | v2.5 | 加入 OpenAlex 作为并行补充源 |
| 2026-05-27 | v2.4 | Google Scholar 改为 WebSearch 间接查询 |
| 2026-05-27 | v2.3 | Add Semantic Scholar rate limit rule: ≥1s interval |
| 2026-05-23 | v2.2 | Sub-agent parallel hierarchical reading + multi-agent cross-validation |
| 2026-05-22 | v2.1 | Add hierarchical reading + content verification |
| 2026-05-07 | v2.0 | Merged deep-research (13-agent academic pipeline) as Deep Mode |
| 2026-05-05 | v1.5 | Remove arXiv/OpenAlex/PubMed, unify Semantic Scholar |
| 2026-05-04 | v1.4-1.0 | Initial iterations |


````

## README.md

````text
# paper-research

> Claude Code Skill — 多源搜索与结构化学术研究协议

`v4.0 | 2026-06-05 | active`

---

## 一句话简介

**paper-research** 是 Claude Code 的搜索与研究 skill，覆盖从"快速查一个事实"到"系统研究一个课题"的完整需求。主入口 [SKILL.md](SKILL.md) 负责智能路由，自动加载对应模式文档。

---

## ⚠️ 使用前提（必读）

> **本 Skill 依赖 Claude Code 的 MCP（Model Context Protocol）生态。以下条件不满足则无法正常运行。**

### 所需环境

| 组件 | 来源 | 说明 |
|------|------|------|
| **Claude Code** | [安装指南](https://docs.anthropic.com/en/docs/claude-code) | 运行本 Skill 的 CLI 环境 |
| **WebSearch / WebFetch** | Claude Code **内置** | 无需额外配置，开箱即用 |
| **Semantic Scholar MCP** | 需在 `.mcp.json` 中配置 | 学术搜索核心依赖，需 [API Key](https://api.semanticscholar.org/)（免费） |
| **context7 MCP** | 需在 `.mcp.json` 中配置 | 技术文档查询（框架/库/SDK），非必需但建议配 |

### Semantic Scholar MCP 配置示例

在项目根目录（或 `~/.claude/`）的 `.mcp.json` 中添加：

```json
{
  "mcpServers": {
    "semantic-scholar": {
      "command": "npx",
      "args": ["@semantic-scholar/mcp-server"],
      "env": {
        "S2_API_KEY": "你的 API Key"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"]
    }
  }
}
```

> 🔑 Semantic Scholar API Key 免费申请：[https://api.semanticscholar.org/](https://api.semanticscholar.org/)

### 使用约定

执行过程中会在当前工作目录下创建以研究主题命名的文件夹存放产出物（如 `fe3o4-heterostructure-review/01-investigation/`），请确保有写入权限。

---

## 两种模式

| 模式 | 场景 | 输出 |
|------|------|------|
| **Quick** | 查事实、概览、验证 | Research Brief（500-1500字） |
| **Deep** | 系统研究、文献综述、学术报告 | APA 7.0 报告（3000-8000字） |

两种模式共享同等级可靠性：Sub-agent 并行分层阅读、原文下载、位置索引、claim 提取、多 Agent 信息核对。

---

## 快速开始

### 触发词

说 `研究一下` `帮我调研` `查资料` `查一下` `搜索` `调研` `深度研究` `文献搜索` `论文调研` `这个结论可靠吗` `查文献` 等即可自动触发。

### Quick 示例
```
"帮我查一下 Fe₃O₄ 交换偏置效应最新研究进展"
```

### Deep 示例
```
"系统调研 Fe₃O₄/α-Fe₂O₃ 异质结构的合成方法与磁性能，出 APA 报告"
```

---

## 协议体系

| 文件 | 说明 |
|------|------|
| [SKILL.md](SKILL.md) | **主入口** — Mode Selection + 路由 + Protocol Index（~80行） |
| [protocols/quick-mode.md](protocols/quick-mode.md) | Quick Mode 完整 Step 1-8（含 Keyword Engineering、Fan-Out、Tool Preloading） |
| [protocols/deep-mode.md](protocols/deep-mode.md) | Deep Mode 完整 Phase 1-6 + Socratic、Anti-Patterns、Operational Modes |
| [protocols/hierarchical-reading.md](protocols/hierarchical-reading.md) | 分层阅读 + Sub-agent 并行分发（跨模式共享） |
| [protocols/verification.md](protocols/verification.md) | 统一验证协议：data 模式（数据级核对）+ report 模式（报告级审查） |
| [agents/literature-reader.md](agents/literature-reader.md) | Sub-agent 分层阅读分派模板 |
| [agents/bibliography-agent.md](agents/bibliography-agent.md) | Bibliography 搜索扇出规范 |

**路由机制**：SKILL.md 根据用户意图自动判断 Quick/Deep → Read 对应子文档 → 按需加载跨模式协议。详见 [SKILL.md > Mode Routing](SKILL.md#mode-routing--必须遵循)。

---

## 版本历史

| Date | Version | Change |
|:---|:---|:---|
| 2026-06-05 | **v3.0** | 文档拆分重构：SKILL.md 仅保留路由；Quick/Deep 拆为独立子文档；跨模式协议独立文件化 |
| 2026-06-04 | **v2.8** | Dynamic Workflows 并行拓扑 + P0-P4 修复（description 优化、启动条件、检查清单、规则索引） |
| 2026-05-23 | **v2.2** | Sub-agent 并行分层阅读 + 多 Agent 信息核对 + 原文位置索引 |

完整历史见 [SKILL.md](SKILL.md#version-history)。

````

## protocols/quick-mode.md

````text
# Quick Mode — 快速调研协议

> Quick multi-source search & synthesis protocol for fast, reliable answers.
> Part of `paper-research` skill — loaded by `skills/paper-research/SKILL.md` when Quick Mode is selected.

`version: v3.0 | created: 2026-05-04 | updated: 2026-06-05 | status: active`

---

## Core Mechanism

```
Single Query
    │
    ├→ Query Expansion (1 question → 3-5 variants)
    │
    ├→ Parallel Search
    │   ├─ WebSearch (general)
    │   ├─ Semantic Scholar            [if academic]
    │   └─ OpenAlex (WebFetch)         [if academic, 与 Semantic Scholar 并行]
    │
    ├→ Content Fetching (top 3-5 results per source)
    │   │
    │   └→ 获取全文 → 文献数 ≥ 2?
    │       ├─ Yes → Sub-agent 并行分层阅读 → 多 Agent 信息核对
    │       └─ No  → 单线分层阅读
    │
    ├→ Cross-Validation
    │   ├─ 整合多 Agent 核对报告（如有）
    │   ├─ Multi-source consensus → adopt
    │   ├─ Conflict → authority > recency > volume
    │   ├─ Single source → downgrade, note limitation
    │   └─ No source → state no direct evidence
    │
    ├→ Synthesis
    │   ├─ Multi-source merge + dedup
    │   ├─ 3-5 key insights
    │   └─ Source list appended at end
    │
    └→ Follow-up (3 suggestions for deeper dive)
```

> **Note**: The diagram reflects the high-level flow. Before executing, verify MCP tools are loaded (see Tool Preloading Check in Step 1.5).

### Quick Mode Steps Overview

| Step | 启动条件 | 产出物 |
|------|---------|--------|
| **Step 1** 查询扩展 + 目录 | 用户发起研究请求 | 3 个查询变体 + 目录树 |
| **Step 1.5** WebSearch 精化后置 | Step 2 结果 <5 条 + 自然语言查询 | 精化搜索词（追加到已有结果） |
| **Step 2** 并行搜索 | Step 1.5 完成 | 搜索结果汇总 (top 12-15) |
| **Step 3** 内容获取 | 搜索结果就绪 | `search-results.md` + 分层阅读产物 |
| **Step 4** 交叉验证 | Content Fetching 完成 | 置信度判定 + 局限性标注 |
| **Step 5** 合成 | Cross-Validation 完成 | 3-5 核心要点 |
| **Step 6** 内容审查 | Step 5 完成 + 涉及文献阅读 | `content-verification-report.md` |
| **Step 7** 后续建议 | Step 6 完成 | 3 个 follow-up 方向 |
| **Step 8** 最终输出 | 全部前置完成 | `synthesis-notes.md` + `research-brief.md` |

### Rules Index

| 规则区域 | 位置 | 核心内容 |
|---------|------|---------|
| 源选择规则 | Step 1 Rules | 非学术→WebSearch only；学术→+ MCP；混合→all |
| Keyword Engineering | Step 1 | 5 条协议：分解→操作符→结果量反馈→中英归一→反模式 |
| 后置精化规则 | Step 1.5 Execution Rules | 学术源<5条时 WebSearch 后置探查；Quick 模式下非前置，只在不足时触发 |
| 工具预加载 | Step 1.5 Tool Preloading Check | 所有 MCP 工具必须先 ToolSearch 后使用 |
| 并行规则 | Step 2 Parallel Rules | 并发调用；SS 间隔≥1s；源失败降级 |
| 扇出调度 | Step 2 Fan-Out Search | ≥3 变体扇出；每轮≤4 sub-agent；返回契约 JSON |
| 中文回退 | Step 3 Chinese Paper Fallback | 4 步回退 + 4 条规则 |
| 多 Agent 核对 | `verification.md` | 4 步：归并→比对→裁决→报告 |
| 内容审查 | `verification.md` | Claim 级交叉验证 + 引用真实性检查 |

## Step 1: Query Expansion & 创建目录

> **启动条件**：用户发起研究/搜索请求

**Expand user query into 3 search variants** covering different angles:

| Dimension | Strategy | Example |
|-----------|----------|---------|
| Language | Chinese + English | "AI agents impact jobs" / "AI 智能体 就业影响" |
| Perspective | Academic + Industry | "deep learning scaling laws" / "AI industry trends 2026" |
| Counterpoint | Negative/limiting condition | "AI automation job displacement concerns" |

**同时**：根据查询关键词确定 `{research-topic}` 目录名（英文短横线格式），创建 `{research-topic}/` 目录树骨架，作为后续所有中间产物的落盘位置。

```
{research-topic}/
├── 01-investigation/
│   ├── search-results.md        ← 搜索结果汇总 + 来源评估
│   └── literature/              ← 仅获取全文时创建
├── 02-analysis/
│   ├── cross-validation-report.md  ← 多 Agent 核对报告
│   └── synthesis-notes.md         ← 核心发现 + 源要点
└── 03-report/
    └── research-brief.md          ← 最终研究简报
```

**Rules:**
- Non-academic → WebSearch only
- Academic → WebSearch + 1-2 academic MCPs in parallel
- Mixed → all sources

### Keyword Engineering for Precision

**Problem**: Broad natural-language queries on Semantic Scholar return thousands of irrelevant results, burying the signal.

**Protocol — before dispatching any academic API query**:

1. **Decompose** the user's question into atomic domain terms:
   - Bad: `"advanced oxidation processes halogenated organic compounds"` (vague, 5 concepts flat)
   - Good: `"advanced oxidation" "halogenated" degradation kinetics` (phrase-quoted core concepts)

2. **Use operators, not natural language**:
   - Correct: `"UV/H2O2" "chlorinated" degradation`
   - Wrong: `"What is the effect of UV/H2O2 on chlorinated compounds?"`

3. **Check result volume** as a feedback signal:
   - >200 results → refine by adding a specific compound or constraining by year
   - <5 results → loosen by removing the most specific term

4. **Chinese-English term normalization**:
   - WebSearch 中文关键词 → 提取标准英文领域术语 → SS 用确认后的英文关键词查询
   - 保留中英文双语言变体

5. **Anti-pattern register**:
   - 照搬用户的自然语言问题直接搜 SS
   - 遗漏领域缩写（PFAS, VOCs, AOPs 等）

> **完成清单**：
> - [ ] 3 个查询变体已生成（语言/视角/反方）
> - [ ] `{research-topic}/` 目录树已创建
> - [ ] 关键词已工程化（如果用于学术查询）
>
> **产出物**：3 个查询变体字符串 + `{research-topic}/` 目录树骨架

## Step 1.5: WebSearch 精化后置（Refinement Fallback）

> **此步骤不再是前置步骤**——改为结果不足时的补救路径。常规流程：Step 1 Keyword Engineering → Step 2 搜索，结果充足则跳过本步骤。
> **触发条件**：Step 2 完成后，学术源返回 < 5 条 且用户查询为自然语言
> **跳过条件**：Step 2 已返回 ≥5 条 / 用户查询已是精确学术关键词

Before dispatching searches to academic APIs (Semantic Scholar, OpenAlex), run a brief WebSearch pass to discover the precise keywords used in peer-reviewed literature for this topic.

### Rationale

Academic APIs match on keywords, not meaning. A broad concept like "advanced oxidation processes halogenated organic compounds" produces noise because each term is common in isolation. WebSearch results reveal the exact phrasing the field uses, which can then be fed as precise queries to the academic APIs.

### Post-Search Refinement Flow

```
Query Variants (from Step 1)
    │
    ├→ [Step 1.5a] WebSearch (2-3 quick landscape queries)
    │   │  Use ToolSearch("select:WebSearch") first
    │   │
    │   └→ Extract from results:
    │       ├─ Standard acronyms: AOP, PFAS, VOCs, TCE, etc.
    │       ├─ Specific method names: UV/H2O2, Fenton, photocatalysis
    │       ├─ Known review article titles (contain canonical keywords)
    │       └─ Common compound names
    │
    ├→ [Step 1.5b] Keyword Engineering (apply rules above)
    │   └→ Reformulate all search queries using extracted terms
    │
    └→ [Step 2] Academic API Search
        └→ Semantic Scholar + OpenAlex with the reformulated queries
```

### Execution Rules

1. **Always WebSearch first** when the user's query uses natural language
2. **2-3 WebSearch queries max** — enough to identify field vocabulary
3. **Queries are quick** — 30-60 seconds; do not deep-read any single result at this stage
4. **Output**: 3 refined search strings using extracted terminology, ready for Step 2

### Chinese-Language Topics

When the research topic originates in Chinese:
- WebSearch(中文关键词) → find English equivalent terms
- Check if the Chinese paper has an English title/abstract indexed in Semantic Scholar

> **Tool Preloading Check (Critical)**
>
> MCP tools must be explicitly loaded before first use in a conversation. The following are NOT automatically available:
>
> | Tool | Preloading Command | When Needed |
> |------|-------------------|-------------|
> | WebSearch | `ToolSearch("select:WebSearch")` | Before any WebSearch call |
> | WebFetch | `ToolSearch("select:WebFetch")` | Before fetching any URL |
> | Semantic Scholar | `ToolSearch("select:semantic-scholar__search_papers,semantic-scholar__get_paper")` | Before first academic search |
>
> **Failure mode**: Calling WebSearch or WebFetch without preloading causes silent fallback or error.
>
> **Mnemonic**: "Select then Search" — every MCP tool needs a selection step first.
>
> **Re-check**: If entering a new conversation turn, re-verify tools are loaded before use.

> **完成清单**：
> - [ ] 2-3 次 WebSearch 快速查询已完成
> - [ ] 已提取标准领域术语/缩写
> - [ ] 3 个精化搜索字符串已用提取术语重新编写
> - [ ] MCP 工具已预加载（WebSearch、WebFetch、Semantic Scholar）
>
> **产出物**：3 个精化搜索字符串 + 工具预加载确认

## Step 2: Parallel Search

> **启动条件**：Step 1 完成（Step 1.5 精化后置，按需触发）
> **前置检查**：所有 MCP 工具已通过 ToolSearch 预加载（见上方 Step 1.5 Tool Preloading Check）

### Trigger Matrix

| Topic Type | Search Combo | When |
|-----------|-------------|------|
| **Academic/Literature** | WebSearch + OpenAlex + Semantic Scholar（逐个，≥1 秒） | User doing lit review, or topic has domain terminology |
| **Technical/Coding** | WebSearch (primary) + context7 (docs) | Framework/lib/tool usage |
| **General/News** | WebSearch × 3 queries | Industry news, current events |
| **Mixed/Unsure** | WebSearch first, then decide if academic MCP needed | Default |

### Parallel Rules

- **Concurrent** (multiple tool calls in one message), no queue
- Return **top 5-10 results** per source
- Source fails → down-weight, continue
- **Semantic Scholar 速率限制**：每次查询间隔 ≥1 秒，逐个发送，禁止并行多条 Semantic Scholar 查询
- **利用等待间隔**：Semantic Scholar 查询间的 ≥1 秒间隔内，并行发起 OpenAlex 查询，不浪费空闲

### Fan-Out Search (Agent-Based Parallelism)

当有 3+ 个查询变体需要独立执行时（如 3 个查询变体 × 2 个来源 = 6 次调用），使用 Agent 工具扇出到 sub-agent，而非串行调用。

**扇出拓扑**：

```
主 Agent 拆解搜索计划
    │
    ├→ sub-agent 1: WebSearch(query_variant_1) → WebFetch top results
    ├→ sub-agent 2: WebSearch(query_variant_2) → WebFetch top results
    ├→ sub-agent 3: Semantic Scholar(query_refined_1) + get_paper abstracts
    ├→ sub-agent 4: OpenAlex(query_refined_2, via WebFetch)
    │
    └→ 主 Agent 归并: dedup → rank → select top 5-8 per source
```

**调度规则**：

1. **One source per sub-agent**：每个 sub-agent 只处理 1 个来源 + 1 个查询变体
2. **返回契约**：每个 sub-agent 返回 JSON：
   ```json
   {"source": "Semantic Scholar", "query": "...", "results": [
     {"title": "...", "url": "...", "snippet": "...", "relevance_signal": "high|medium"}
   ]}
   ```
3. **每轮最多 4 个 sub-agent**；超过 4 个变体时分批
4. **SS 速率限制 + 扇出**：多个 SS 查询时错开 ≥1s 调度，或合并到一个 sub-agent 内串行

**归并规则**：
- 按 URL 去重（保留引用数高的版本）
- 按相关性排序（high > medium > low），再按年份
- 每来源保留 top 5-8，总计 top 12-15
- 来源无结果 → 标记 "no results from {source}"

**反模式**：
- 6-8 次串行调用而不是扇出
- 给一个 sub-agent 分配多个来源
- 仅 1-2 个查询也扇出（开销 > 收益）

> **完成清单**：
> - [ ] 按 Trigger Matrix 选择了正确的搜索组合
> - [ ] 已按来源并行发送查询（非串行）
> - [ ] 搜索结果已去重、排序、选取 top 12-15
> - [ ] 来源失败已标记 limitation
> - [ ] Semantic Scholar 查询间隔 ≥1 秒
> - [ ] 使用了 Fan-Out 扇出（当查询变体 ≥3 个时）
>
> **产出物**：搜索结果汇总（top 12-15 条目，含来源标记）
>
> **⚠️ 终止条件**：若所有源（WebSearch、Semantic Scholar、OpenAlex）均返回 0 结果，**不得静默进入 Step 3**。须输出：*"所有搜索源均无结果。可能原因：(1) 搜索词过于精确 (2) 工具未正确预加载 (3) API 不可用。建议：检查 ToolSearch 预加载状态，或改用更宽泛的搜索词。"* 然后终止流程等待用户输入。

## Step 3: Content Fetching

> **启动条件**：搜索结果就绪（Step 2 完成）

| Source | Method |
|--------|--------|
| WebSearch | Link → WebFetch for abstract or full text |
| Semantic Scholar | `get_paper` for abstract, `get_paper_fulltext` if needed |
| OpenAlex | WebFetch `https://api.openalex.org/works?search=` 获取元数据 + 引用数 |

**源不可用处理**：任一 Source 请求失败（含间接查询无结果）→ 降级标记该源，注明 limitation，继续流程不中断。

**Don't fetch full text blindly** — only when abstract is insufficient.

> **获取到全文后** → 判断文献数：≥2 篇则启动 Sub-agent 并行分层阅读（每篇完整执行质量快检→分块→gist→精读→claim 提取，输出 4 文件到 `01-investigation/literature/{paper_id}/`），主 agent 收集后执行 [多 Agent 信息核对](skills/paper-research/protocols/verification.md)；1 篇则主 agent 单线执行 [分层阅读协议](skills/paper-research/protocols/hierarchical-reading.md)。

**内容获取完成后**，将搜索结果汇总写入 `01-investigation/search-results.md`（含查询来源、结果列表、选取依据）。

### Chinese Paper Fallback

中文期刊论文常遇到 PDF 付费墙、缺少 DOI、或在西方 API 中元数据不完整的情况。

**回退协议**：

```
Attempt Semantic Scholar get_paper / get_paper_fulltext
  │
  ├→ Full text accessible?
  │   ├→ Yes → Read + process normally（含中文文本）
  │   └→ No / paywall / DOI not found →
  │       ├→ Try 1: Search Semantic Scholar for English-language papers
  │       │          on the SAME compound/system
  │       │
  │       ├→ Try 2: WebSearch with Chinese keywords + "PDF" or "全文"
  │       │          Use WebFetch only if a direct PDF link is found
  │       │
  │       └→ Try 3: Accept abstract-level data only
  │                  → 输出中标注："中文期刊, abstract only, 未独立验证"
```

**规则**：
1. **禁止编造**被付费墙阻挡的数据。无法读取则标注空缺，在报告中注明。
2. **英文文献交叉验证**：中文论文的数值若能找到英文等同文献佐证，标注"中文摘要级 + 英文文献 [[ref]] 佐证"。
3. **证据降级**：仅摘要可获取的数据降一级——从"原创研究"降为"摘要级证据"。
4. **来源标注**：在引用条目末尾加上 `(Chinese, abstract only)`。

> **完成清单**：
> - [ ] 所有来源内容已获取（WebFetch / get_paper / OpenAlex API）
> - [ ] 获取到全文 → 已判断文献数并执行分层阅读（≥2 篇走并行）
> - [ ] 搜索结果已写入 `01-investigation/search-results.md`
> - [ ] 源不可用 → 已降级标记并注明 limitation
>
> **产出物**：`01-investigation/search-results.md`（含查询来源、结果列表、选取依据）
>
> **如果获取到全文**，额外产出：
> - `01-investigation/literature/{paper_id}/`（分层阅读 4 文件 + 原文副本）
> - 多 Agent 核对报告（≥2 篇文献时）参照 [verification.md data 模式](skills/paper-research/protocols/verification.md)

## Step 4: Cross-Validation

> **启动条件**：Content Fetching 完成（含分层阅读 + 多 Agent 核对，如需要）

Internal quality check before synthesis.

- 有 [多 Agent 核对报告](skills/paper-research/protocols/verification.md) → 以核对报告结论为优先输入，补充非文献来源判断
- 无核对报告 → 按以下规则判断：

| Situation | Action |
|-----------|--------|
| Multi-source agreement | Adopt, high confidence |
| Conflict with multi-source on one side | Trust multi-source side |
| Both single-source | authority > recency > volume; flag if still uncertain |
| Single source only, no cross-ref | Downgrade, note limitation in output |
| No source | State no direct evidence |
| Time-dependent conclusions | Use latest, note timeline |

> **完成清单**：
> - [ ] 已检查是否有多 Agent 核对报告（有则以它为优先输入）
> - [ ] 按情境规则完成置信度判定
> - [ ] 单源/无源情况已标注 limitation
> - [ ] 时间敏感结论标注了时间线
>
> **产出物**：交叉验证结论（置信度标注 + 局限性注释，嵌入合成步骤）

## Step 5: Synthesis

> **启动条件**：Cross-Validation 完成（Step 4）

Read all results → extract 3-5 key points → organize as logical narrative. No inline citations; all sources at end.

### Output Format

```text
## [Title]

> [One-line core takeaway]

Narrative body... (logical flow, no inline references)

---

**Sources**
- [Title](URL) — [source type]
```

**保存合成结果**，供 Step 8 写入 `02-analysis/synthesis-notes.md`。

> **完成清单**：
> - [ ] 3-5 个核心要点已提取
> - [ ] 逻辑叙事已组织（无内联引用）
> - [ ] 合成结果已暂存，供 Step 8 写入
>
> **产出物**：合成结论（暂存状态，供 Step 8 写入 `02-analysis/synthesis-notes.md` + `03-report/research-brief.md`）

---

## Step 6: Content Verification

> **启动条件**：Synthesis 完成（Step 5）且 本次会话涉及文献阅读
> **跳过条件**：纯搜索任务 / 未获取任何文献全文 / 用户明确要求跳过

在合成之后、输出之前，对合成结果的每条结论进行内容审查。仅在本次会话涉及文献阅读时执行。

> **详细协议** → `skills/paper-research/protocols/verification.md`
>
> **与多 Agent 信息核对的关系**：核对（Step 3→4 之间）= 跨文献原始 claim 一致性检查（数据级），通过 [verification.md](skills/paper-research/protocols/verification.md) 执行；内容审查（Step 6）= 报告中引用的 claim 验证（报告级，含引用真实性检查）。两者层次不同但互为补充——核对确保文献间数据可信，内容审查确保最终输出引述准确。

| 步骤 | 说明 |
|------|------|
| Claim 抽取 | 将每条结论拆解为原子 claim (subject, relation, object) |
| 跨 Agent/跨源比对 | 一致→高置信度；矛盾→标记争议，引用原文裁决；孤 claim→低置信度 |
| 引用验证 | 每条引用检查 DOI/PMID 真实性（使用 Semantic Scholar） |
| 输出 | Claim Table：每条声明的来源、置信度、验证状态 |

**审查完成后**，将 Claim Table 写入 `02-analysis/content-verification-report.md`，供最终输出时引用。

> **完成清单**：
> - [ ] 每条结论已拆解为原子 claim
> - [ ] 跨 Agent/跨源比对已完成（一致/矛盾/孤 claim 分类）
> - [ ] 每条引用已验证 DOI/PMID 真实性
> - [ ] Claim Table 已写入 `02-analysis/content-verification-report.md`
> - [ ] 无 vibe citing

---

## Step 7: Follow-up

> **启动条件**：Content Verification 完成（或跳过）

Auto-generate 3 follow-up directions:

- **Deeper dive**: sub-topic based on current results
- **Verify**: "Does this hold under X condition?"
- **Extend**: "What are related directions?"

**模式切换评估**：若当前研究结果表明显著未覆盖的深度（系统性文献缺口、需方法学评估、跨领域集成需求），应在此步骤主动建议：*"当前结论基于 Quick 调研，如需系统综述（APA 报告 + 全文 meta 分析），建议切换到 Deep Mode。已生成 `{research-topic}/` 目录，切换后可复用已有文献和搜索结果。"*

> **完成清单**：
> - [ ] 3 个后续方向已生成（更深/验证/扩展）
> - [ ] 已评估是否需要切换到 Deep Mode
>
> **产出物**：3 个 follow-up 建议 + （可选）Deep Mode 切换建议

---

## Step 8: 最终输出

> **启动条件**：全部前置步骤（Step 1-7）完成或按条件跳过

写入最终研究简报。目录骨架已在 Step 1 创建，中间产物（claim table、交叉验证报告、内容审查报告）已在各步骤产生时落盘。

1. 写入 `02-analysis/synthesis-notes.md` — 归并后的核心发现与源要点
2. 写入 `03-report/research-brief.md` — 最终简短回答（500-1500字）

> **完成清单**：
> - [ ] `02-analysis/synthesis-notes.md` 已写入
> - [ ] `03-report/research-brief.md` 已写入
> - [ ] 所有中间产物已验证可访问
>
> **产出物**：
> - `02-analysis/synthesis-notes.md` — 核心发现与源要点
> - `03-report/research-brief.md` — 最终研究简报

---

## Step 9: Session-Log（跨会话学习）

> **启动条件**：Step 8 完成（可选步骤，建议执行）

记录本次搜索经验用于跨会话知识积累，写入 `{research-topic}/.session-log.json`：

```json
{
  "ts": "自动填入",
  "topic": "{research-topic}",
  "mode": "quick",
  "domain": "领域名（如材料科学/AI/生物医学）",
  "sources": {"websearch": {...}, "semantic_scholar": {...}, "openalex": {...}},
  "effective_terms": ["返回≥3条相关结果的搜索词"],
  "ineffective_terms": ["返回0或噪声的搜索词"],
  "failures": ["不可达或超时的源"],
  "skipped_steps": ["被跳过的步骤名及原因"],
  "user_feedback": "null 或用户反馈文本"
}
```

> 详见 `skills/paper-research/protocols/source-reliability.md` 的 Session-Log 格式定义和累积矩阵更新规则。

> **完成清单**：
> - [ ] `.session-log.json` 已写入 `{research-topic}/` 目录
>
> **产出物**：`{research-topic}/.session-log.json`

````

## protocols/deep-mode.md

````text
# Deep Mode — 学术研究管线

> Structured multi-agent academic research pipeline for systematic reviews and in-depth analysis.
> Part of `paper-research` skill — loaded by `skills/paper-research/SKILL.md` when Deep Mode is selected.

`version: v3.0 | created: 2026-05-07 | updated: 2026-06-05 | status: active`

---

## Mode Guide

```
User Input
    |
    +-- Clear research question?
    |   +-- Yes --> Need systematic review / meta-analysis?
    |   |           +-- Yes --> systematic-review mode
    |   |           +-- No --> Need full report?
    |   |                      +-- Yes --> full mode
    |   |                      +-- No --> lit-review mode
    |   +-- No --> Want guided thinking?
    |              +-- Yes --> socratic mode
    |              +-- No --> full mode (Phase 1 interactive)
    |
    +-- Have text to review? --> review mode
    +-- Only fact-check? --> fact-check mode
```

## Phase 1: Scoping (Interactive)

> **启动条件**：用户选择 Deep Mode / 深度研究需求

| Agent | Output |
|-------|--------|
| **Research Question Agent** | RQ Brief → `01-scoping/research-question.md` — FINER criteria, scope boundaries, 2-3 sub-questions |
| **Research Architect** | Methodology Blueprint → `01-scoping/methodology-blueprint.md` — paradigm, method, data strategy |
| **Devil's Advocate** | Checkpoint → `01-scoping/devil-advocate-check.md` — RQ answerable? Method appropriate? → PASS/REVISE |

**User confirmation required before Phase 2.**

> **完成清单**：
> - [ ] Research Question Brief 已写入
> - [ ] Methodology Blueprint 已写入
> - [ ] Devil's Advocate Checkpoint 为 PASS
> - [ ] 用户已确认进入 Phase 2
>
> **产出物**：`01-scoping/` 目录下 3 个输出文件

### Phase 1→2: 创建目录树

根据 RQ Brief 确定 `{research-topic}` 目录名（英文短横线格式，如 `fe3o4-heterostructure-review`），在项目根目录创建完整目录树：

```
{research-topic}/
├── 01-scoping/       ← Phase 1 输出（已有文件移入）
├── 02-investigation/
│   └── literature/   ← 精读文献 + sub-agent 输出
├── 03-analysis/      ← 核对报告 + 合成笔记
├── 04-composition/   ← 报告草稿
├── 05-review/        ← 审查报告
└── 06-report/         ← 最终报告 + 参考文献
```

> Phase 1 输出文件写入时即指定对应目录路径。

## Phase 2: Investigation

> **启动条件**：Phase 1 完成 + 用户确认
> **前置检查**：WebSearch/WebFetch/Semantic Scholar 工具已通过 ToolSearch 预加载

> **Tool Preloading Check（与 Quick Mode 共享）**
>
> MCP 工具首次使用前必须预加载：
>
> | Tool | Preloading Command |
> |------|-------------------|
> | WebSearch | `ToolSearch("select:WebSearch")` |
> | WebFetch | `ToolSearch("select:WebFetch")` |
> | Semantic Scholar | `ToolSearch("select:semantic-scholar__search_papers,semantic-scholar__get_paper")` |
>
> **Mnemonic**: "Select then Search" — 先 ToolSearch 再使用。详见 `quick-mode.md` Step 1.5。

| Agent | Output |
|-------|--------|
| **Bibliography Agent** | Bibliography → `02-investigation/bibliography.md` — Systematic search, annotated bibliography (APA 7.0) |
| **Source Verification Agent** | Verification → `02-investigation/source-verification.md` — Evidence hierarchy grading, predatory journal check, CoI flagging |

> **获取到文献全文后** → 判断文献数：≥2 篇则启动 Sub-agent 并行分层阅读（每篇完整执行质量快检→分块→gist→精读→claim 提取 + 原文下载，输出 4 文件到 `02-investigation/literature/{paper_id}/`），主 agent 收集后执行下方核对步骤；1 篇则主 agent 单线执行 [分层阅读协议](skills/paper-research/protocols/hierarchical-reading.md)，输出到同一目录结构。

### Phase 2→3: 多 Agent 信息核对

主 agent 收集所有 sub-agent 的 claim-table 后，执行完整 [多 Agent 信息核对](skills/paper-research/protocols/verification.md) 流程（4 步：归并→比对→裁决→报告），核对报告输出到 `03-analysis/cross-validation-report.md`。

### Agent Dispatch Specification (Phase 2 Search)

Bibliography Agent 的搜索扇出调度规范已提取到独立文件：

**详细规范** → `skills/paper-research/agents/bibliography-agent.md`

内容包括：搜索词精化策略、扇出拓扑图、归并规则、Tool Preloading 要求。

> **扇出-验证-归并原则（Dynamic Workflows）**：每个扇出轮次遵循三步模式：
> 1. **扇出（Fan-out）** — 主 Agent 拆解任务，分发到独立 sub-agent（每轮 ≤3 个）
> 2. **验证（Verify）** — 每个 sub-agent 独立执行并按契约返回格式化结果
> 3. **归并（Merge）** — 主 Agent 收集结果，去重、排序、冲突处理
>
> 该模式是 Dynamic Workflows 在 paper-research 中的具体应用。详见 Phase 5 的并行评审拓扑。

> **完成清单**：
> - [ ] Bibliography 搜索完成（含搜索词精化 + 扇出调度）
> - [ ] 文献全文已获取并分层阅读完成
> - [ ] 多 Agent 信息核对已完成（verification.md）
> - [ ] Source Verification 已写入
> - [ ] 核对报告已输出到 `03-analysis/cross-validation-report.md`
>
> **产出物**：
> - `02-investigation/` 目录（bibliography + source verification + literature）
> - `03-analysis/cross-validation-report.md`

## Phase 3: Analysis

> **启动条件**：核对报告就绪（Phase 2 完成）

| Agent | Output |
|-------|--------|
| **Synthesis Agent** | Synthesis → `03-analysis/synthesis-notes.md` — Cross-source integration, contradiction resolution, gap analysis（基于核对后的可信 claims） |
| **Devil's Advocate** | Checkpoint → `03-analysis/devil-advocate-check.md` — cherry-picking? confirmation bias? logic valid? → PASS/REVISE |

**➤ Devil's Advocate 强制执行**（防偏机制）：在输出 PASS/REVISE 前，**必须实际执行**至少 1 次反方关键词的 WebSearch（而非凭模型知识判断），将搜索结果引用写入 checkpoint 的 `counter-evidence` 部分。未执行反方搜索 → checkpoint 自动 FAIL。

**修订循环规则**（与 Phase 5 一致）：若 REVISE，由 Synthesis Agent 修订后 Devil's Advocate 重新检查。**最多 2 轮**；2 轮后仍 REVISE → 将未解决问题记录为 "Acknowledged Limitations" 并继续推进。

> **完成清单**：
> - [ ] Synthesis 已写入 `03-analysis/synthesis-notes.md`
> - [ ] Devil's Advocate 为 PASS（或有已计划的修订）
>
> **产出物**：`03-analysis/synthesis-notes.md` + `devil-advocate-check.md`

## Phase 4: Composition

> **启动条件**：Phase 3 完成

| Agent | Output |
|-------|--------|
| **Report Compiler** | Draft → `04-composition/draft-report.md` — Full APA 7.0 report: Title → Abstract → Intro → Method → Findings → Discussion → References |

> **报告草稿完成后** → 执行[内容审查](skills/paper-research/protocols/verification.md)对结论进行 claim 级交叉验证和引用真实性检查。审查结果作为 Phase 5 Review 的输入。

> **完成清单**：
> - [ ] APA 7.0 报告草稿已写入 `04-composition/draft-report.md`
> - [ ] 内容审查已完成（verification.md）
>
> **产出物**：`04-composition/draft-report.md` + 内容审查结果

## Phase 5: Review

> **启动条件**：内容审查完成（Phase 4）

| Agent | Output |
|-------|--------|
| **Editor in Chief** | Review → `05-review/editorial-review.md` — Originality, rigor, evidence → ACCEPT/REVISE/REJECT |
| **Ethics Review** | Review → `05-review/ethics-review.md` — AI disclosure, attribution, dual-use → CLEARED/BLOCKED |
| **Devil's Advocate** | Review → `05-review/final-devil-advocate.md` — Final vulnerability scan → PASS/REVISE |

**IRON RULES:**
- Devil's Advocate **必须实际执行**反方关键词 WebSearch（与 Phase 3 相同），未执行 → 自动 FAIL
- Devil's Advocate CRITICAL issues block progression
- Ethics BLOCKED halts delivery
- Max 2 revision loops; remaining issues → "Acknowledged Limitations"

### 评审范围（按 Operational Mode）

| Operational Mode | 评审配置 |
|-----------------|---------|
| `full` / `systematic-review` | 完整 Triple Review（Editor + Ethics + Devil's Advocate 并行） |
| `lit-review` / `review` | 双 Agent 评审（Editor + Devil's Advocate） |
| `quick` / `fact-check` | 单 Agent 评审（仅 Devil's Advocate） |

原因：quick/fact-check 模式输出篇幅小（300-1500字），完整 Triple Review 的并行开销与产出不成比例。lit-review/review 不需要 Ethics Review。

### Dynamic Workflows: Parallel Review Topology

Phase 5 的三个评审 Agent 以**并行拓扑**执行，而非顺序执行。主 Agent 在所有评审完成后汇总结果：

```
主 Agent 触发评审
    │
    ├→ Agent(Editor in Chief)  → `05-review/editorial-review.md`
    ├→ Agent(Ethics Review)    → `05-review/ethics-review.md`
    └→ Agent(Devil's Advocate) → `05-review/final-devil-advocate.md`
    │
    └→ 主 Agent 归并: 按优先级处理问题 → `05-review/merged-review.md`
```

**归并优先级规则**：
1. Ethics BLOCKED → 立即停止，不推进交付
2. Devil's Advocate CRITICAL → 标记为必须修订
3. Editor in Chief ACCEPT/REVISE → 纳入修订计划
4. 多 Agent 意见一致 → 加速执行
5. 多 Agent 意见冲突 → 按上述优先级裁决

**IRON RULE 增强**：由于评审并行执行，"Ethics BLOCKED halts delivery" 在并发场景下确保 Ethics 的否决权高于其他评审。主 Agent 必须在归并阶段检查 Ethics 结果——若 BLOCKED，丢弃其他评审结果，立即停止。

> **完成清单**：
> - [ ] 三个评审均已写入 `05-review/` 目录
> - [ ] Ethics 未 BLOCKED
> - [ ] 归并评审已写入 `05-review/merged-review.md`
>
> **产出物**：`05-review/merged-review.md`（含所有评审意见 + 归并优先级处理）

## Phase 6: Revision

> **启动条件**：Phase 5 评审完成

Report compiler addresses feedback, resolves conditions, produces final report.

Output → `06-report/research-report.md` + `06-report/references.md`

> **完成清单**：
> - [ ] 所有评审反馈已处理（最多 2 轮修订）
> - [ ] 最终报告已写入 `06-report/research-report.md`
> - [ ] 参考文献已写入 `06-report/references.md`
>
> **产出物**：`06-report/research-report.md` + `06-report/references.md`

**Phase 6 完成后（可选）**：写入 Session-Log 用于跨会话知识积累：

写入 `{research-topic}/.session-log.json`，格式见 `skills/paper-research/protocols/source-reliability.md`。Deep Mode 的 `mode` 字段填入实际使用的 Operational Mode（full/lit-review/systematic-review 等）。

---

## Socratic Mode

> 5-layer guided dialogue for when user has vague ideas but no clear research question.

| Layer | Focus |
|-------|-------|
| 1 | Clarification — "What aspect interests you most?" |
| 2 | Assumption Probing — "Why do you think that matters?" |
| 3 | Evidence/Reasoning — "What evidence would change your view?" |
| 4 | Viewpoint/Perspective — "How would someone with opposite view argue?" |
| 5 | Implication/Consequence — "If proven true, what follows?" |

**IRON RULE:** Never give direct answers — always guide through questions.

## Operational Modes

| Mode | Output | Length |
|------|--------|--------|
| `full` (default) | Full APA 7.0 report | 3,000-8,000 words |
| `quick` | Research brief | 500-1,500 |
| `review` | Reviewer report on provided text | N/A |
| `lit-review` | Annotated bibliography + synthesis | 1,500-4,000 |
| `fact-check` | Verification report | 300-800 |
| `socratic` | Guided dialogue → Research Plan | Iterative |
| `systematic-review` | PRISMA 2020 report + GRADE table | 5,000-15,000 |

## Anti-Patterns

| Anti-Pattern | Correct Behavior |
|-------------|-----------------|
| Confirmation bias in source selection | Devil's Advocate checkpoint includes counter-evidence search |
| Cherry-picking evidence | Report full evidence landscape including conflicts |
| **IRON RULE: Vibe citing** | Every reference verified independently; gray zone = FAIL |
| Skipping phases | Complete each phase fully; output is next phase input |
| Shallow Socratic (disguised answers) | Ask genuine questions exposing assumptions |
| Source tier inflation | Evidence hierarchy: peer-reviewed > preprint > gray lit |

**IRON RULE:** Every claim must have a citation. No unsupported assertions.

## Handoff to academic-paper

After deep research, the entire `{research-topic}/` directory contains all materials (RQ Brief, Methodology, Bibliography, Synthesis, Cross-Validation Report, Reports). Handoff to `academic-paper` by passing the directory path, where `intake_agent` reads from the filed outputs.

````

## protocols/source-reliability.md

````text
# Source Reliability Matrix

> 跨会话累积的源可靠性评分，按领域分级。每次 session 结束后可从 `.session-log.md` 增量更新。
> Part of `paper-research` skill — loaded by `skills/paper-research/SKILL.md` 按需引用。

`version: v1.0 | created: 2026-06-05 | status: active`

---

## 评分方法论

| 维度 | 权重 | 评估方法 |
|------|:--:|---------|
| 结果相关性 | 40% | top-5 中与查询直接相关的条目占比 |
| 全文可获取率 | 30% | 有可读原文（非付费墙/null）的结果占比 |
| API 可用性 | 20% | 本次会话请求成功率（无超时/限速） |
| 速率/延迟 | 10% | 超时或限速次数（越少越好） |

**评分**: ⭐⭐⭐⭐⭐ 极佳 → ⭐ 接近不可用

**更新规则**: 每 3 次 session 后，对评分做一次加权平均修正。连续 3 次下降 → 触发降级警告。

---

## 累积矩阵（按领域）

> 初始评分基于语义覆盖范围预估，随使用累积自动修正。

| 领域 | Semantic Scholar | OpenAlex | WebSearch |
|------|:---:|:---:|:---:|
| **材料科学** (纳米/磁性) | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **环境工程** (PFAS/AOP/VOCs) | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **AI/ML** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **中文人文社科** | ⭐⭐ | ⭐ | ⭐⭐⭐ |
| **生物医学** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| *未分类* (默认) | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

### 源特性速查

| 源 | 强项 | 弱项 |
|----|------|------|
| Semantic Scholar | 引用关系图、is_influential 标记、全文链接 | 中文覆盖弱、API 限速严格 |
| OpenAlex | 开放获取、机构/基金元数据丰富 | 部分学科全文率低、搜索精度不如 SS |
| WebSearch | 最新信息、跨领域覆盖、无 API 限制 | 无结构化元数据、信噪比波动大 |

---

## Session-Log 格式

每次 session 结束时（Quick Mode Step 9 / Deep Mode Phase 6 后），写入 `{research-topic}/.session-log.json`：

```json
{
  "ts": "2026-06-05_2200",
  "topic": "fe3o4-heterostructure-review",
  "mode": "quick",
  "domain": "材料科学",
  "sources": {
    "websearch": {"results": 8, "relevant": 7, "fetchable": 5},
    "semantic_scholar": {"results": 12, "relevant": 10, "fetchable": 8},
    "openalex": {"results": 5, "relevant": 3, "fetchable": 2}
  },
  "effective_terms": ["Fe₃O₄ heterostructure", "exchange bias interface"],
  "ineffective_terms": [],
  "failures": [],
  "skipped_steps": ["step_1.5"],
  "user_feedback": null
}
```

**字段说明**：
- `sources.<name>.relevant`: 结果中与查询直接相关的条目数（用于计算结果相关性维度）
- `sources.<name>.fetchable`: 有可读原文的条目数（用于计算全文可获取率维度）
- `failures`: 不可达或超时的源
- `skipped_steps`: 被跳过的步骤及原因（用于跳过率自检）

---

## Related

- `skills/paper-research/SKILL.md` — 主 skill 入口（Protocol Index）
- `skills/paper-research/protocols/quick-mode.md` — Quick Mode（Step 9 记录 session-log）
- `skills/paper-research/protocols/deep-mode.md` — Deep Mode（Phase 6 后记录 session-log）

````

## protocols/hierarchical-reading.md

````text
# 分层阅读协议

> `[evol:protocol]` — 获取到精读文献全文后启动，解决大文件处理和解析质量问题的标准化阅读流程。

`version: v1.1 | created: 2026-05-22 | updated: 2026-06-05 | status: active`

---

## 触发条件

**入口**：Content Fetching / Investigation 阶段拿到文献全文后

**判断**：
- 单篇文献字符数 > 8000 字 → 自动启动分层阅读
- 多篇文献合计 > 15000 字 → 自动启动分层阅读
- 文献来源为 PDF（经 pdftotext 转换）→ 自动启动分层阅读
- 用户明确要求"精读/仔细看这篇" → 自动启动分层阅读
- **多篇精读文献 ≥ 2 篇** → 启动 Sub-agent 并行分层阅读（详见下方）

**跳过条件**：文献篇幅小（单篇 < 3000 字）且来源为纯文本（非 PDF 转换），可直接精读。

---

## Step 1: 解析质量快检

PDF→文本转换后常见的符号失真模式，在精读前先扫描标记。

### 检视清单

| 检查项 | 检测方法 | 严重程度 |
|--------|----------|----------|
| 公式符号丢失 | 扫描孤立字母+数字组合、□/� 等替换字符 | ⚠️ 高 |
| 上下标扁平化 | E₀→E0, xᵢ→xi 等下标数字/字母丢失格式 | ⚠️ 中 |
| 表格结构错位 | 行内出现不一致的列数、竖线/空格异常 | ⚠️ 高 |
| 特殊字符替换 | αβγ→aßy, ≥→>=, ±→+ 等 | ⚠️ 高 |
| 断行/断词异常 | 单词中间换行、公式跨行断裂 | ⚠️ 中 |
| 引用编号丢失 | [1][2]→[ ][ ] 或完全消失 | ⚠️ 低 |

### 输出格式

```
## 解析质量报告

| 风险段落（行号范围） | 问题类型 | 说明 |
|---------------------|----------|------|
| L120-125 | 公式符号丢失 | "α-Fe₂O₃" 显示为 "a-Fe203"，下标丢失 |
| L300-310 | 表格结构错位 | 第 3 列表格数据串列到第 2 列 |

**整体评估**: {通过 / 部分失真 / 严重失真}
```

### 处理策略

| 评估结果 | 处理方式 |
|----------|----------|
| 通过 | 进入 Step 2 分块阅读，不额外处理 |
| 部分失真 | 进入 Step 2，但 gist 中标注"此段落可能因解析问题存在信息失真" |
| 严重失真 | 尝试替代解析方案（如有），否则标注"此文献解析质量差，结论需谨慎对待" |

---

## Step 2: Episode Pagination（语义分块）

按文献的自然语义边界分块，而非固定 token 数切割。

### 分块规则

默认按以下优先级识别语义断点：

| 优先级 | 断点类型 | 检测信号 |
|--------|----------|----------|
| 1 | 章节标题 | `#`, `##`, `Abstract`, `Introduction`, `Methods`, `Results`, `Discussion`, `Conclusion`, `References` |
| 2 | 段落空行 | 连续两个以上换行符 |
| 3 | 逻辑段落 | 方法→结果 等主题转换处（LLM 判断） |

### 输出结构

每块包含以下元信息：

```
## Chunk {N}

path: {文章标题}
section: {章节名}
lines: {起始行-结束行}
tokens: ~{估算 token 数}
```

### 最大块大小

- 单块不超过 4000 tokens（经验值，适配上下文窗口）
- 超过 4000 tokens 的按段落边界二次拆分
- 小于 200 tokens 的相邻块合并

---

## Step 3: Memory Gisting

每块读完后压缩为一句话 gist，建立整篇文献的 gist 索引。

### Gist 模板

```
{gist} | [{chunk_id}] | {section}
```

**示例输出**：

```
引入了 Fe₃O₄/α-Fe₂O₃ 异质结构的概念，指出界面耦合增强磁电效应 | [C1] | Introduction
采用水热法合成，500°C 退火 2h 得到 α-Fe₂O₃ 相 | [C2] | Methods
XRD 和 TEM 确认了异质界面存在，磁滞回线显示交换偏置增强 | [C3] | Results
```

### 输出：Gist 索引

```
## Gist Index: {文献标题}

| # | 所在章节 | Gist |
|---|---------|------|
| C1 | Introduction | 引入了 Fe₃O₄/α-Fe₂O₃ 异质结构的概念... |
| C2 | Methods | 采用水热法合成，500°C 退火... |
| C3 | Results | XRD 和 TEM 确认了异质界面存在... |
| C4 | Discussion | 界面电荷转移是性能增强的主因... |
```

---

## Step 4: Interactive Lookup（按需精读）

基于 gist 索引决定哪些块需要精读，哪些块只需要 gist 级信息。

### 精读决策矩阵

| 场景 | 精读策略 |
|------|----------|
| 用户问具体方法/数据 | → 精读对应的 Methods/Results 块 |
| 用户问主要发现 | → 精读 Discussion/Conclusion 块 |
| 需要引用某结论 | → 精读该 claim 来源块，核实原文表述 |
| 对比多篇文献 | → 精读每篇的 Results/Discussion 块 |
| 只需了解范围 | → 只读 gist 索引，不精读 |

### 精读输出规范

每块精读后输出：

```
## 精读笔记: {chunk_id} | {section}

### 关键发现
- {原子 claim 1}
- {原子 claim 2}

### 支持数据
- {具体数值/引用/数据点}

### 存疑标记
- {如果有解析质量问题或逻辑跳跃，在此标注}
```

---

## 多文献场景

多篇文献同时处理时，每篇独立走 Step 1-3，然后合并为一个**多文献 gist 索引矩阵**：

```
## 多文献 Gist 矩阵

| 文献 | 核心主题 | Methods | 关键结果 | 结论 |
|------|----------|---------|---------|------|
| Ref 1 (Wang 2024) | Fe₃O₄/α-Fe₂O₃ ... | 水热/500°C | 交换偏置增强 | 界面耦合 ... |
| Ref 2 (Li 2023) | CoFe₂O₄ 纳米颗粒 | 共沉淀/400°C | Ms=85 emu/g | 尺寸效应 ... |
```

合并后统一进入 Interactive Lookup 决策。

---

## Sub-agent 并行模式（多文献 ≥ 2 篇）

当文献数 ≥ 2 篇时，先判断是单线处理还是 Sub-agent 并行：

- **单线处理**（文献数 < 2）：走本协议 Step 1→2→3→4
- **Sub-agent 并行**（文献数 ≥ 2）：分派到独立 sub-agent 执行完整分层阅读，**详细模板和调度规则见** `skills/paper-research/agents/literature-reader.md`

主 agent 收集所有 sub-agent 输出 → [多 Agent 信息核对](skills/paper-research/protocols/verification.md)（verification.md data 模式）。

### 跨模式调用点

| 模式 | 分层阅读插入点 | 核对机制插入点 | 内容审查插入点 | 结果落盘 |
|------|---------------|---------------|---------------|----------|
| Quick Mode | Content Fetching 之后（Step 3 → 分层阅读 → Step 4，≥2篇走并行） | 分层阅读之后（核对 → Step 4） | Step 5 合成之后（Step 6） | Step 7 之后（Step 8） |
| Deep Mode | Investigation 之后（Phase 2 → 分层阅读 → Phase 3，≥2篇走并行） | 分层阅读之后（核对 → Phase 3） | Composition 之后（Phase 4 → 内容审查 → Phase 5） | Phase 6 之后（自行保存到对应目录） |

---

## 与本 skill 的关系

本协议被 `skills/paper-research/SKILL.md` 引用。在 Quick Mode 和 Deep Mode 中，获取文献全文后插入本流程。

- Quick Mode：通过 `quick-mode.md` 的 Step 3 触发
- Deep Mode：通过 `deep-mode.md` 的 Phase 2 触发

---

## Related

- `skills/paper-research/SKILL.md` — 主 skill 入口
- `skills/paper-research/protocols/quick-mode.md` — Quick Mode 协议
- `skills/paper-research/protocols/deep-mode.md` — Deep Mode 协议
- `skills/paper-research/protocols/verification.md` — 下游多 Agent 核对协议
- `skills/paper-research/protocols/verification.md` — 下游内容审查协议

````

## agents/bibliography-agent.md

````text
# Bibliography Agent

> 搜索阶段 Sub-agent 分派规范 — 学术文献搜索与扇出调度。
> 由 `deep-mode.md` Phase 2 调用。
> Part of `paper-research` skill.

`version: v1.0 | created: 2026-06-05 | status: active`

---

## Search Refinement

在调用 Semantic Scholar/OpenAlex 前，先执行与 Quick Mode 相同的两步策略：
1. **WebSearch 前置探查** → 提取领域标准术语
2. **Keyword Engineering** → 用提取术语精化搜索词

详见 `quick-mode.md` 的 Step 1→1.5。

---

## Fan-out Topology

```
Bibliography Agent 分解搜索策略
    │
    ├→ sub-agent 1: WebSearch (中文关键词) → 提取英文术语
    ├→ sub-agent 2: Semantic Scholar (主领域关键词)
    ├→ sub-agent 3: Semantic Scholar (反方/变形关键词)
    └→ sub-agent 4: OpenAlex (并行补充查询)
    │
    └→ 主 Agent 归并: 去重 → 按证据等级排序 → 注释书目
```

---

## Merge Rules

- 同名/同内容去重，保留引用数高的版本
- 每 sub-agent 返回 top 5，归并后保留 top 10-15
- 冲突结果标注双方来源，不强行统一
- 单次最多 3 个 sub-agent；SS 查询错开 ≥1s

---

## Tool Preloading

Phase 2 开始前验证 WebSearch/WebFetch/SS 工具已通过 ToolSearch 预加载。
详见 `quick-mode.md` Step 1.5 的 Tool Preloading Check。

---

## Related

- `skills/paper-research/protocols/quick-mode.md` — Quick Mode（搜索词精化参考）
- `skills/paper-research/protocols/deep-mode.md` — Deep Mode Phase 2（调用方）
- `skills/paper-research/SKILL.md` — 主 skill 入口

````

## agents/literature-reader.md

````text
# Literature Reader Agent

> Sub-agent 分派模板 — 对单篇文献执行完整分层阅读。
> 由 `hierarchical-reading.md` 在文献数 ≥ 2 篇时调用。
> Part of `paper-research` skill.

`version: v1.0 | created: 2026-06-05 | status: active`

> **{mode_prefix} 取值**：用于 investigation 目录。Quick Mode = `01-`，Deep Mode = `02-`
> **{ana_prefix} 取值**：用于 analysis 目录。Quick Mode = `02-`，Deep Mode = `03-`

---

## 并行流程图

```
文献全文（N 篇）
  │
  ├→ 文献数 ≥ 2?
  │   │
  │   ├── No → 单线处理（hierarchical-reading.md Step 1→2→3→4）
  │   │
  │   └── Yes → Sub-agent 并行
  │         ├─ Agent(litA) → 文献A: 质量快检→分块→gist→精读→claim表+原文
  │         ├─ Agent(litB) → 文献B: 同上
  │         └─ Agent(litC) → 文献C: 同上
  │               │
  │               └→ 各输出 4 文件到 {research-topic}/{mode_prefix}investigation/literature/{paper_id}/
  │
  └→ 主 agent 收集 → 多 Agent 信息核对（[verification.md](skills/paper-research/protocols/verification.md)）
```

---

## Dispatch Template

```yaml
Agent:
  description: "分层阅读: {文献标题前20字}"  # model 不指定，继承父进程
  prompt: |
    ## Background
    子任务：对以下文献执行完整分层阅读，输出 claim table + gist index + 原文位置索引。
    所属流程：paper-research（Quick/Deep Mode 通用）

    ## Task Specification
    ### WHAT
    0. 下载原文：将文献全文保存到输出目录（PDF 或 txt 格式）
    1. 解析质量快检，输出 quality-report.md（按 hierarchical-reading.md Step 1）
    2. Episode Pagination，按章节/段落语义分块，标注每块的行号范围（按 hierarchical-reading.md Step 2）
    3. Memory Gisting，每块一句 gist，输出 gist-index.md（按 hierarchical-reading.md Step 3）
    4. Interactive Lookup，精读所有块（单篇全部精读）（按 hierarchical-reading.md Step 4）

    ### WHERE
    文献路径：{path}
    输出目录：{research-topic}/{mode_prefix}investigation/literature/{paper_id}/

    ### DONE
    输出四个文件：
    - source.{pdf|txt} ← 原文副本
    - quality-report.md ← 解析质量报告
    - gist-index.md ← gist 索引（含行号范围）
    - claim-table.md ← 原子 claim 表（格式见 skills/paper-research/protocols/verification.md）

    ### DON'T
    - 不修改任何现有文件
    - 不搜索外部信息（只读给定文献）
    - 不分析多篇文献的关系（只处理单篇）

    ## Output Contract
    status: {success|partial|failure}
    files_modified: [文件列表]
    gist_summary: {一句话文献核心发现}
    claim_count: {提取的 claim 数}
    key_claims: {3-5条最重要的claim原文及位置}
```

---

## Isolation Rules

- 每个 sub-agent 写入独立子目录 `{research-topic}/{mode_prefix}investigation/literature/{paper_id}/`
- 各 sub-agent 之间无文件冲突
- 主 agent 按目录读取所有成果进行汇总
- 单轮最多 3 个 sub-agent 并行
- 文献数 > 3 篇：分批次并行（每批 ≤3），或优先选择最相关的 3 篇

---

## Related

- `skills/paper-research/protocols/hierarchical-reading.md` — 上游分层阅读协议（调用方）
- `skills/paper-research/protocols/verification.md` — 下游数据级核对（data 模式）
- `skills/paper-research/SKILL.md` — 主 skill 入口

````

## protocols/verification.md

````text
# 验证协议

> 统一 claim 级验证协议，通过调用模式区分数据级/报告级。
> Part of `paper-research` skill — loaded by `skills/paper-research/SKILL.md` when claim verification is needed.

`version: v1.0 | created: 2026-06-05 | status: active`

---

## 调用模式

| 模式 | 插入点 | 输入 | 输出 | 执行步骤 |
|------|--------|------|------|---------|
| **data** (数据级) | Quick Step 3→4 / Deep Phase 2→3 | sub-agent claim-tables | `cross-validation-report.md` | Gate → 归并→比对→裁决→报告 |
| **report** (报告级) | Quick Step 6 / Deep Phase 4→5 | 合成结论 + 引用列表 | `content-verification-report.md` + Claim Table | 抽取→比对→引用验证→Claim Table |

**两者关系**：数据级确保文献间数据可信，报告级确保最终输出引述准确。方法论相似（跨源比对矩阵），但输入源和插入点不同，不可互相替代。

---

# data 模式（数据级核对）

> 主 Agent 收集所有 sub-agent 的 claim-table 后执行。

## Step D0: Sub-agent 输出校验门（Validation Gate）

在归并 claims 之前，必须先校验每个 sub-agent 的输出完整性：

| 检查项 | 判断条件 | 失败处理 |
|--------|---------|---------|
| claim-table.md 存在 | 文件存在于预期目录 | 缺失 → 标记该文献 "output_missing"，跳过不阻塞 |
| claim-table 格式 | 每行含 `\|` 分隔符、至少 4 个字段、`source_ref` 非空 | 格式错误 → 重发 sub-agent 一次；二次失败则跳过该文献 |
| claim-count 匹配 | Output Contract 中的 `claim_count` 与实际条数一致 | 不一致 → 以降级标记接受（取 min） |
| gist-index.md 存在 | 文件存在且含至少一条 gist 条目 | 缺失 → 跳过该文献的分层阅读信息，仅用 claim-table |

**校验总结**：
```
Validation Gate: {N} sub-agents processed, {M} passed, {F} failed (skipped)
```
失败的 sub-agent 文献在后续核对中**不参与比对**，在核对报告中标注"文献 {id} 因输出格式错误未纳入核对"。

---

## Step D1: Claim 归并

将所有 sub-agent 返回的 claims 按**主题**归并：

| 主题 | LitA claim | LitB claim | LitC claim |
|------|-----------|-----------|-----------|
| 交换偏置增强 | Hₑₓ=250 Oe | Hₑₓ=230 Oe | — |
| 合成方法 | 水热/500°C | 共沉淀/400°C | 水热/450°C |

## Step D2: 跨源比对

| 结果分类 | 条件 | 置信度 | 处理 |
|----------|------|--------|------|
| 一致 | 多源数值/结论吻合 | ⭐⭐⭐ | 直接采用 |
| 部分一致 | 趋势一致但数值有差异 | ⭐⭐ | 标注差异范围 |
| 孤 claim | 仅单篇提及 | ⭐ | 标注"仅单源"，建议交叉验证 |
| 矛盾 | 多源数值/结论冲突 | ❌ | 引用原文裁决，无法裁决则标记争议 |

## Step D3: 矛盾裁决（回溯原文验证）

```
矛盾或疑问出现
  │
  ├→ 查 claim-table 中的原文位置（行号/段落）
  ├→ 读取 source.* 对应位置，验证 sub-agent 提取是否准确
  ├→ 确认是否在比较同一事物（相同 subject+relation）
  ├→ 核查条件差异（温度、方法不同→可能不矛盾）
  ├→ 条件相同 → 按证据层级裁定：
  │    系统综述 > 荟萃分析 > 原创研究 > 预印本
  └→ 仍无法裁定 → 标记争议，让用户判断
```

## Step D4: 输出核对报告

写入 `{research-topic}/{ana_prefix}analysis/cross-validation-report.md`。

> **{mode_prefix} 取值**：用于 investigation 目录。Quick Mode = `01-`，Deep Mode = `02-`
> **{ana_prefix} 取值**：用于 analysis 目录。Quick Mode = `02-`，Deep Mode = `03-`
>
> 原文位置回溯路径：`{research-topic}/{mode_prefix}investigation/literature/{paper_id}/source.*`

```text
## 多 Agent 信息核对报告

### 跨源一致性总览
- ✅ 一致 claims: N 条
- ⭐ 部分一致: N 条
- ⚠️ 孤 claim: N 条
- ❌ 矛盾: N 条（已裁决/待裁决）

### 矛盾详情
| Claim | 来源A | 来源B | 裁决结果 |
|-------|-------|-------|---------|
```

---

# report 模式（报告级内容审查）

> 合成/报告完成后、最终输出前执行。

**无条件执行**：只要本次会话涉及文献阅读和结论生成，本协议必须执行。
**跳过条件**：本次任务不涉及信息提取（纯搜索、纯查询等），或用户明确要求跳过。

## Step R1: Atomic Claim 抽取

将合成结果中的每条结论拆解为原子 claim。

### Claim 格式

每条 claim 遵循三元组结构：

```
subject | relation | object | source_ref | context
```

| 字段 | 说明 | 示例 |
|------|------|------|
| subject | 主体（材料/方法/现象） | Fe₃O₄/α-Fe₂O₃ 异质结构 |
| relation | 断言关系 | 显示出 |
| object | 客体/数值/结论 | 交换偏置增强（Hₑₓ = 250 Oe） |
| source_ref | 来源文献引用 | Wang 2024, Fig. 3b |
| context | 边界条件 | 在 10K、100 Oe 场冷条件下 |

### 抽取规则

- 每条 claim 自包含，不依赖上下文可理解
- 数值型 claim 必须保留原始数值和单位
- 比较型 claim 必须标注比较基准（相比什么）
- 推测型 claim 标注 `[推测]` 前缀

### 示例

```
Fe₃O₄/α-Fe₂O₃ 异质结构 | 显示出 | 交换偏置增强 Hₑₓ=250 Oe | Wang 2024 Fig.3b | 10K, 100 Oe FC
CoFe₂O₄ 纳米颗粒 | 饱和磁化强度为 | 85 emu/g | Li 2023 Table 1 | 室温, 10 kOe
界面电荷转移 | 是性能增强的 | 主因 [推测] | Wang 2024 Discussion | 未提供直接证据，基于阻抗谱推论
```

---

## Step R2: 跨 Agent/跨源比对矩阵

将抽取的 claims 按 subject+relation 进行分组比对。

### 比对矩阵

```
## Claim: {subject} {relation} {object}

| 来源 | 支持/反对 | 置信度 | 数据一致性 |
|------|-----------|--------|-----------|
| Agent A (Wang 2024) | 支持 ✅ | 高 | 数值匹配 |
| Agent B (Li 2023) | 支持 ✅ | 中 | 趋势一致但数值不同 |
| Agent C (Discussion) | — | — | 未涉及此 claim |
| 验证 Agent | — | — | — |
```

### 比对结果分类

| 结果 | 分类 | 置信度 | 处理方式 |
|------|------|--------|----------|
| 多个独立来源一致 | **一致** | ⭐⭐⭐ 高 | 直接采用 |
| 来源间数值/表述有差异 | **部分一致** | ⭐⭐ 中 | 标注差异并附双方数值 |
| 仅一个来源提及 | **孤 claim** | ⭐ 低 | 标注"仅单源"，建议交叉验证 |
| 来源间存在矛盾 | **矛盾** | ❌ 争议 | 引用原文裁决，无法裁决时标记为争议 |
| 来源自身含推测性语言 | **推测** | ⚠️ 推测 | 标注"推测性结论" |

### 矛盾裁决流程

当出现矛盾时：

```
1. 确认双方 claim 是否在比较同一事物（相同 subject+relation）
2. 核查双方 source_ref 是否为原始数据（非转引）
3. 检查条件差异（温度、浓度、方法不同→可能不矛盾）
4. 条件相同时 → 按证据层级裁定：
   系统综述 > 荟萃分析 > 原创研究 > 预印本 > 灰色文献
5. 仍无法裁定 → 标记为"争议"，让用户判断
```

---

## Step R3: 引用验证

对 claims 中出现的引文进行真实性检查。

### 验证方法（Primary → Fallback → Last-resort）

| 优先级 | 源 | 方法 | 适用场景 |
|--------|-----|------|----------|
| **Primary** | Semantic Scholar | `get_paper(doi:)` 或 `search_papers(query:)` | 有 DOI/PMID/标题+作者 |
| **Fallback** | CrossRef API | WebFetch `https://api.crossref.org/works/{doi}` | Semantic Scholar 不可用或有 DOI 但 SS 无结果 |
| **Last-resort** | WebSearch | `WebSearch("{title} {author} {year}")` | 前两者均失败时至少确认文献存在性 |

**Fallback 触发规则**：
- Semantic Scholar `get_paper` 返回空 → 自动切换到 CrossRef（如有 DOI）
- CrossRef 也无结果 → WebSearch 确认存在性
- 单条引用验证最多尝试 2 次（SS + CrossRef），超时标记"待确认"而非"未找到"

**Token 成本控制**：仅对有 DOI 的引用执行 fallback；无 DOI 的引用在 SS 失败后直接标记"⚠️ 未验证"。

### 验证结果标记

```
| 引用 | 验证状态 | 备注 |
|------|----------|------|
| Wang 2024 | ✅ 已验证 (doi:10.xxx/xxxx) | 标题匹配 |
| Li 2023 | ⚠️ 未验证（无 DOI/PMID） | 标注"引用未经 DOI 验证" |
| Zhang 2020 | ❌ 未找到 | 检查拼写或引用是否虚构 |
```

### 铁律

- **Vibe citing = FAIL**：每条引用必须独立验证，灰色地带标记为"待确认"
- 無法驗證的引用 → 从 claim table 中降级，标注"引用未经独立验证"

---

## Step R4: Claim Table 输出

最终产物是一张完整的 Claim Table。

### 输出格式

```
## 内容审查报告

### Claim Table

| # | Claim | 来源 | 置信度 | 验证状态 | 引用状态 |
|---|-------|------|--------|----------|----------|
| 1 | Fe₃O₄/α-Fe₂O₃ 显示交换偏置增强 Hₑₓ=250 Oe | Wang 2024 | ⭐⭐⭐ 高 | ✅ 一致 | ✅ 已验证 |
| 2 | 界面电荷转移是性能增强主因 | Wang 2024 Discussion | ⚠️ 推测 | ❌ 孤 claim | ✅ 已验证 |
| 3 | CoFe₂O₄ Ms=85 emu/g（室温） | Li 2023 | ⭐⭐ 中 | ✅ 部分一致 | ⚠️ 无DOI |

### 摘要

- ✅ 一致 claims: {N} 条
- ⭐ 部分一致: {N} 条
- ⚠️ 孤 claim / 推测: {N} 条
- ❌ 矛盾 / 争议: {N} 条
- ✅ 引用已验证: {N} 条
- ⚠️ 引用未验证: {N} 条

### 建议

- {建议 1: 争议点需要用户判断}
- {建议 2: 孤 claim 建议补充检索}
```

---

## Related

- `skills/paper-research/protocols/hierarchical-reading.md` — 上游分层阅读，产出 claim-table（data 模式输入）
- `skills/paper-research/protocols/quick-mode.md` — Quick Mode（Step 3→4 调用 data 模式，Step 6 调用 report 模式）
- `skills/paper-research/protocols/deep-mode.md` — Deep Mode（Phase 2→3 调用 data 模式，Phase 4→5 调用 report 模式）
- `skills/paper-research/SKILL.md` — 主 skill 入口

````
