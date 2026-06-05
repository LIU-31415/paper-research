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
