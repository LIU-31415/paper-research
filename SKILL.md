---
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

执行任何模式前先读 [研究执行门槛](protocols/research-gates.md)。继续项目时先核对主题目录research-state.md及现行源文件；所有模式共用项目隔离、历史有效性、独立研究及结论阅读用途规则。

> **Source of truth for all search/research workflows.** 主入口，根据用户需求自动路由到对应模式。

`version: v4.1 | created: 2026-05-04 | updated: 2026-10-12 | status: active`

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

1. **核对上下文后判断模式**：先执行研究门槛，确认当前项目/状态和历史材料有效性，再根据 Mode Selection 表判断用户意图

2. **加载协议**：
   - 判断为 **Quick** → 立即 Read `protocols/quick-mode.md`，严格遵循 Step 1-8
   - 判断为 **Deep** → 立即 Read `protocols/deep-mode.md`，严格遵循 Phase 1-6

3. **执行过程中按需加载跨模式协议**：
   - 获取到文献全文且满足条件时 → Read `protocols/hierarchical-reading.md`
   - 收集到 sub-agent claim-table 后 → Read `protocols/verification.md`
   - 合成/报告完成后，最终输出前 → Read `protocols/verification.md`

4. **铁律**：
   - 任何情况下不跳过协议步骤
   - 不做 vibe citing，每条引用独立验证
   - 每步完成后确认启动条件和完成清单

---

## 极简搜索（无需加载子文档）

极简仅省略模式文档，不省略研究门槛；无需项目条件的一次事实查询不强加样本/仪器要求。

处理"查一个事实/快速验证"等简单任务时，可以不加载 `quick-mode.md`，直接执行以下精简流程：

```
用户查询 → 并行 WebSearch(1-2 queries) → WebFetch top 3 → 交叉比对 → 输出结果
```

**适用条件**：用户问题不需要学术文献、不涉及多源 cross-validation、不需要长篇合成。
**不适用**：任何涉及"研究/综述/论文/文献/可靠性验证"的请求 → 必须走完整 Mode Routing 加载子文档。

---

## Protocol Index

所有模式首先加载 [research-gates.md](protocols/research-gates.md)，该门槛不依赖是否取得全文或是否启用sub-agent。

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

**跨模式切换映射**：从 Quick 切换到 Deep 时，`01-` 目录前缀不变（仅复用通过研究门槛有效性检查的 investigation），但 `02-`（analysis）在 Deep 中对应 `03-`。切换时需创建 Deep Mode 缺失目录（`01-scoping/`, `04-composition/`, `05-review/`, `06-report/`），**不重命名已有目录**。

### 变量定义（子文件参考）

- `protocols/hierarchical-reading.md` 定义了 `{mode_prefix}` 和 `{ana_prefix}` 的具体取值
- `protocols/verification.md` 定义了 `{mode_prefix}` 和 `{ana_prefix}` 及原文回溯路径

---

## Version History

| Date | Version | Change |
|:---|:---|:---|
| 2026-10-12 | **v4.1** | 统一项目状态与历史复用、独立研究判断、阅读用途及claim支撑门槛；修复入口frontmatter分隔符 |

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

