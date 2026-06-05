# Source Reliability Matrix

> 跨会话累积的源可靠性评分，按领域分级。每次 session 结束后可从 `.session-log.md` 增量更新。
> Part of `paper-research` skill — loaded by `skills/paper-research/SKILL.md` 按需引用。

`version: v1.0 | created: 2026-06-05 | status: active`

---

## 评分方法论

| 维度 | 权重 | 评估方法 |
|------|:--:|---------|
| 结果相关性 | 40% | top-5 中与查询直接相关的条目占比 |
| 全文可获取率 | 30% | 有可读原文（非付费墙/null）的结果占比 |
| API 可用性 | 20% | 本次会话请求成功率（无超时/限速） |
| 速率/延迟 | 10% | 超时或限速次数（越少越好） |

**评分**: ⭐⭐⭐⭐⭐ 极佳 → ⭐ 接近不可用

**更新规则**: 每 3 次 session 后，对评分做一次加权平均修正。连续 3 次下降 → 触发降级警告。

---

## 累积矩阵（按领域）

> 初始评分基于语义覆盖范围预估，随使用累积自动修正。

| 领域 | Semantic Scholar | OpenAlex | WebSearch |
|------|:---:|:---:|:---:|
| **材料科学** (纳米/磁性) | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **环境工程** (PFAS/AOP/VOCs) | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **AI/ML** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **中文人文社科** | ⭐⭐ | ⭐ | ⭐⭐⭐ |
| **生物医学** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| *未分类* (默认) | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

### 源特性速查

| 源 | 强项 | 弱项 |
|----|------|------|
| Semantic Scholar | 引用关系图、is_influential 标记、全文链接 | 中文覆盖弱、API 限速严格 |
| OpenAlex | 开放获取、机构/基金元数据丰富 | 部分学科全文率低、搜索精度不如 SS |
| WebSearch | 最新信息、跨领域覆盖、无 API 限制 | 无结构化元数据、信噪比波动大 |

---

## Session-Log 格式

每次 session 结束时（Quick Mode Step 9 / Deep Mode Phase 6 后），写入 `{research-topic}/.session-log.json`：

```json
{
  "ts": "2026-06-05_2200",
  "topic": "fe3o4-heterostructure-review",
  "mode": "quick",
  "domain": "材料科学",
  "sources": {
    "websearch": {"results": 8, "relevant": 7, "fetchable": 5},
    "semantic_scholar": {"results": 12, "relevant": 10, "fetchable": 8},
    "openalex": {"results": 5, "relevant": 3, "fetchable": 2}
  },
  "effective_terms": ["Fe₃O₄ heterostructure", "exchange bias interface"],
  "ineffective_terms": [],
  "failures": [],
  "skipped_steps": ["step_1.5"],
  "user_feedback": null
}
```

**字段说明**：
- `sources.<name>.relevant`: 结果中与查询直接相关的条目数（用于计算结果相关性维度）
- `sources.<name>.fetchable`: 有可读原文的条目数（用于计算全文可获取率维度）
- `failures`: 不可达或超时的源
- `skipped_steps`: 被跳过的步骤及原因（用于跳过率自检）

---

## Related

- `skills/paper-research/SKILL.md` — 主 skill 入口（Protocol Index）
- `skills/paper-research/protocols/quick-mode.md` — Quick Mode（Step 9 记录 session-log）
- `skills/paper-research/protocols/deep-mode.md` — Deep Mode（Phase 6 后记录 session-log）
