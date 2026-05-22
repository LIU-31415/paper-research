---
name: paper-research
description: >
  Multi-source search & research protocol. INVOKE WHENEVER the user wants to: 
  research a topic, search for academic papers, lookup information online, 
  fact-check a claim, get a quick synthesis, or says "帮我调研", "搜索", "查一下", 
  "research", "literature review", "what's the latest on", "这个结论可靠吗", "帮我查",
  "深度研究", "帮我想想", "引导我的研究". 
  Two modes: Quick (multi-source search + synthesis for fast answers) 
  and Deep (structured multi-agent academic research pipeline with Socratic guidance, 
  systematic review, and APA reports). SKIP only for simple file lookups.
---

# Research Protocol

> **Source of truth for all search/research workflows.**

`version: v2.2 | created: 2026-05-04 | updated: 2026-05-23 | status: active`

---

## Mode Selection

| Your Need | Mode | What You Get |
|-----------|------|-------------|
| Quick lookup, fact-check, overview | **Quick** ↓ | Multi-source search + synthesis, 5 min |
| Deep academic research, systematic review | **Deep** → | Structured multi-agent pipeline, full APA report |

**Unsure?** Start with Quick. If results show the topic needs deeper treatment, suggest switching to Deep.

---

# Quick Mode (Original Perplexity-Style)

Quick multi-source search & synthesis protocol for fast, reliable answers.

## Core Mechanism

```
Single Query
    │
    ├→ Query Expansion (1 question → 3-5 variants)
    │
    ├→ Parallel Search
    │   ├─ WebSearch (general)
    │   ├─ Google Scholar (WebFetch)  [if academic]
    │   └─ Semantic Scholar            [if academic]
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

## Step 1: Query Expansion

**Expand user query into 3 search variants** covering different angles:

| Dimension | Strategy | Example |
|-----------|----------|---------|
| Language | Chinese + English | "AI agents impact jobs" / "AI 智能体 就业影响" |
| Perspective | Academic + Industry | "deep learning scaling laws" / "AI industry trends 2026" |
| Counterpoint | Negative/limiting condition | "AI automation job displacement concerns" |

**Rules:**
- Non-academic → WebSearch only
- Academic → WebSearch + 1-2 academic MCPs in parallel
- Mixed → all sources

## Step 2: Parallel Search

### Trigger Matrix

| Topic Type | Search Combo | When |
|-----------|-------------|------|
| **Academic/Literature** | WebSearch + Google Scholar + Semantic Scholar | User doing lit review, or topic has domain terminology |
| **Technical/Coding** | WebSearch (primary) + context7 (docs) | Framework/lib/tool usage |
| **General/News** | WebSearch × 3 queries | Industry news, current events |
| **Mixed/Unsure** | WebSearch first, then decide if academic MCP needed | Default |

### Parallel Rules

- **Concurrent** (multiple tool calls in one message), no queue
- Return **top 5-10 results** per source
- Source fails → down-weight, continue

## Step 3: Content Fetching

| Source | Method |
|--------|--------|
| WebSearch | Link → WebFetch for abstract or full text |
| Semantic Scholar | `get_paper` for abstract, `get_paper_fulltext` if needed |
| Google Scholar | WebFetch with precise quoted queries |

**Don't fetch full text blindly** — only when abstract is insufficient.

> **获取到全文后** → 判断文献数：≥2 篇则创建 `{research-topic}/` 目录（目录名由查询关键词自动生成），启动 Sub-agent 并行分层阅读（每篇完整执行质量快检→分块→gist→精读→claim 提取，输出 4 文件到 `literature/{paper_id}/`），主 agent 收集后执行 [多 Agent 信息核对](#多-agent-信息核对跨模式共享)；1 篇则主 agent 单线执行 [文献处理: 分层阅读](#文献处理)。

## Step 3.5: Cross-Validation

Internal quality check before synthesis (not shown in output).

> **有多 Agent 核对报告时**：先读取 `{research-topic}/analysis/cross-validation-report.md`，将核对结果（一致/部分/矛盾/孤 claim）作为 Cross-Validation 的优先输入。核对只看文献间的数据一致性，Cross-Validation 看所有来源（文献 + WebSearch + 其他）的综合可信度。两者互补，不替代。

| Situation | Action |
|-----------|--------|
| 核对报告已有结论 | 以核对报告为准，Cross-Validation 补充非文献来源判断 |
| Multi-source agreement | Adopt, high confidence |
| Conflict with multi-source on one side | Trust multi-source side |
| Both single-source | authority > recency > volume; flag if still uncertain |
| Single source only, no cross-ref | Downgrade, note limitation in output |
| No source | State no direct evidence |
| Time-dependent conclusions | Use latest, note timeline |

## Step 4: Synthesis

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

---

## Step 4.5: Content Verification

在合成之后、输出之前，对合成结果的每条结论进行内容审查。仅在本次会话涉及文献阅读时执行。

> **详细协议** → `archive/protocols/ContentVerification.md`
>
> **与多 Agent 信息核对的关系**：核对（Step 3→3.5 之间）= 跨文献原始 claim 一致性检查（数据级），内容审查（Step 4.5）= 报告中引用的 claim 验证（报告级，含引用真实性检查）。两者层次不同但互为补充——核对确保文献间数据可信，内容审查确保最终输出引述准确。

| 步骤 | 说明 |
|------|------|
| Claim 抽取 | 将每条结论拆解为原子 claim (subject, relation, object) |
| 跨 Agent/跨源比对 | 一致→高置信度；矛盾→标记争议，引用原文裁决；孤 claim→低置信度 |
| 引用验证 | 每条引用检查 DOI/PMID 真实性（使用 Semantic Scholar） |
| 输出 | Claim Table：每条声明的来源、置信度、验证状态 |

### Quick Mode 目录树

Quick Mode 采用 3 级简化目录，但 `literature/` 子结构与 Deep Mode **完全一致**。Content Fetching 后由主 agent 根据查询关键词自动生成 `{research-topic}` 目录名（英文短横线格式）。

```
{research-topic}/
├── investigation/
│   ├── search-results.md        ← 搜索结果汇总 + 选择依据
│   └── literature/              ← 精读文献（与 Deep 结构完全一致）
│       ├── paper-1/
│       │   ├── source.{pdf|txt}
│       │   ├── quality-report.md
│       │   ├── gist-index.md
│       │   └── claim-table.md
│       ├── paper-2/
│       └── paper-3/
├── analysis/
│   ├── cross-validation-report.md  ← 多 Agent 核对报告
│   └── synthesis-notes.md         ← 核心发现 + 源要点
└── report/
    └── research-brief.md          ← 最终简短回答（500-1500字）
```

---

## Step 5: Follow-up

Auto-generate 3 follow-up directions:

- **Deeper dive**: sub-topic based on current results
- **Verify**: "Does this hold under X condition?"
- **Extend**: "What are related directions?"

---

# 文献处理（跨模式共享）

当本次会话涉及上传或获取文献全文时（无论 Quick 还是 Deep 模式），执行以下文献处理流程。

> **详细协议** → `archive/protocols/HierarchicalReading.md`

## 入口判断

| 条件 | 动作 |
|------|------|
| 单篇文献 > 8000 字 | 启动分层阅读 |
| 多篇合计 > 15000 字 | 启动分层阅读 |
| 来源为 PDF（pdftotext 转换） | 启动分层阅读 |
| 用户要求精读 | 启动分层阅读 |
| 多篇精读文献 ≥ 2 篇 | 启动 Sub-agent 并行分层阅读，每篇独立分发（Quick/Deep 通用） |
| 单篇 < 3000 字且非 PDF 来源 | 直接精读，跳过分层阅读 |

## 分层阅读流程

```
文献全文（N 篇）
  │
  ├→ 文献数 ≥ 2?
  │   │
  │   ├── No → 单线处理
  │   │     ├→ Step 1: 解析质量快检
  │   │     ├→ Step 2: Episode Pagination（语义分块）
  │   │     ├→ Step 3: Memory Gisting
  │   │     └→ Step 4: Interactive Lookup（按需精读）
  │   │
  │   └── Yes → Sub-agent 并行（Quick/Deep 通用，同模板）
  │         ├─ Agent(litA) → 文献A: 质量快检→分块→gist→精读→claim表+原文
  │         ├─ Agent(litB) → 文献B: 同上
  │         └─ Agent(litC) → 文献C: 同上
  │               │
  │               └→ 各输出 4 文件到 {research-topic}/literature/{paper_id}/
  │
  └→ 主 agent 收集 → 多 Agent 信息核对（跨源比对→矛盾裁决→核对报告）
```

## Sub-agent 并行模式（Quick/Deep 通用）

当文献数 ≥ 2 篇时，启动 Sub-agent 并行处理。每篇文献独立分发到一个 sub-agent，执行完整分层阅读。

### 分派模板

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
    1. 解析质量快检，输出 quality-report.md
    2. Episode Pagination，按章节/段落语义分块，标注每块的行号范围
    3. Memory Gisting，每块一句 gist，输出 gist-index.md
    4. Interactive Lookup，精读所有块（单篇全部精读）
    5. Claim 提取，输出 claim-table.md（格式见 ContentVerification.md），
       每条 claim 必须标注原文位置（行号 / 段落编号）

    ### WHERE
    文献路径：{path}
    输出目录：{research-topic}/literature/{paper_id}/

    ### DONE
    输出四个文件：
    - source.{pdf|txt} ← 原文副本
    - quality-report.md ← 解析质量报告
    - gist-index.md ← gist 索引（含行号范围）
    - claim-table.md ← 原子 claim 表（含原文位置）

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

### 文件隔离

- 每个 sub-agent 写入独立子目录 `{research-topic}/literature/{paper_id}/`
- 各 sub-agent 之间无文件冲突
- 主 agent 按目录读取所有成果进行汇总

### 并发限制

- 单轮最多 3 个 sub-agent 并行
- 文献数 > 3 篇：分批次并行（每批 ≤3），或优先选择最相关的 3 篇

## 跨模式调用点

| 模式 | 分层阅读插入点 | 核对机制插入点 | 内容审查插入点 |
|------|---------------|---------------|---------------|
| Quick Mode | Content Fetching 之后（Step 3 → 分层阅读 → Step 3.5，≥2篇走并行） | 分层阅读之后（核对 → Step 3.5） | Synthesis 之后（Step 4.5） |
| Deep Mode | Investigation 之后（Phase 2 → 分层阅读 → Phase 3，≥2篇走并行） | 分层阅读之后（核对 → Phase 3） | Composition 之后（Phase 4 → 内容审查 → Phase 5） |

---

# 多 Agent 信息核对（跨模式共享）

主 agent 收集所有 sub-agent 的 claim-table 后执行。**Quick 和 Deep 均执行完整 4 步流程。**

> 核对过程中可随时通过原文位置索引回溯到 `{research-topic}/literature/{paper_id}/source.*` 中的具体行号，验证 sub-agent 的 claim 提取是否准确。

## Step 1: Claim 归并

将所有 sub-agent 返回的 claims 按**主题**归并：

| 主题 | LitA claim | LitB claim | LitC claim |
|------|-----------|-----------|-----------|
| 交换偏置增强 | Hₑₓ=250 Oe | Hₑₓ=230 Oe | — |
| 合成方法 | 水热/500°C | 共沉淀/400°C | 水热/450°C |

## Step 2: 跨源比对

| 结果分类 | 条件 | 置信度 | 处理 |
|----------|------|--------|------|
| 一致 | 多源数值/结论吻合 | ⭐⭐⭐ | 直接采用 |
| 部分一致 | 趋势一致但数值有差异 | ⭐⭐ | 标注差异范围 |
| 孤 claim | 仅单篇提及 | ⭐ | 标注"仅单源"，建议交叉验证 |
| 矛盾 | 多源数值/结论冲突 | ❌ | 引用原文裁决，无法裁决则标记争议 |

## Step 3: 矛盾裁决（回溯原文验证）

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

## Step 4: 输出核对报告

写入 `{research-topic}/analysis/cross-validation-report.md`：

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

# Deep Mode (Academic Research Pipeline)

When user needs rigorous academic research, activate the structured multi-phase pipeline below.

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

| Agent | Output |
|-------|--------|
| **Research Question Agent** | RQ Brief → `01-scoping/research-question.md` — FINER criteria, scope boundaries, 2-3 sub-questions |
| **Research Architect** | Methodology Blueprint → `01-scoping/methodology-blueprint.md` — paradigm, method, data strategy |
| **Devil's Advocate** | Checkpoint → `01-scoping/devil-advocate-check.md` — RQ answerable? Method appropriate? → PASS/REVISE |

**User confirmation required before Phase 2.**

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
└── report/           ← 最终报告 + 参考文献
```

> Phase 1 输出文件写入时即指定对应目录路径。

## Phase 2: Investigation

| Agent | Output |
|-------|--------|
| **Bibliography Agent** | Bibliography → `02-investigation/bibliography.md` — Systematic search, annotated bibliography (APA 7.0) |
| **Source Verification Agent** | Verification → `02-investigation/source-verification.md` — Evidence hierarchy grading, predatory journal check, CoI flagging |

> **获取到文献全文后** → 判断文献数：≥2 篇则启动 Sub-agent 并行分层阅读（每篇完整执行质量快检→分块→gist→精读→claim 提取 + 原文下载，输出 4 文件到 `02-investigation/literature/{paper_id}/`），主 agent 收集后执行下方核对步骤；1 篇则主 agent 单线执行 [文献处理: 分层阅读](#文献处理)，输出到同一目录结构。

### Phase 2→3: 多 Agent 信息核对

主 agent 收集所有 sub-agent 的 claim-table 后，执行完整 [多 Agent 信息核对](#多-agent-信息核对跨模式共享) 流程（4 步：归并→比对→裁决→报告），核对报告输出到 `03-analysis/cross-validation-report.md`。

## Phase 3: Analysis

| Agent | Output |
|-------|--------|
| **Synthesis Agent** | Synthesis → `03-analysis/synthesis-notes.md` — Cross-source integration, contradiction resolution, gap analysis（基于核对后的可信 claims） |
| **Devil's Advocate** | Checkpoint → `03-analysis/devil-advocate-check.md` — cherry-picking? confirmation bias? logic valid? → PASS/REVISE |

## Phase 4: Composition

| Agent | Output |
|-------|--------|
| **Report Compiler** | Draft → `04-composition/draft-report.md` — Full APA 7.0 report: Title → Abstract → Intro → Method → Findings → Discussion → References |

> **报告草稿完成后** → 执行[文献处理: 内容审查](#文献处理)对结论进行 claim 级交叉验证和引用真实性检查。审查结果作为 Phase 5 Review 的输入。

## Phase 5: Review

| Agent | Output |
|-------|--------|
| **Editor in Chief** | Review → `05-review/editorial-review.md` — Originality, rigor, evidence → ACCEPT/REVISE/REJECT |
| **Ethics Review** | Review → `05-review/ethics-review.md` — AI disclosure, attribution, dual-use → CLEARED/BLOCKED |
| **Devil's Advocate** | Review → `05-review/final-devil-advocate.md` — Final vulnerability scan → PASS/REVISE |

**IRON RULES:**
- Devil's Advocate CRITICAL issues block progression
- Ethics BLOCKED halts delivery
- Max 2 revision loops; remaining issues → "Acknowledged Limitations"

## Phase 6: Revision

Report compiler addresses feedback, resolves conditions, produces final report.

Output → `report/research-report.md` + `report/references.md`

## Socratic Mode

5-layer guided dialogue for when user has vague ideas but no clear research question:

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

---

## Version History

| Date | Version | Change |
|:---|:---|:---|
| 2026-05-23 | v2.2 | Sub-agent parallel hierarchical reading + multi-agent cross-validation + original text download with position indexing + topic directory tree management (Quick/Deep share same reliability) |
| 2026-05-22 | v2.1 | Add hierarchical reading + content verification across Quick/Deep modes |
| 2026-05-07 | v2.0 | Merged deep-research (13-agent academic pipeline) as Deep Mode |
| 2026-05-05 | v1.5 | Remove arXiv/OpenAlex/PubMed, unify Semantic Scholar |
| 2026-05-04 | v1.4 | Source reliability matrix + OpenAlex fallback |
| 2026-05-04 | v1.3 | Google Scholar (WebFetch) integration |
| 2026-05-04 | v1.2 | Restore Cross-Validation internal flow |
| 2026-05-04 | v1.1 | Streamline output format |
| 2026-05-04 | v1.0 | Initial create |
