# Project Documentation

> Architecture docs and system guides.
> **Agent context:** Start at [CLAUDE.md](../CLAUDE.md) → [AGENTS.md](../AGENTS.md) for behavioral directives.

## System Architecture

```text
│              CLAUDE.md (Profile + Ref)        │
│  ┌──────────┐  ┌───────────┐  ┌───────────┐  │
│  │AGENTS.md │  │ RULES.md  │  │  Memory   │  │
│  │Behavior  │  │Archive    │  │Auto-memory│  │
│  │Directives│  │Routing    │  │Index      │  │
│  └──────────┘  └───────────┘  └───────────┘  │
│  ┌──────────────────────────────────────────┐ │
│  │        archive/evolution/                 │ │
│  │  logs → patterns → patches → sops        │ │
│  │         ↑ frontier-radar                 │ │
│  └──────────────────────────────────────────┘ │
│  ┌──────────┐  ┌───────────┐                  │
│  │archive/  │  │archive/   │                  │
│  │topics/   │  │outputs/   │                  │
│  │Knowledge │  │Deliverable│                  │
│  │Notes     │  │Outputs    │                  │
│  └──────────┘  └───────────┘                  │
└──────────────────────────────────────────────┘
```

## Key Files

| File | Purpose |
|------|---------|
| [CLAUDE.md](../CLAUDE.md) | User profile, workflow prefs, quick ref |
| [AGENTS.md](../AGENTS.md) | Agent behavioral directives, self-evolution protocol |
| [archive/RULES.md](../archive/RULES.md) | Archive routing, dedup, format, sharding rules |
| [archive/evolution/README.md](../archive/evolution/README.md) | Self-evolution engine — logs, patterns, patches, SOPs |
| [archive/INDEX.md](../archive/INDEX.md) | Archive knowledge index |
| [memory/MEMORY.md](../memory/MEMORY.md) | Auto-memory index (cross-session) |
