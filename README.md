# paper-research

> Claude Code Skill — 多源搜索与结构化学术研究协议

`v4.0 | 2026-06-05 | active`

---

## 一句话简介

**paper-research** 是 Claude Code 的搜索与研究 skill，覆盖从"快速查一个事实"到"系统研究一个课题"的完整需求。主入口 [SKILL.md](SKILL.md) 负责智能路由，自动加载对应模式文档。

---

## ⚠️ 使用前提（必读）

> **本 Skill 依赖 Claude Code 的 MCP（Model Context Protocol）生态。以下条件不满足则无法正常运行。**

### 所需环境

| 组件 | 来源 | 说明 |
|------|------|------|
| **Claude Code** | [安装指南](https://docs.anthropic.com/en/docs/claude-code) | 运行本 Skill 的 CLI 环境 |
| **WebSearch / WebFetch** | Claude Code **内置** | 无需额外配置，开箱即用 |
| **Semantic Scholar MCP** | 需在 `.mcp.json` 中配置 | 学术搜索核心依赖，需 [API Key](https://api.semanticscholar.org/)（免费） |
| **context7 MCP** | 需在 `.mcp.json` 中配置 | 技术文档查询（框架/库/SDK），非必需但建议配 |

### Semantic Scholar MCP 配置示例

在项目根目录（或 `~/.claude/`）的 `.mcp.json` 中添加：

```json
{
  "mcpServers": {
    "semantic-scholar": {
      "command": "npx",
      "args": ["@semantic-scholar/mcp-server"],
      "env": {
        "S2_API_KEY": "你的 API Key"
      }
    },
    "context7": {
      "command": "npx",
      "args": ["@context7/mcp-server"]
    }
  }
}
```

> 🔑 Semantic Scholar API Key 免费申请：[https://api.semanticscholar.org/](https://api.semanticscholar.org/)

### 使用约定

执行过程中会在当前工作目录下创建以研究主题命名的文件夹存放产出物（如 `fe3o4-heterostructure-review/01-investigation/`），请确保有写入权限。

---

## 两种模式

| 模式 | 场景 | 输出 |
|------|------|------|
| **Quick** | 查事实、概览、验证 | Research Brief（500-1500字） |
| **Deep** | 系统研究、文献综述、学术报告 | APA 7.0 报告（3000-8000字） |

两种模式共享同等级可靠性：Sub-agent 并行分层阅读、原文下载、位置索引、claim 提取、多 Agent 信息核对。

---

## 快速开始

### 触发词

说 `研究一下` `帮我调研` `查资料` `查一下` `搜索` `调研` `深度研究` `文献搜索` `论文调研` `这个结论可靠吗` `查文献` 等即可自动触发。

### Quick 示例
```
"帮我查一下 Fe₃O₄ 交换偏置效应最新研究进展"
```

### Deep 示例
```
"系统调研 Fe₃O₄/α-Fe₂O₃ 异质结构的合成方法与磁性能，出 APA 报告"
```

---

## 协议体系

| 文件 | 说明 |
|------|------|
| [SKILL.md](SKILL.md) | **主入口** — Mode Selection + 路由 + Protocol Index（~80行） |
| [protocols/quick-mode.md](protocols/quick-mode.md) | Quick Mode 完整 Step 1-8（含 Keyword Engineering、Fan-Out、Tool Preloading） |
| [protocols/deep-mode.md](protocols/deep-mode.md) | Deep Mode 完整 Phase 1-6 + Socratic、Anti-Patterns、Operational Modes |
| [protocols/hierarchical-reading.md](protocols/hierarchical-reading.md) | 分层阅读 + Sub-agent 并行分发（跨模式共享） |
| [protocols/verification.md](protocols/verification.md) | 统一验证协议：data 模式（数据级核对）+ report 模式（报告级审查） |
| [agents/literature-reader.md](agents/literature-reader.md) | Sub-agent 分层阅读分派模板 |
| [agents/bibliography-agent.md](agents/bibliography-agent.md) | Bibliography 搜索扇出规范 |

**路由机制**：SKILL.md 根据用户意图自动判断 Quick/Deep → Read 对应子文档 → 按需加载跨模式协议。详见 [SKILL.md > Mode Routing](SKILL.md#mode-routing--必须遵循)。

---

## 版本历史

| Date | Version | Change |
|:---|:---|:---|
| 2026-06-05 | **v3.0** | 文档拆分重构：SKILL.md 仅保留路由；Quick/Deep 拆为独立子文档；跨模式协议独立文件化 |
| 2026-06-04 | **v2.8** | Dynamic Workflows 并行拓扑 + P0-P4 修复（description 优化、启动条件、检查清单、规则索引） |
| 2026-05-23 | **v2.2** | Sub-agent 并行分层阅读 + 多 Agent 信息核对 + 原文位置索引 |

完整历史见 [SKILL.md](SKILL.md#version-history)。
