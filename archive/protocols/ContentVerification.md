# 内容审查协议

> `[evol:protocol]` — 合成/报告草案完成后、最终输出前，对结论进行原子 claim 级交叉验证和引用真实性检查。

`version: v1.0 | created: 2026-05-22 | status: active`

---

## 触发条件

**入口**：合成阶段（Quick Mode Step 4 / Deep Mode Phase 4）完成后，最终输出前

**无条件执行**：只要本次会话涉及文献阅读和结论生成，本协议必须执行。

**跳过条件**：本次任务不涉及信息提取（纯搜索、纯查询等），或用户明确要求跳过。

---

## Step 1: Atomic Claim 抽取

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

## Step 2: 跨 Agent/跨源比对矩阵

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

## Step 3: 引用验证

对 claims 中出现的引文进行真实性检查。

### 验证方法

使用 Semantic Scholar MCP `get_paper` 工具，通过以下字段查询：

| 场景 | 查询字段 | 验证内容 |
|------|----------|----------|
| 有 DOI | `get_paper(doi: "10.xxx/xxxx")` | 标题、作者、年份是否匹配 |
| 有 PMID | `get_paper pubmed_id` | 同上 |
| 有标题+作者 | `search_papers(query: "title+author")` | 确认存在性 |
| 仅作者+年份 | 最低验证 | 仅标注"未经 DOI 验证" |

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

## Step 4: Claim Table 输出

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

## 与本 skill 的关系

本协议被 `skills/paper-research/SKILL.md` 引用。在 Quick Mode 中作为 Step 4.5，在 Deep Mode 中作为 Phase 4→Phase 5 之间的质量门。

---

## Related

- `skills/paper-research/SKILL.md` — 主 skill 文件
- `archive/protocols/HierarchicalReading.md` — 上游分层阅读协议
- `archive/protocols/SubAgentDispatch.md` — 子 agent 分发标准
