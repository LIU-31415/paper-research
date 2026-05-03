# AI Agent 记忆复利系统 — 项目需求文档 (PRD)

## 1. 项目背景

用户在日常使用 AI 助手（Claude Code）进行查资料、写文本、编程等任务时，每次会话都是"一次性"的——AI 不了解用户的背景、偏好和过往产出。这导致：

- 每次会话需重复描述背景信息
- 过往的知识和产出无法沉淀
- AI 无法"越用越懂你"

## 2. 项目目标

在 `C:\Users\LIU\Desktop\agent` 工作区打造一个**越用越好用的 AI Agent 系统**，核心指标：

1. **知识沉淀**：每次对话的精华内容被自动记录，在 VSCode 侧栏形成可见的存档
2. **复利效应**：AI 通过积累的知识逐步了解用户背景和需求，回答越来越精准
3. **低开销**：Token 开销可控（典型会话 4-9K），不加载不相关内容

## 3. 用户故事

| 角色 | 场景 | 期望 |
|------|------|------|
| 研究者 | 查资料、文献调研 | 研究笔记自动保存，下次查相关话题时能引用之前的发现 |
| 写作者 | 论文、文本写作 | 写作输出存档，风格和知识积累复用 |
| 开发者 | 编写代码、解决问题 | 技术方案和最佳实践沉淀，不重复解决同一问题 |
| 普通用户 | 各种任务 | AI 了解背景，不需要每次都自我介绍 |

## 4. 功能需求

| 功能 | 优先级 | 描述 |
|------|--------|------|
| 精华存档 | P0 | AI 自动将对话中的关键结论写入 Markdown 文件 |
| 主题分类 | P0 | 按研究/写作/技术/工具 4 个主题组织知识 |
| VSCode 可见 | P0 | 存档文件出现在 VSCode 左侧文件侧栏 |
| 用户画像 | P0 | CLAUDE.md 记录用户角色、领域、偏好 |
| 主题路由 | P0 | 按任务类型定向加载对应知识，不加载无关内容 |
| 去重检测 | P1 | 已有内容不重复存档，矛盾时提示确认 |
| 知识图谱 | P1 | MCP 知识图谱记录实体间语义关系 |
| 会话时间轴 | P1 | 按日期组织的会话精华记录 |
| 混合存档 | P2 | AI 自动存档 + 用户手动触发 |
| 全量模式 | P2 | 用户可要求 AI 基于全部知识回答 |

## 5. 架构设计

### 5.1 四层记忆模型

```
Layer 0: CLAUDE.md              — 始终注入，用户画像 + 行为规则 (~1-2K)
Layer 1: archive/topics/        — 按需检索，主题知识库 (~3-6K)
Layer 2: MCP Knowledge Graph    — 语义关联，实体关系网络
Layer 3: archive/sessions/      — 仅显式查询，历史会话记录
```

### 5.2 渐进式上下文注入

```
每次会话开始时：
  Level 0 [始终注入] CLAUDE.md → 用户画像、核心规则、存档路径
     ↓
  Level 1 [按需检索] Archive/topics/ → 匹配当前任务主题的知识
     ↓
  Level 2 [语义关联] MCP Knowledge Graph → 发现跨主题连接
     ↓
  Level 3 [仅显式查询] Archive/sessions/ → 历史详情
```

### 5.3 主题路由规则

| 任务类型 | 加载文件 | 不加载文件 |
|---------|---------|-----------|
| 写作 | Writing-Outputs.md、（可加 Research-Notes.md） | Tech-Solutions.md, Tool-Config.md |
| 研究查资料 | Research-Notes.md | Writing, Tech, Tool |
| 技术/编程 | Tech-Solutions.md + Tool-Config.md | Research, Writing |
| 交叉任务 | 先读 INDEX.md 再判断 | — |
| 全量模式（用户指定） | 所有 topic | — |

### 5.4 Token 预算

| 层级 | 位置 | Token 预算 |
|------|------|-----------|
| 核心 | CLAUDE.md | ~1-2K |
| 工作 | archive/topics/ | ~3-6K |
| 存档 | archive/sessions/ | ~0K（不预加载） |
| **总计** | | **~4-9K** |

## 6. 文件夹结构

```
agent/
├── PRD.md                          # 本文件：项目需求文档
├── CLAUDE.md                       # Layer 0: AI 行为指南 + 用户画像（核心）
├── archive/                        # Layer 1+3: 知识存档根目录
│   ├── INDEX.md                    # 目录索引（自动维护）
│   ├── sessions/                   # 按日期排列的会话精华
│   │   └── YYYY-MM-DD_Title.md
│   ├── topics/                     # 按主题聚合的知识库
│   │   ├── Research-Notes.md       # 研究资料
│   │   ├── Writing-Outputs.md      # 写作输出
│   │   ├── Tech-Solutions.md       # 技术方案
│   │   └── Tool-Config.md          # 工具配置
│   └── references/                 # 外部引用
└── .vscode/
    └── settings.json               # Markdown 预览优化
```

## 7. 设计原则

1. **CLAUDE.md = 核心 20%** — 只放最重要信息，其余在 archive/ 中按需检索
2. **记录成本 < 检索收益** — AI 自动识别精华，用户只需确认；格式极度精简
3. **渐进式详细度** — 核心始终注入 / 工作按需检索 / 存档仅显式查询
4. **精确主题路由** — 任务类型定向加载，不加载不相关内容
5. **去重与冲突检测** — 已有内容不重复，矛盾提示确认
6. **知识飞轮循环** — 执行 → 反思 → 存档 → 更新 → 更精准

## 8. 精华条目格式

```markdown
# YYYY-MM-DD: Title

`tags: #tag1 #tag2`

**结论：** 一句话核心发现。

- 要点 1
- 要点 2

→ 相关：[Topic](topics/xxx.md) · [Graph: entity_name]
```

## 9. 实施步骤

| Step | 内容 | 产出文件 |
|------|------|---------|
| 0 | 创建 PRD.md | PRD.md |
| 1 | 创建 CLAUDE.md（用户画像 + 规则） | CLAUDE.md |
| 2 | 初始化 MCP 知识图谱 | 知识图谱实体 |
| 3 | 创建 archive/ 目录结构 | INDEX.md + 4 个 topic 文件 |
| 4 | 创建第一篇存档 | sessions/ + topics/ 条目 |
| 5 | 配置 VSCode | .vscode/settings.json |

## 10. 验收标准

- [ ] VSCode 打开 agent 目录，侧栏可见 `archive/` 文件夹及其内部文件
- [ ] `CLAUDE.md` 包含用户画像和完整的归档指令
- [ ] MCP 知识图谱中存在至少 3 个实体和 3 条关系
- [ ] 提出研究查询，AI 自动创建存档条目并更新知识图谱
- [ ] 提出写作任务，AI 只加载 Writing-Outputs.md（不加载 Tech-Solutions.md）
- [ ] 新会话中 AI 能根据 CLAUDE.md 了解用户背景
