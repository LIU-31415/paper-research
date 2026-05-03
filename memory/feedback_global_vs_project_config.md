---
name: Global vs project config rule
description: Global settings go to ~/.claude/CLAUDE.md, project settings go to project-root/CLAUDE.md
type: feedback
---

Global preferences (称呼, behavioral habits, cross-project preferences) → `~/.claude/CLAUDE.md`.
Project-specific config (archive rules, tech stack, team, repo conventions) → `project-root/CLAUDE.md`.

**Why:** User wants a clean separation — global identity/habits don't leak into project context, and project rules don't clutter other projects.

**How to apply:** When the user says "全局设置" or anything about personal preferences/cross-cutting config, add to `~/.claude/CLAUDE.md`. When about a specific project's code/tools/workflow, add to that project's `CLAUDE.md`. Don't ask which file — infer from scope.
