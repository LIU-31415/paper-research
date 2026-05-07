# Proposal: OpenHanako-Inspired Evolution — Phase 2

> **Status:** ⏳ Pending Approval
> **Source:** [OpenHanako GitHub](https://github.com/liliMozi/openhanako) — studied 2026-05-05

---

## Background

Phase 1 (已交付):
- ✅ **Memory Recency Tiering** — Hot/Warm/Cold 三层记忆梯队 + 衰减协议
- ✅ **Plugin Architecture MVP** — plugins/ 目录 + plugin.yaml 格式 + 加载协议

Remaining gaps from OpenHanako analysis:

| Gap | Priority | Current State |
|-----|----------|--------------|
| Skill import from GitHub | P0 | SOPs 只能本地编辑，无外部导入通道 |
| Plugin lifecycle (install/enable/disable) | P1 | Plugin 协议有了，但无安装/卸载机制 |
| Async workspace ("书桌") | P1 | 无异步协作空间 |
| Community plugin trust | P2 | 只有 builtin，community trust 未实现 |
| Cross-platform bridge | P2 | 超出当前范围 |

---

## Proposal: Phase 2 — Skill Import + Plugin Lifecycle

### Why this matters

Plugin 协议已经有了骨架（manifest + 加载），但缺肌肉：
- 技能不能从外部导入，生态长不起来
- Plugin 只能手动创建，无法 install/uninstall

Skill import 是投入产出比最高的方向——做完后可以从 GitHub 拉 SOP，社区生态自动生长。

### Proposed changes

**1. Skill Import Protocol**
Define `skill.yaml` manifest format for standalone skills (lightweight plugins). Support import from GitHub repos, gists, URLs.

**2. Plugin Lifecycle Commands**
Add install/enable/disable semantics to Plugin Loading Protocol. Plugin INDEX auto-updates on install.

**3. Community Trust End-to-End**
Implement the community trust workflow: plugin discovery → review prompt → enable toggle → load.

### Files involved

| File | Change |
|------|--------|
| `plugins/PLUGINS.md` | Add Skill Import section + lifecycle commands |
| `AGENTS.md` | Update Plugin Loading Protocol with community trust flow |
| New: `plugins/community/` | Directory for installed community plugins |
| New: `archive/evolution/sops/Skill-Import.sop.md` | SOP for importing skills from GitHub |

### Steps

- [ ] Step 1: Define `skill.yaml` format (lighter than plugin.yaml, single-file focus)
- [ ] Step 2: Add skill import protocol to PLUGINS.md
- [ ] Step 3: Create community/ directory + enable/disable in INDEX.md
- [ ] Step 4: Test: find a GitHub repo → write skill.yaml → import → activate

---

## Future Candidates (P2)

- **PathGuard-style sandbox** — Formalize file access control levels (like OpenHanako's 4-level PathGuard)
- **Async workspace** — "书桌" concept: each project gets NOTES + TODO + README convention
- **Multi-agent channel** — Lightweight multi-agent coordination pattern

---

## Quick Start for New Session

When resuming, the agent should:

1. **Read** `archive/evolution/frontier-radar.md` — see OpenHanako scan findings
2. **Read** `plugins/PLUGINS.md` — current Plugin Architecture state
3. **Read** `archive/evolution/proposals/2026-05-05_OpenHanako-Evolution-Next.md` — this proposal
4. **Check**: all Phase 1 deliveries are in place (memory tier files, plugin dirs)
5. **Start**: Execute Step 1-4 of the plan above, or prioritize per user direction
