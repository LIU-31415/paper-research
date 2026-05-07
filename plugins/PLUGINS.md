# Plugin Architecture

> `version: v0.1 | status: active`
> A lightweight, convention-based plugin system for agent capability extensions.
> Inspired by [OpenHanako Plugin Architecture](https://github.com/liliMozi/openhanako/blob/main/PLUGINS.md) — adapted for CLI-agent context.

---

## Core Concept

A **plugin** is a directory with a `plugin.yaml` manifest that contributes well-defined artifacts (SOPs, guardrails, knowledge, workflows) to the agent's runtime environment. Plugins are discovered at session start and their contributions are loaded into the appropriate system registries.

```
plugins/
├── PLUGINS.md          ← This file — protocol definition
├── INDEX.md            ← Plugin registry (all available plugins)
└── built-in/           ← System-shipped plugins
    └── my-plugin/
        ├── plugin.yaml ← Manifest (required)
        ├── *.sop.md    ← SOP contributions
        ├── *.guard.md  ← Guardrail contributions
        └── *.knowledge.md ← Knowledge contributions
```

---

## Plugin Manifest (`plugin.yaml`)

```yaml
id: my-plugin
name: My Plugin
version: 1.0.0
description: What this plugin does
author: system
trust: builtin  # or "community"
contributes:
  sops: []      # SOP file paths (relative to plugin dir)
  guards: []    # Behavioral guardrail file paths
  knowledge: [] # Pre-loaded knowledge file paths
  workflows: [] # Workflow template file paths
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier. Convention: `kebab-case` |
| `name` | Yes | Human-readable name |
| `version` | Yes | Semver |
| `description` | Yes | One-line description |
| `author` | No | Creator name. `system` for built-in |
| `trust` | Yes | `builtin` (auto-loaded) or `community` (requires approval) |
| `dependencies` | No | Array of plugin IDs this depends on |
| `contributes` | Yes | Map of contribution types to file path arrays |

---

## Contribution Types

### SOPs (`contributes.sops`)

**File pattern:** `*.sop.md`

Standard Operating Procedures — repeatable, step-by-step workflows. Files use SOP format (see existing SOPs in `archive/evolution/sops/`).

**Loading:** Merged into SOP registry. Available for agent to reference during task execution.

**Example:**
```yaml
contributes:
  sops:
    - archive-init.sop.md
    - memory-tier-maintenance.sop.md
```

### Guardrails (`contributes.guards`)

**File pattern:** `*.guard.md`

Behavioral rules and constraints — injected into the agent's behavioral protocol at session start.

**Loading:** Read and merged into active behavioral directives (appended to AGENTS.md protocol during session init).

**Example:**
```yaml
contributes:
  guards:
    - auto-patch.guard.md
```

### Knowledge (`contributes.knowledge`)

**File pattern:** `*.knowledge.md`

Pre-loaded knowledge entries — injected into agent's memory context at session start. Lightweight alternative to full archive entries.

**Loading:** At session start, knowledge entries are read and their content is added to working memory context.

**Example:**
```yaml
contributes:
  knowledge:
    - archive-rules.knowledge.md
```

### Workflows (`contributes.workflows`)

**File pattern:** `*.workflow.md`

Multi-step workflow templates — define tool sequences, verification timing, and archive routing for complex tasks.

**Loading:** Registered as available workflow templates. Triggered when task type matches.

**Example:**
```yaml
contributes:
  workflows:
    - archive-operation.workflow.md
```

---

## Loading Protocol

The plugin system follows a **discover → parse → classify → activate** lifecycle:

### Session Start Loading

```
1. Scan
   ├── for each dir in plugins/*/
   │   ├── if plugin.yaml exists → parse manifest
   │   └── validate: id, version, trust fields mandatory
   │
2. Classify
   ├── if trust = builtin → auto-activate all contributions
   └── if trust = community → skip (require manual enable)
   
3. Activate
   ├── for each contribution type:
   │   ├── sops → register in SOP registry
   │   ├── guards → append to active behavioral rules
   │   ├── knowledge → inject into memory context
   │   └── workflows → register workflow templates
   └── log: "Plugin [id] v[version] loaded (X SOPs, Y guards, Z knowledge)"
```

### Contribution Path Resolution

- Relative paths in `contributes.*` are resolved relative to the plugin directory (`plugins/built-in/<id>/`)
- Absolute paths are also supported (for referencing legacy content)
- Missing files are logged as warnings but don't block plugin loading

---

## Trust Model

| Level | Auto-load | User approval | Use |
|-------|-----------|--------------|-----|
| `builtin` | ✅ Always | Not needed | System-shipped plugins |
| `community` | ❌ | Required before first load | Third-party plugins |

This mirrors OpenHanako's two-level permission model (restricted vs full-access), adapted for our context — community plugins should be reviewed before activation.

---

## Migration Strategy

Existing content in `archive/evolution/sops/` can be wrapped into plugins via path-referencing manifests:

```yaml
# plugins/built-in/archive-sops/plugin.yaml
contributes:
  sops:
    # Reference existing files by absolute or relative path from project root
    - ../../archive/evolution/sops/Archive-Memory-System.md
```

New content should be placed directly in the plugin directory for true self-contained plugins.

---

## Skill Import Protocol

Skills imported from external sources (GitHub, gists, raw URLs) use **Claude Code's native SKILL.md format** — no custom manifest needed.

Native skill format (auto-discovered by `Skill` tool):

```text
plugins/community/<skill-name>/
└── SKILL.md          ← frontmatter + content
```

### Native SKILL.md Format

```markdown
---
name: my-skill
description: What this skill does
---

# Skill content here

## Steps
1. Do this
2. Do that
```

Only two frontmatter fields required: `name` and `description`. The `Skill` tool handles discovery, parsing, and loading automatically.

### Import Flow

```text
User finds content to import (GitHub file, gist, URL)
  │
  ├─ (1) FETCH → Download content from source
  │    ├── curl/gh for remote files
  │    └── Or copy local file
  │
  ├─ (2) WRAP → Add SKILL.md frontmatter
  │    ├── name: <kebab-case-id>
  │    ├── description: <one-line>
  │    └── Body: original content
  │
  ├─ (3) PLACE → plugins/community/<id>/SKILL.md
  │    └── Skill tool auto-discovers on next session
  │
  ├─ (4) REVIEW → Agent presents for approval
  │    ├── "📦 Skill [name] detected in community/"
  │    ├── Preview (first 10 lines)
  │    └── Ask user: enable now?
  │
  └─ (5) ENABLE → User approves
       └── INDEX.md status → enabled
```

### Lifecycle States

| State | Meaning | Action |
|-------|---------|--------|
| `discovered` | SKILL.md copied to community/ | Ready for review |
| `enabled` | User reviewed and approved | Active — Skill tool discovers it |
| `disabled` | User turned off | Skip during session start scan |
| `uninstalled` | Removed from community/ | Deregistered from INDEX |

### Enable / Disable

- **Enable:** Set status in INDEX.md to `enabled`. `Skill` tool discovers on next session start.
- **Disable:** Set status in INDEX.md to `disabled`. Agent skips this community dir during scan.
- **Uninstall:** Remove `plugins/community/<id>/`. INDEX entry archived.

### Community Trust Workflow

```text
1. DISCOVERY
   ├── User finds external content (GitHub, gist, forum)
   └── Downloads it

2. IMPORT (agent action)
   ├── Read/download content
   ├── Wrap in SKILL.md frontmatter (name, description)
   ├── Write to plugins/community/<id>/SKILL.md
   └── Register in plugins/INDEX.md as [discovered]

3. REVIEW (agent asks user)
   ├── "📦 Skill [name] detected"
   ├── Content preview
   └── "Enable now? [y/N]"

4. ACTIVATION (on approval)
   ├── INDEX.md status → enabled
   └── Available next session via Skill tool
```

> **Note:** This only fills what Claude Code doesn't natively provide — an import pipeline from external sources. Discovery and loading are handled by the native `Skill` tool.

---

## Relationship to Existing Systems

| System | Before | After |
|--------|--------|-------|
| SOPs | `archive/evolution/sops/*.md` flat dir | Still there; additionally discoverable via plugins |
| Guardrails | `AGENTS.md` inline | Can be extended via plugin guard contributions |
| Knowledge | `memory/` auto-memory only | Plugin knowledge adds structured domain context |
| Workflows | `archive/evolution/workflows/` | Still there; additionally registered via plugins |
