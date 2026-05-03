# 2026-05-02: Archive System Setup

`tags: #archive #memory #system`

**结论：** 在 `C:\Users\LIU\Desktop\agent` 搭建了四层记忆复利系统，实现 AI 越用越好用的知识飞轮效应。

- 采用 CLAUDE.md（用户画像）+ archive/topics/（主题知识库）+ MCP 知识图谱（语义关联）+ archive/sessions/（会话时间轴）四层架构
- Token 控制：按任务类型定向加载 topic 文件，写作时不加载代码知识，典型开销 4-9K
- 混合归档：AI 自动记录精华结论 + 用户可随时补充修正
- 去重冲突检测：已有内容不重复，矛盾提示用户确认
- 调研参考：MCP Memory Server、Claude Code 原生 memory、Mem0/MemGPT/Letta 分层记忆、Windsurf 自动识别模式

→ [Tool-Config](topics/Tool-Config.md) · [Graph: archive-system]
