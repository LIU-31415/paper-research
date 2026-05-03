# SOP Extraction Workflow

Extract reusable Standard Operating Procedures from successful task trajectories.

## Trigger

Run when:
- A task completes with `outcome: success` and `duration_min >= 10`
- Weekly review / maintenance

## Process

### Step 1: Select Source Logs

Scan `archive/evolution/logs/` or `archive/sessions/` for successful outcomes:

```bash
grep "outcome: success" archive/evolution/logs/*.md
grep -l "^tags:" archive/sessions/*.md
```

### Step 2: Extract Trajectory

For each successful task, extract:

| Field | Source |
|-------|--------|
| task_type | log entry `type:` field |
| approach | log entry `approach:` field |
| tools_used | log entry `tools_used:` field |
| key_decisions | session body / log body |
| step_sequence | chronological steps from log body |
| pain_points | implicit — things that almost went wrong |

### Step 3: Cluster by Task Type

Group similar task_types together. Common clusters:
- **tech/tool-install**: gh CLI, MCP servers, VPN
- **tech/archive**: memory system, evolution system
- **research/literature**: paper search, cross-validation
- **writing/proposal**: research proposals, abstracts

### Step 4: Generate SOP

Write SOP to `archive/evolution/sops/{cluster-name}.md`.

SOP template:

```markdown
# {Cluster Name}

type: {task_type}
generated: YYYY-MM-DD
updated: YYYY-MM-DD
source_logs: [paths to source logs]

## Step Sequence

1. **Phase 1: {Phase Name}**
   - Action 1
   - Action 2

2. **Phase 2: {Phase Name}**
   - Action 1

## Tool Checklist

- {tool}: {purpose}

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Common Pitfalls

- {pitfall}: {prevention}
```
