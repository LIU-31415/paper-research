# Tech Solutions

`tags: #tech #code`

_技术方案、代码实现、架构决策归档于此。新内容置顶。_

---

## 2026-05-03: β-FeOOH 磁化方案优化（文献驱动参数调整）

`tags: #β-FeOOH #magnetic #Fe3O4 #protocol #morphology-preservation`

**结论：** 保留形貌引入磁性的核心矛盾是碱性条件（Stöber pH 11 + 共沉淀 pH 11）会侵蚀 β-FeOOH。基于 7 篇文献和化学原理推理，通过分步加氨、Fe³⁺ 预吸附→N₂ 排氧→Fe²⁺ 加料顺序反转、APTES 分步加倍三个抓手降低碱性暴露。

### Step 2 关键调整

- 氨水分步加（1.0→0.5 ml）+ TEOS 分步加（0.4+0.4 ml），初始 pH 9.5 形成超薄保护壳后再补强
- 水/乙醇比从 40/240 降到 30/270，减少 TEOS 均相成核
- 洗涤：2E→1E/W→2W（用户提出的极性过渡方案）

### Step 3 关键调整

- **顺序反转：** Fe³⁺ 先预吸附 30 min → N₂ 排氧 20 min → 加 Fe²⁺ → 氨水慢速滴加（0.3 ml/min）
- Fe²⁺ 微过量 10%（1.10→1.21 g）补偿氧化损失
- 温度 60→55°C，反应 30→15 min，降速保形貌
- 原方案"溶解磁性纳米颗粒"为笔误，应为 β-FeOOH@SiO₂ 颗粒

### Step 4 关键调整

- 先真空干燥称干重，按 0.25 mmol/g 计算 APTES，替代湿饼体积估算
- 分两批（0.3+0.3 g）+ 4h 总反应
- 乙醇体积 300→200 ml 提升浓度

→ 见 `archive/references/Literature-MultiAgent-Workflow.md`（工作流）· `archive/topics/Research-Notes.md`（文献条目）

---

## 2026-05-03: Model Capability vs Tool Capability Alignment

`tags: #model-awareness #capability-audit #vision`

**结论：** 工具（Read）支持图片 ≠ 当前模型能识图。能力回答必须验证模型层而非仅依赖工具描述，否则属于"口嗨式承诺，交付时打脸"。

### 根因模式

- 系统 Prompt 中工具描述写了"supports images" → 直接答"能" → 未验证当前模型（deepseek-v4-flash）是否具备多模态能力
- 工具能力和模型能力是两层，必须分别验证

### 预防措施

- 回答"能不能做X"之前：①工具支持吗？②当前模型支持吗？两端都确认再回答
- 不确定时先做验证测试（如传一个已知合法文件看返回结果），再做结论

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
