# Bibliography Agent

> 搜索阶段 Sub-agent 分派规范 — 学术文献搜索与扇出调度。
> 由 `deep-mode.md` Phase 2 调用。
> Part of `paper-research` skill.

`version: v1.0 | created: 2026-06-05 | status: active`

---

## Search Refinement

接收主Agent提供的当前项目/范围与research-state.md参考，按 [研究门槛](../protocols/research-gates.md) 处理；缺失条件保留未知，不从其他项目/示例继承。旧结果复用先查适用性和版本。

在调用 Semantic Scholar/OpenAlex 前，先执行与 Quick Mode 相同的两步策略：
1. **WebSearch 前置探查** → 提取领域标准术语
2. **Keyword Engineering** → 用提取术语精化搜索词

详见 `quick-mode.md` 的 Step 1→1.5。

---

## Fan-out Topology

```
Bibliography Agent 分解搜索策略
    │
    ├→ sub-agent 1: WebSearch (中文关键词) → 提取英文术语
    ├→ sub-agent 2: Semantic Scholar (主领域关键词)
    ├→ sub-agent 3: Semantic Scholar (反方/变形关键词)
    └→ sub-agent 4: OpenAlex (并行补充查询)
    │
    └→ 主 Agent 归并: 去重 → 按证据等级排序 → 注释书目
```

---

## Merge Rules

- DOI/题名去重记录，保留预印本/正式版/更正关系及特有结果；再按研究/数据集分组，未知标INDEPENDENCE_UNKNOWN，不按引用数选真伪或把多渠道计作独立证据
- 每 sub-agent 返回 top 5，归并后保留 top 10-15
- 冲突结果标注双方来源，不强行统一
- 单次最多 3 个 sub-agent；SS 查询错开 ≥1s

---

## Tool Preloading

Phase 2 开始前验证 WebSearch/WebFetch/SS 工具已通过 ToolSearch 预加载。
详见 `quick-mode.md` Step 1.5 的 Tool Preloading Check。

---

## Related

- `protocols/quick-mode.md` — Quick Mode（搜索词精化参考）
- `protocols/deep-mode.md` — Deep Mode Phase 2（调用方）
- `SKILL.md` — 主 skill 入口
