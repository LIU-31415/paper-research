---
name: paper-search
description: >
  Perplexity-style multi-source search & synthesis protocol for academic literature
  and general research. INVOKE WHENEVER the user wants to: research a topic, search
  for academic papers, lookup information online, fact-check a claim, get a quick
  synthesis from multiple sources, or says things like "帮我调研", "搜索", "查一下",
  "research", "literature review", "what's the latest on", "这个结论可靠吗", "帮我查".
  Combines WebSearch, Semantic Scholar, Google Scholar, arXiv/OpenAlex, and PubMed
  in parallel with cross-validation and synthesis. SKIP only for simple single-file
  lookups the user could do themselves with Read/Grep/Glob.
---

# Paper Search Protocol

> Perplexity-style multi-source search & synthesis protocol for academic literature and general research.

`version: v1.5 | status: active`

> 复制 Perplexity 的搜索-合成机制，提升信息检索的覆盖面和准确性。

---

## Core Mechanism

```
Single Query
    │
    ├→ Query Expansion (1 question → 3-5 variants)
    │
    ├→ Parallel Search
    │   ├─ WebSearch (general web)
    │   ├─ Google Scholar (WebFetch scrape)  [if academic topic, use precise queries]
    │   └─ Semantic Scholar (academic papers) [if academic topic, covers arXiv + PubMed]
    │
    ├→ Content Fetching (top 3-5 results per source)
    │
    ├→ Cross-Validation (internal)
    │   ├─ Multi-source consensus → adopt
    │   ├─ Conflict → authority > recency > volume
    │   ├─ Single source → downgrade, note limitation
    │   └─ No source → state no direct evidence
    │
    ├→ Synthesis
    │   ├─ Multi-source merge + dedup
    │   ├─ Find the story → 3-5 key insights
    │   └─ Source list appended at end
    │
    └→ Follow-up (3 suggestions for deeper dive)
```

---

## Step 1: Query Expansion

**Automatically expand user query into 3-5 search variants** covering different angles:

| Dimension | Strategy | Example |
|-----------|----------|---------|
| Language | Chinese + English variants | "AI agents impact jobs" / "AI 智能体 就业影响" |
| Perspective | Academic + industry | "deep learning scaling laws Chinchilla" / "AI industry trends Gartner 2026" |
| Opposition | Counter-arguments / limiting conditions | "AI automation job displacement concerns" |

**Rules**:
- Non-academic topics → WebSearch only, skip academic MCPs
- Academic topics → WebSearch + 1-2 academic MCPs in parallel
- Mixed topics → all sources
- Unknown/ambiguous → WebSearch first, decide based on results

---

## Step 2: Parallel Search

### Trigger Matrix

| Topic Type | Search Combination | When |
|------------|-------------------|------|
| **Academic/Literature** | WebSearch + Google Scholar + Semantic Scholar | User explicitly doing literature review, or topic contains domain terminology |
| **Technical/Programming** | WebSearch (primary) + context7 (docs) | Framework/library/tool usage questions |
| **General/News** | WebSearch 3 queries (primary) | Industry trends, current events,科普 |
| **Mixed/Unknown** | WebSearch first, decide if academic MCPs needed | Default strategy |

### Parallel Rules

- **Independent concurrency** (multiple tool calls in one message), no priority queuing
- Each source returns **top 5-10 results**, no truncation
- Source failure → weighted down, does not block other sources

### Source Reliability Matrix

Different academic sources perform differently across fields. Choose based on topic domain:

| Source | Strengths | Weaknesses/Limitations | Rate Limit |
|--------|-----------|----------------------|------------|
| **Semantic Scholar** | All disciplines, CS/materials/bio/medicine/engineering | Newest papers delayed 1-2 weeks indexing | ~1 rps, relatively generous |
| **Google Scholar (WebFetch)** | Best citation coverage, can find newest papers | Broad queries noisy, needs precise queries | No explicit limit |

**Decision rules:**
- Citation validation → prefer Google Scholar
- General academic search → Semantic Scholar primary

---

## Step 3: Content Fetching

| Source | Content Retrieval |
|--------|-------------------|
| WebSearch | Fetchable links → use WebFetch/mcp__fetch__fetch to get abstract or full text |
| Semantic Scholar | `get_paper` for abstract, `get_paper_fulltext` if needed |
| Google Scholar | WebFetch scrape, precise queries (quotes + keywords), good for citation validation and latest paper discovery |

**Don't blindly read full text** — only fetch full text when deep analysis is needed (skip if abstract is sufficient).

---

## Step 3.5: Cross-Validation (Internal)

Internal quality assessment before synthesis. Not shown in output format.

| Situation | Handling |
|-----------|----------|
| Multi-source consensus | Adopt, high confidence |
| Conflict with multi-source support on one side | Trust the side with more sources |
| Conflict, both single-source | Authority > recency > volume; mark as disputed if still uncertain |
| Single source only, cannot cross-validate | Downgrade priority, note limitation in output |
| No source support | Report no direct evidence |
| Conclusions change over time | Use latest, annotate timeline |

---

## Step 4: Synthesis

### Synthesis Flow

Read all results → extract 3-5 key points → organize into a coherent narrative following logical flow. No inline citation markers in body text. All sources listed at the end.

### Output Structure

```text
## [Title]

> [One-sentence core]

Body text... (logical flow, no inline citations)

---

**Sources**
- [Title](URL) — [Source type]
- [Title](URL) — [Source type]
```

---

## Step 5: Follow-up

Auto-generate 3 follow-up directions at the end of output:

- **Deep dive**: Explore a sub-direction based on current results
- **Validation**: "Is this conclusion valid under scenario X?"
- **Extension**: "What are related directions in this field?"

---

## Integration with Multi-Agent Workflow

| Scenario | This Protocol | Multi-Agent |
|:---------|:-------------|:------------|
| Quick topic overview | ✅ Primary | ❌ Too heavy |
| Deep academic literature review | ❌ Too shallow | ✅ Primary |
| Validate a claim's reliability | ⚡ Quick check first | Then decide if deep dive needed |
| Enter a new domain | ⚡ Scout first | Then decide if multi-agent needed |
| Code/technical documentation lookup | ✅ Primary | ❌ Not applicable |

---

## Version History

| Date | Version | Change |
|:----|:--------|:-------|
| 2026-05-05 | v1.5 | Remove arXiv/OpenAlex/PubMed references, unify through Semantic Scholar (MCP streamlining) |
| 2026-05-04 | v1.4 | Add source reliability matrix + OpenAlex fallback + arXiv rate limit notes |
| 2026-05-04 | v1.3 | Add Google Scholar source (WebFetch scraping) |
| 2026-05-04 | v1.2 | Restore Cross-Validation internal assessment flow |
| 2026-05-04 | v1.1 | Streamline output format constraints |
| 2026-05-04 | v1.0 | Initial creation |
