# Memory Tier Maintenance

`status: [verified] | task_types: [evolution, config]`

## When to Run

At session end during autonomous evolution step, OR on manual "进化" trigger.

## Steps

1. **Scan** — Read `MEMORY.md` + glob all `*.md` files in the memory directory
2. **Check staleness** — For each file with `tier` and `last_accessed`:
   - Hot + `last_accessed > 14d` → downgrade to Warm
   - Warm + `last_accessed > 30d` → downgrade to Cold
   - Cold + `last_accessed > 90d` → remove from MEMORY.md index (keep file)
3. **Promote hot entries** — If `access_count >= 5` and tier is Warm → promote to Hot
4. **Update files** — Edit `tier` field in memory file frontmatter
5. **Rebuild MEMORY.md** — Regroup entries into 🔥/💤/❄️ sections sorted by last_accessed desc
6. **Log** — Write evolution log entry with outcome

## Tools

- `Read` — memory files
- `Edit` — update tier/access_count fields
- `Write` — restructure MEMORY.md

## Fade Thresholds

| Tier | Threshold | Action |
|------|-----------|--------|
| Hot → Warm | 14d no access | Downgrade |
| Warm → Cold | 30d no access | Downgrade |
| Cold → drop | 90d no access | Remove from index (keep file) |
| Warm → Hot | access_count >= 5 | Promote |

## Files

- Memory index: `~/.claude/projects/c--Users-LIU-Desktop-agent/memory/MEMORY.md`
- Individual entries: `~/.claude/projects/c--Users-LIU-Desktop-agent/memory/*.md`
