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
