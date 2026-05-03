# 2026-05-03: Self-Evolution Setup & Permission Config

`tags: #evolution #self-improvement #permissions #settings`

**结论：** 完成了 AI Agent 自进化系统 Phase 1+2 的搭建和验证，同时配置了项目级权限白名单消除确认弹窗。

### 产出

**自进化引擎** (`archive/evolution/`):
- 经验日志系统：每次非平凡任务结束时自动写结构化日志
- 失败模式检测：同一 error 出现 ≥2 次 → 创建模式文件；≥3 次 → 自动触发补丁
- 自动补丁机制：三层护栏（只加不减 + 预检 + 快照 + 验证）
- SOP 提取：从历史 session 提取 2 个 SOP（CLI 安装、记忆系统初始化）
- 漂移检测：G5-G8 护栏，基线检查点
- 集成测试通过：注入 3 次失败 → 检测 → 补丁 → 验证 → 清理

**权限配置** (`.claude/settings.json`):
- 新建项目级 settings.json，21 条宽匹配规则
- Bash 命令：pdftotext, curl, gh, npx, uv, python, rm, mkdir, claude 等全部免确认
- MCP 工具：memory, context7, arxiv, semantic-scholar 等全部免确认

### 要点

- 自进化系统基于 Hermes Agent（GEPA）、MetaClaw、ACE、SE-Agent 等 10+ 开源项目调研设计
- 代码自修改（Phase 3）因安全对齐崩塌风险（Misevolution 论文：拒绝率 99.4%→54.4%）暂不实施
- 权限配置教训：用户表达信任时应直接放行，不需要先做数据扫描再给结果

→ [Evolution README](evolution/README.md) · [INDEX](INDEX.md) · [CLAUDE.md](../CLAUDE.md)
