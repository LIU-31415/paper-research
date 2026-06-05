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
