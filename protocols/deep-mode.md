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
