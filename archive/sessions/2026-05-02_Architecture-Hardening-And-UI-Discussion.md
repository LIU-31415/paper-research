# Session: 2026-05-02 Architecture Hardening and UI Discussion

`tags: #archive #architecture #mcp #ui`

**Summary:** 对已建立的四层记忆架构进行三项加固（Task Disambiguation、Staleness Check、MCP-Setup 文档），初始化 Layer 2 知识图谱，讨论 UI 必要性后决定暂不构建。

## 完成事项

### 1. 架构加固（CLAUDE.md）

- 新增 **Task Disambiguation** 节：模糊任务先问用户分类（纯技术/纯调研/混合），再路由
- **Dedup & Conflict** 加入 Staleness Check：修改 topic 文件时扫描 6 个月以上旧条目，提示加 `[last-reviewed]` 或 `[deprecated]`
- **Format Rules** 同步更新 staleness 格式要求
- 新增 **External References** 节，统一指向 MCP-Setup.md 和 README.md

### 2. 新文档

- 创建 `archive/references/MCP-Setup.md`：MCP Memory Server 配置方法 + Archive 与 KG 关系对比表

### 3. INDEX.md 索引升级

- Topics 表新增 `Last Entry` 列
- 新增 **Recent Entries** 子表按时间倒序展示最新条目
- References 区表格化

### 4. Layer 2 知识图谱初始化

- 已有 13 个实体（用户、系统、规则、主题、引用）+ 14 条关系
- 新增：task-disambiguation, staleness-check, mcp-setup, index-enhancement 实体
- 新增：tech, tool-config 主题实体

### 5. UI 讨论结论

- 确认不做 UI 界面，当前 Claude Code + VSCode 侧栏足以闭环
- 未来如需浏览可考虑只读静态站点，但不解决实际痛点前不构建

## 相关文件

- [CLAUDE.md](../../CLAUDE.md)
- [INDEX.md](../../INDEX.md)
- [MCP-Setup.md](../../archive/references/MCP-Setup.md)
- [Tool-Config.md](../../archive/topics/Tool-Config.md)

→ 相关：[会话 2026-05-02 Archive-System-Setup](./2026-05-02_Archive-System-Setup.md)
