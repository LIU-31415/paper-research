# Frontier Radar — External Signal Ingestion

> **Purpose:** 头部企业/前沿研究的信号输入口，驱动自进化引擎对比外部进展
> **Protocol:** 见 `README.md` — External Signal Ingestion 章节

---

## Source Registry

| Source | URL | Scan Method | Freq | Last Scan | Status |
|--------|-----|-------------|------|-----------|--------|
| Anthropic Blog | https://www.anthropic.com/blog | WebFetch (fallback: WebSearch) | weekly | 2026-05-04 | ✅ scanned |
| OpenAI Blog | https://openai.com/blog | WebFetch | weekly | 2026-05-04 | ✅ scanned |
| Cursor Blog | https://cursor.com/blog | WebFetch (fallback: WebSearch) | weekly | 2026-05-04 | ✅ scanned |
| Google DeepMind | https://deepmind.google/discover/blog/ | WebFetch (fallback: WebSearch) | weekly | 2026-05-04 | ✅ scanned |
| Meta AI Blog | https://ai.meta.com/blog/ | WebFetch | weekly | 2026-05-04 | ✅ scanned |
| arXiv cs.AI | (via MCP) | `mcp__arxiv__search_papers` | biweekly | 2026-05-04 | ❌ 429 rate limited |
| Semantic Scholar | (via MCP) | `mcp__semantic-scholar__search_papers` | biweekly | 2026-05-04 | ✅ scanned |
| arXiv cs.CL | (via MCP) | `mcp__arxiv__search_papers` | biweekly | 2026-05-04 | ❌ 429 rate limited |

## Scan Log

| Date | Source | Key Findings | Impact |
|------|--------|-------------|--------|
| 2026-05-04 | Cursor Blog | Bugbot: self-improving rules from PR feedback, candidate→promotion gate, 78% resolution rate on 110K+ repos | P1 — our system lacks external feedback loop and candidate gating |
| 2026-05-04 | Cursor Blog | Real-time RL from production inference (5h cycle), +2.28% agent edit persistence, -3.13% user dissatisfaction | P2 — model-level training out of scope, but reward-from-user-behavior concept validated |
| 2026-05-04 | Semantic Scholar | Darwin Godel Machine: self-improving coding agents via archive+evolution, 20%→50% SWE-bench | P1 — directly relevant evolution mechanism, archive of agents similar to our pattern archive |
| 2026-05-04 | Semantic Scholar | SEW: Self-Evolving Workflows for code gen, auto-optimizes multi-agent topology + prompts, +12% LiveCodeBench | P1 — workflow auto-optimization is a gap we haven't addressed |
| 2026-05-04 | OpenAI Blog (WebSearch) | Codex self-improvement: GPT-5.3-Codex "instrumental in creating itself." Codex writes code for its own training. Harness Engineering: engineers banned from editing code, 3-5 PRs/day via agents | P1 — no feedback-from-production loop in our system |
| 2026-05-04 | OpenAI Blog (WebSearch) | Agents SDK v0.14+: sandbox execution, durable snapshot/rehydration, MCP tools, model-native harness | P2 — interesting but model-level |
| 2026-05-04 | Google DeepMind | Gemma 4 open models (April 2026), Decoupled DiLoCo distributed training, Gemini 3.1 Flash TTS | P2 — general infra, not directly applicable |
| 2026-05-04 | Meta AI Blog | Muse Spark: first MSL model, native multimodal + tool use + multi-agent orchestration, "personal superintelligence" vision | P2 — model capability, not system architecture |
| 2026-05-04 | Semantic Scholar | RoboPhD: autonomous ELO-based agent evolution, 70→1500 lines/18 iterations, "evolved Haiku exceeds naive Sonnet" | P1 — no autonomous evolution in our system |
| 2026-05-04 | Semantic Scholar | SWE-chat: only 44% agent code survives, more security vulns in agent-written code | P1 — no quality metrics tracked |
| 2026-05-04 | Semantic Scholar | SWE-Pruner: 23-54% context reduction on agent tasks | P2 — infra-level optimization |

## Ingestion Flow

```
Trigger (manual: "扫一下")
  → For each source in registry:
      → Fetch (WebFetch → if 404, WebSearch fallback) or MCP search
      → Extract key findings
  → For each finding:
      → Gap analysis vs current system state
      → If P0 or P1: auto-generate improvement proposal
      → Write to scans/YYYY-MM-DD_scan.md
      → Update Scan Log (above)
```

## Source Addition Rules

- Sources should be primary (official blogs, peer-reviewed venues), not aggregators
- AI agent systems / agent harness / self-evolving agents are in-scope
- General AI capability advances are out-of-scope (too broad, too noisy)
- Add via edit to this file's registry table + log reason in Scan Log
