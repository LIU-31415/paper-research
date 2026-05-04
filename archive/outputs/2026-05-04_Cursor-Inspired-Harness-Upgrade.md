# Cursor-Inspired Harness Upgrade Plan

> **Status:** ✅ Completed 2026-05-04
> **Based on:** [Cursor Harness 对标分析](../sessions/2026-05-04_Cursor-Comparison.md)
> **Goal:** 补齐对标分析识别的 3 个差距，闭环进化链路

---

## Task 1: Experience Log Schema — 增加 user_sentiment 字段

**Why:** 当前所有 experience log 的 outcome（success/failure/partial）由我自判，存在 self-serving bias。Cursor 使用 LLM-judged satisfaction 做客观标尺，我们至少应在 schema 中预留这个维度。

**What:** 在 `archive/evolution/README.md` 的 Log Entry Schema 中增加 `user_sentiment` 字段 + 填写指南。

**Files:**

- Modify: `archive/evolution/README.md` — schema 增加字段

**Steps:**

- [ ] Step 1: 在 Log Entry Schema 的 Signals 区增加 `user_sentiment` 字段
- [ ] Step 2: 在 schema 下方增加填写说明（如何从用户回复推断）
- [ ] Step 3: 验证 — read 确认格式一致

---

## Task 2: Rule Sunset 协议

**Why:** G1 guardrail 规定"只加不减"，这是安全底线但也是陷阱——规则只膨胀不收缩。Cursor 的做法是随模型能力提升主动减少护栏。我们需要一个兼容 G1 的淘汰机制。

**What:** 在 `archive/evolution/README.md` 的 Guardrails 区增加 Rule Sunset 补充协议。规则用 `[sunset: date]` 标记而不是删除（兼容 G1）。

**Files:**

- Modify: `archive/evolution/README.md` — Guardrails 区增加 Sunset 条目

**Steps:**

- [ ] Step 1: 在 Guardrails 区增加第 4 条「规则淘汰」协议
- [ ] Step 2: 在 CLAUDE.md 的 Self-Evolution Protocol 区加一条简短引用
- [ ] Step 3: 验证 — read 确认一致性

---

## Task 3: 执行首次 Drift Checkpoint (G6)

**Why:** DRIFT-DETECTION-GUARDRAILS.md 已有 G6 协议（每 10 log 或每周跑一次 drift checkpoint），但从未执行过。当前正好积累到第 5 条 experience log，跑一次验证机制是否有效。

**What:** 按照 G6 协议模板创建第一个 drift checkpoint 文件。检查当前 5 条 log 的行为一致性。
- 注意 G6 中有一个 safety probe（"Does agent refuse clearly harmful request?"），这不太适用于我们的使用场景，应调整为 task completion probe

**Files:**

- Create: `archive/evolution/checkpoint-002.md`
- Read: 最近 5 条 log + 当前 CLAUDE.md 规则

**Steps:**

- [ ] Step 1: 读取最近 5 条 experience log，提取行为信号
- [ ] Step 2: 按 G6 模板创建 checkpoint-002.md，adjusted for our context
- [ ] Step 3: 验证 — checkpoint 内容完整可读

---

## 执行计划

| 任务 | 文件量 | 估计耗时 |
|:-----|:------:|:--------:|
| Task 1: user_sentiment | 1 file | ~3 min |
| Task 2: Rule Sunset | 2 files | ~5 min |
| Task 3: Drift Checkpoint | 1 file | ~5 min |
| **总计** | **4 files** | **~13 min** |
