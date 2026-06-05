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
