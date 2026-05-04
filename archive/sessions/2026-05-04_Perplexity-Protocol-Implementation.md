# Perplexity-Style Search Protocol Implementation

**Date:** 2026-05-04
**Tags:** #perplexity #search-protocol #synthesis

## Summary

实现了 Perplexity 风格的搜索-合成协议，从需求讨论到协议文档落地经历了两轮迭代：

1. **v1.0**: 创建完整协议，含搜索流程 + 合成输出模板 + 内联引用
2. **v1.1**: 根据超哥反馈精简——去掉输出约束（合成四纪律、模板、内联引用），保留搜索核心流程 + 末尾来源列表

## Key Outcomes

- `archive/references/Perplexity-Search-Protocol.md` v1.1 — 搜索协议文档
- `archive/INDEX.md` 已更新
- 与 `Literature-MultiAgent-Workflow.md` 形成互补关系（快速搜索 vs 深度验证）

## Failure & Fix

- 超哥反馈输出"不好理解" → 根因是过度约束合成格式（合成四纪律）而非提升叙述质量
- 超哥反馈"没写计划就改" → 已沉淀为 memory 规则：格式修正自动改，内容结构改动先写计划
