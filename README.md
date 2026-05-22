# paper-research

> Claude Code Skill — 多源搜索与结构化学术研究协议

`v2.2 | 2026-05-23 | active`

---

## 一句话简介

**paper-research** 是 Claude Code 的搜索与研究 skill，覆盖从"快速查一个事实"到"系统研究一个课题"的完整需求。Quick Mode 5 分钟给出答案，Deep Mode 产出完整 APA 7.0 报告。

---

## 两种模式

| 模式 | 场景 | 流程 | 输出 |
|------|------|------|------|
| **Quick** | 问题：查一个事实、概览、验证 | 搜索→获取→分层阅读→核对→合成→回答 | Research Brief（500-1500字） |
| **Deep** | 课题：系统研究、文献综述、学术报告 | 6 Phase pipeline（Scoping→Investigation→Analysis→Composition→Review→Revision） | APA 7.0 报告（3000-8000字） |

**两种模式共享同等级可靠性**：Sub-agent 并行分层阅读、原文下载、位置索引、claim 提取、多 Agent 信息核对——不分轻重。

---

## v2.2 核心特性

### Sub-agent 并行分层阅读

多篇文献（≥2 篇）时自动分发到独立 Sub-agent 并行处理，每篇完整执行：

```
质量快检 → Episode Pagination（语义分块） → Memory Gisting → 精读 → Claim 提取
```

输出 4 个文件到 `{research-topic}/literature/{paper_id}/`：
- `source.{pdf|txt}` — 原文副本
- `quality-report.md` — 解析质量报告
- `gist-index.md` — gist 索引（含行号范围）
- `claim-table.md` — 原子 claim 表（含原文位置）

### 多 Agent 信息核对

主 agent 收集所有 sub-agent 的 claim-table 后执行 4 步核对：

```
Claim 归并 → 跨源比对 → 矛盾裁决（回溯原文验证） → 核对报告
```

每条 claim 标注置信度：一致 ⭐⭐⭐ / 部分一致 ⭐⭐ / 孤 claim ⭐ / 矛盾 ❌

### 原文下载 + 位置索引

每篇文献下载原文到项目目录，claim 表标注行号/段落编号。核对时可直接回溯到原文对应位置验证，不依赖二手转述。

### 主题目录树

每次研究自动创建独立目录，所有阶段性成果落盘为文件，其他 agent 可直接读取，不依赖主 agent 转述。

**Deep Mode（6 级）：**
```
{research-topic}/
├── 01-scoping/          ← RQ Brief + Methodology + Checkpoint
├── 02-investigation/    ← Bibliography + Source Verification + literature/
│   └── literature/      ← 精读文献原文 + sub-agent 处理成果
├── 03-analysis/         ← 核对报告 + 合成笔记
├── 04-composition/      ← 报告草稿
├── 05-review/           ← Editorial/Ethics/Devil's Advocate
└── report/              ← 最终 APA 报告 + 参考文献
```

---

## 快速开始

### 触发词

直接说以下任意关键词即可激活 skill：`帮我调研` `搜索` `查一下` `research` `literature review` `深度研究` `这个结论可靠吗`

### Quick Mode 示例

```
"帮我查一下 Fe₃O₄ 交换偏置效应最新研究进展"
```

### Deep Mode 示例

```
"系统调研 Fe₃O₄/α-Fe₂O₃ 异质结构的合成方法与磁性能，出 APA 报告"
```

---

## 协议体系

| 协议 | 说明 |
|------|------|
| [skills/paper-research/SKILL.md](skills/paper-research/SKILL.md) | 主 skill 文件，Quick/Deep 完整流程 |
| [archive/protocols/HierarchicalReading.md](archive/protocols/HierarchicalReading.md) | 分层阅读协议（ReadAgent 风格 4 步） |
| [archive/protocols/ContentVerification.md](archive/protocols/ContentVerification.md) | 内容审查协议（原子 claim 比对 + 引用验证） |

---

## 版本历史

| Date | Version | Change |
|:---|:---|:---|
| 2026-05-23 | **v2.2** | Sub-agent parallel hierarchical reading + multi-agent cross-validation + original text download with position indexing + topic directory tree management |
| 2026-05-22 | v2.1 | Add hierarchical reading + content verification across Quick/Deep modes |
| 2026-05-07 | v2.0 | Merged deep-research (13-agent academic pipeline) as Deep Mode |
| 2026-05-04 | v1.0 | Initial create |
