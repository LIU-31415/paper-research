# 2026-05-03: Archive Consolidation & MCP Academic Research Setup

`tags: #archive #consolidation #mcp #semantic-scholar #arxiv #workflow`

## 完成事项

### 1. 存档合并整理
- **Sessions 去重**：`2026-05-03_gh-CLI-Setup.md` 合并入 `2026-05-03_gh-CLI-Setup-And-Global-Config.md`，删除重复文件
- **Research-Notes 合并**：两条 PFAS 条目（文献调研 + 验证记录）合并为一条
- **INDEX.md 精简**：Recent Entries 从 6 条缩至 5 条，打上 `consolidated: true` 标记

### 2. Outputs 文件夹建立
- 新建 `archive/outputs/`，用于存放调研结果、工作流完整交付件
- 与 `topics/`（精炼结论）互补，两条线各司其职
- 更新 CLAUDE.md 和 workflow 文档

### 3. 文献多 Agent 工作流 → v0.3
- 明确 Phase 1 三路并行：Semantic Scholar + arXiv + WebSearch/WebFetch
- 所有来源对等，无主次之分
- 交叉验证（Phase 2）做多源一致性比对

### 4. MCP 学术检索服务配置
- 安装 Semantic Scholar MCP（`uvx semantic-scholar-mcp`，24 tools）
- 安装 arXiv MCP（`npx @futurelab-studio/latest-science-mcp`）
- 新建 `.mcp.json`，更新 `settings.local.json` 白名单
- 验证通过：两路都能正常返回论文结果

## 关键决策

- 文献检索层面：MCP + Web 全源并存，不做减法
- 输出结构：outputs（完整报告）+ topics（精炼结论），不再混放
- 超哥反馈：后续避免重复铺流程描述，同类信息一次说完
