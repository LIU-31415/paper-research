# Agent System Upgrade Plan

> **Status:** ✅ Completed
> **Based on:** [Multi-Dimensional Evaluation](../sessions/2026-05-04_System-Evaluation.md)

**Goal:** 执行系统评估识别出的前三优化方向，闭环升级。

**Scope:** 2 tasks — CLAUDE.md 瘦身 + 成功模式追踪

---

## Task 1: Archive Rules Extraction (CLAUDE.md 瘦身)

**Status:** ✅ Completed

**Problem:** CLAUDE.md 承担了路由+存档+自进化+记忆+格式等多种规则，正在膨胀为单体文件，增加认知负载。

**Solution:** 将 Archive System Rules 部分从 CLAUDE.md 提取到 `archive/RULES.md`，CLAUDE.md 只保留精简引用。

**Files:**
- Modify: `CLAUDE.md` — 删除 Archive 详细规则，替换为短引用
- Create: `archive/RULES.md` — 承载完整的存档规则
- Modify: `archive/INDEX.md` — 添加 RULES.md 引用

- [x] Step 1: 创建 `archive/RULES.md`，承载提取的存档规则
- [x] Step 2: 精简 `CLAUDE.md`，替换详细规则为短引用
- [x] Step 3: 更新 `archive/INDEX.md`，添加 RULES.md 条目
- [x] Step 4: 验证 — read 所有修改文件确认一致性

---

## Task 2: Success Pattern Tracking

**Status:** ✅ Completed

**Problem:** 自进化系统目前只检测失败模式，不对称。成功路径的经验也可以提炼为 SOP。

**Solution:** 在 experience log schema 中加入 `success_signals`，增加成功模式检测流程。

**Files:**
- Modify: `archive/evolution/README.md` — 更新 log schema + 添加成功检测规则
- Modify: `archive/evolution/patterns/DETECTION-WORKFLOW.md` — 添加成功模式检测步骤

- [x] Step 1: 更新 `archive/evolution/README.md` — Log Schema 增加 `success_signals`
- [x] Step 2: 更新 `archive/evolution/README.md` — 增加 Success Pattern Detection 章节
- [x] Step 3: 更新 `archive/evolution/patterns/DETECTION-WORKFLOW.md` — 添加成功模式检测步骤
- [x] Step 4: 验证 — 用当前 session 模拟一个成功日志，确认 schema 可用

---

## Close

- [x] 更新 `archive/INDEX.md` 引用
- [x] 写 experience log 记录本次升级
