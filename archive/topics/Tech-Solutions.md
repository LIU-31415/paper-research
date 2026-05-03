# Tech Solutions

`tags: #tech #code`

_技术方案、代码实现、架构决策归档于此。新内容置顶。_

---

_暂无条目_

---

## 2026-05-03: Self-Evolution Engine (Phase 1+2)

`tags: #evolution #self-improvement #architecture`

**结论：** 基于 Hermes Agent/MetaClaw/ACE/SE-Agent 等 10+ 项目的调研，在 archive/ 体系上搭建了经验日志→失败检测→自动补丁→SOP 提取的自进化引擎，含 G1-G8 安全护栏。代码自修改（Phase 3）因安全对齐崩塌风险暂不实施。

### 架构

```text
经验日志 (logs/) → 失败模式检测 (patterns/) → 自动补丁 (patches/) → CLAUDE.md
                                     ↓
    成功轨迹 (logs success) → SOP 提取 (sops/) → A/B 验证 → 技能进化
```

### 护栏体系

- G1-G4: 只加不减、预检、快照、验证（自动补丁时强制执行）
- G5-G8: 进化数上限、漂移检查点、SOP 保鲜期、行为基线

### 关键风险

- Misevolution 论文实证：自进化后安全拒绝率 99.4%→54.4%
- Layered Mutability 论文：68% 的漂移在 revert 后仍残留
- 结论：只做 skill/memory 层进化，不碰 system prompt 和代码

→ [Evolution README](../evolution/README.md) · [Drift Detection](../evolution/sops/DRIFT-DETECTION-GUARDRAILS.md)
