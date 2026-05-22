# paper-research Skill — Version Archive

> 历史版本留存目录，用于追溯每次大版本变更的完整文件。

## 版本索引

| 版本 | 文件 | 日期 | 状态 |
|------|------|------|------|
| **v2.2** | `../SKILL.md` | 2026-05-23 | **active** |
| v2.1 | [v2.1-SKILL.md](v2.1-SKILL.md) | 2026-05-22 | superseded |

## v2.1 → v2.2 主要变更

| 变更项 | 说明 |
|--------|------|
| Sub-agent 并行分层阅读 | 文献数 ≥2 篇时自动分发到 3 个独立 sub-agent 并行处理（Quick/Deep 通用） |
| 多 Agent 信息核对 | 新增 4 步核对机制：Claim 归并 → 跨源比对 → 矛盾裁决 → 核对报告 |
| 原文下载 + 位置索引 | sub-agent 下载原文到项目目录，claim 标注行号/段落，主 agent 可回溯验证 |
| 主题目录树管理 | Deep：6 级完整目录树；Quick：3 级简化目录树（literature 子结构一致） |
| 跨模式调用点表 | 2 列 → 3 列（+核对机制插入点） |
| Agent Output 路径化 | 所有 Phase 的 Agent Output 增加具体文件路径 |
| Handoff 更新 | 传递目录路径替代摘要传递 |

## 版本管理规范

1. **大版本升级**（如 v2.x → v3.0）：复制当前 SKILL.md 到 `versions/` 目录，更新索引
2. **小版本迭代**（如 v2.2 → v2.2.1）：仅在 SKILL.md 的 Version History 表记录
3. **版本命名**：`v{major}.{minor}.{patch}` (semver)
4. **状态标记**：`active` → `superseded` → `archived`
