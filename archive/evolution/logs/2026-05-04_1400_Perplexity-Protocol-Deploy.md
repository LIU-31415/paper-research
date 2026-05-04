---
outcome: partial
task: Perplexity-style search protocol implementation
error_signal: synthesis_output_hard_to_understand + skipped_plan_step
root_cause: (1) Over-constrained output format without improving narrative quality; (2) Jumped to implementation without writing plan as user requested
resolution: (1) Removed output templates/constraints, kept search flow only; (2) Saved feedback memory: plan-before-edit protocol
---

## Experience Log

**Task:** 实现 Perplexity 风格的搜索-合成协议

### What went wrong
1. v1.0 的输出模板（合成四纪律、内联引用）反而降低了输出质量——约束太多限制了叙述自由
2. 超哥说写计划→没写直接动手→还顺手改了没要求改的表格格式

### What worked
- 多源并行搜索的机制设计清晰（Query Expansion → Parallel Search → Content Fetching → Synthesis → Follow-up）
- 与 Multi-Agent Workflow 的互补关系明确

### Lesson
- 输出质量靠叙述能力不是靠模板约束
- "写计划" 指令必须遵守，格式修正可以自动做，内容改动必须先计划
