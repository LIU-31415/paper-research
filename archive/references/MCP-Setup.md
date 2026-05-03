# MCP Server Setup

## Memory Knowledge Graph (Layer 2)

Layer 2 of the memory hierarchy uses an MCP Knowledge Graph to store entities and semantic relationships across topics.

### Required Server

**`@anthropic/mcp-server-memory`** — stores entities, relations, and observations as a local knowledge graph.

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-memory", "--memory-path", "C:/Users/LIU/.claude/memory/memory.json"]
    }
  }
}
```

### Usage Rules

As defined in `CLAUDE.md` Knowledge Graph Rules:

- New project/technology → create Entity + Observations
- Dependency/connection between known entities → create Relation
- Information conflict → prompt user to confirm

### When to Query

During any session where cross-topic connections matter:
- A new task references something from a past topic
- User asks "have we dealt with X before?"
- Before writing an archive entry that may duplicate or extend existing knowledge

### Relation to Archive

| Aspect | Archive (Layer 1) | Knowledge Graph (Layer 2) |
|--------|-------------------|---------------------------|
| Storage | Markdown files | JSON graph |
| Content | Full entries | Entities + relations |
| Query | Read topic file | Graph traversal |
| Best for | Deep knowledge per topic | Cross-topic connections |
