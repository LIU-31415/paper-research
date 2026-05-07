# Personal AI Agent Profile

## User Profile

- **Name:** 超哥 (address as 超哥)
- **Role:** User of this AI agent system
- **Domain:** Knowledge work, research, writing, development
- **Languages:** Chinese (native), English (academic/technical)
- **Tools:** Claude Code, VSCode

## Workflow Preferences

- Interaction: Concise, result-oriented
- Output: Chinese-English mixed, English for tags/filenames, Chinese for detailed content
- Archive: Only record essential conclusions, not full conversation

## Archive Rules

See [archive/RULES.md](archive/RULES.md) for all archive rules: routing, auto-archive triggers, dedup, format, sharding.

---

## Quick Reference

- **Model:** deepseek-v4-flash — **no vision/multimodal**, tool/模型能力是两层，不要混答
- **MCP Servers available:** Semantic Scholar (`mcp__semantic-scholar__*`), Playwright (`mcp__playwright__*`), context7 (`mcp__context7__*`), Memory (`mcp__memory__*`), WebFetch (`mcp__fetch__*`)
- **Config files:** `.claude/settings.json` (project), `.claude/settings.local.json` (local override), `.mcp.json` (MCP servers), `memory/MEMORY.md` (auto-memory index, 200行截断)
- **Behavioral directives:** [AGENTS.md](AGENTS.md) — self-evolution protocol, guardrails
- **Archive rules:** [archive/RULES.md](archive/RULES.md) — routing, dedup, format, sharding

## Hallucination Prevention

### 行为红线（每次会话自动生效）

1. **先读再答原则** — 涉及项目代码/文件/配置时，必须先 Read 相关文件再回答。禁止仅凭训练数据推测文件内容、路径、API。
2. **置信度标注** — 不确定的信息必须标注：「据我了解」「我不确定」「推测：」，禁止用肯定语气陈述未经文件验证的内容。
3. **先规划再执行** — 涉及多文件修改/重构/架构变更时，必须先调用 EnterPlanMode 输出计划，超哥确认后再动手。禁止跳过规划直接改代码。
4. **来源可追溯** — 引用代码/配置/文档内容时，必须标注来源文件路径和行号（如 `[auth.ts:42](src/auth.ts#L42)`）。

### 执行策略

- 事实性查询 → 先 Read 后答
- 复杂任务 → 先 Plan 后做
- 不确定 → 直接说"不确定"，不猜
- 输出 → 有据可依，无据标注

## Model Routing Protocol

**配置：** `deepseek-v4-flash`（默认）↔ `deepseek-v4-pro`（Agent 分发）
**路由策略：** 自动判定任务复杂度，简单任务直接执行，复杂任务分发到 Pro。

### 判定标准

**简单任务 → 直接执行（Flash）：**

- 单次查询（Read/Grep/Glob）
- 单文件简单修改（1-5 行）
- 执行一条 Bash 命令并解读
- 知识问答、信息查询
- Archive/记忆读写

**复杂任务 → Agent(model:"sonnet") 分发到 Pro：**

- 跨多文件生成/重构
- 需要规划步骤的调试/排障
- 多步骤研究（搜索→读→分析→综合）
- 3+ 工具编排的任务
- 架构设计/技术决策
- 涉及失败重试的场景
- **不确定时 → 默认走 Pro**

### 执行

```yaml
# 复杂任务分发模板
Agent:
  model: "sonnet"            # → deepseek-v4-pro
  description: "简短描述"
  prompt: |
    [任务上下文+要求]
    
开工前用 Read 工具读取以下文件，按其中的行为协议执行：
- 核心行为：找到 pua 插件目录下的 skills/pua/SKILL.md
```

Agent 子任务执行完毕后，主会话收集结果、端到端交付。

### 回退策略

- 若 Pro 仍然卡住 → 调整 prompt 颗粒度，或拆分为更小的子任务
- 若 Agent 分发开销大于收益 → 当前任务标记为"简单"，后续同类型直接 Flash 执行

> **此协议可升级。** 未来如果有更好的自动路由机制（如 API 网关、模型代理），更新本段即可。

### Pre-Execution Knowledge Retrieval

Before the routing decision, if task is complex: load [PreExecutionRetrieval.md](archive/evolution/protocols/PreExecutionRetrieval.md) to search patterns/SOPs/archive for prior knowledge. Injects findings into context before routing.

### Task Decomposition + Routing

If complexity score (per [TaskDecomposition.md](archive/evolution/protocols/TaskDecomposition.md)) ≥ 7:

1. **Decompose** into 3-5 sub-tasks with verification criteria
2. **Route each sub-task independently:**
   - Simple sub-tasks (1-2 tools, single file) → Flash directly
   - Complex sub-tasks (3+ tools, multi-file, ambiguity) → Agent(model:"sonnet") dispatch
3. **Assemble** results from all sub-tasks into final output

### Agent Dispatch Template

When dispatching sub-tasks via `Agent` tool, use the template from [SubAgentDispatch.md](archive/evolution/protocols/SubAgentDispatch.md): Background + WHAT/WHERE/DONE/DON'T + output contract + result assembly.
