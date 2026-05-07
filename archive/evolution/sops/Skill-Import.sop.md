---
name: Skill Import
description: Import external content from GitHub/gist/URL as a native Claude Code SKILL.md
---

# Skill Import SOP

## When to Use
When a user finds external content (GitHub file, gist, raw URL) worth importing as a reusable skill into the local system.

## Prerequisites
- `curl` or `gh` CLI available for fetching remote content
- Write access to `plugins/community/` directory

## Steps

### 1. Locate Source Content

User provides a URL to a Markdown file or raw content:

- GitHub file → `https://raw.githubusercontent.com/owner/repo/ref/path/to/file.md`
- Gist → `https://gist.githubusercontent.com/owner/gist-id/raw/file.md`
- Any raw URL → direct fetch

### 2. Determine Skill Metadata

Derive from context:

- `name` — kebab-case id (from filename or purpose)
- `description` — one-line summary

### 3. Fetch Content

```bash
mkdir -p plugins/community/<name>/
curl -o /tmp/skill-raw.md <raw-url>
```

### 4. Wrap as SKILL.md

Take the fetched content and prepend frontmatter:

```markdown
---
name: <name>
description: <one-line description>
---

<original content>
```

Write to `plugins/community/<name>/SKILL.md`

### 5. Register in INDEX.md

Add entry under Community section:

```markdown
| [<name>](community/<name>/SKILL.md) | <description> | `discovered` |
```

Status values: `discovered` → `enabled` (after review) → `disabled` (if turned off).

### 6. Present for Review

Show user:

- Skill name and description
- Content preview (first 10 lines)
- Ask: "Enable now?"

### 7. Enable on Approval

On user approval:
1. Set INDEX.md status to `enabled`
2. `Skill` tool auto-discovers on next session start

## Verification

After import, confirm:

- [ ] `plugins/community/<name>/SKILL.md` exists with valid frontmatter
- [ ] `plugins/INDEX.md` has entry with correct status
- [ ] Content renders correctly (frontmatter `name`, `description` set)
