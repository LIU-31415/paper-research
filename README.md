# Paper Search

A Perplexity-style multi-source search & synthesis protocol for academic literature and general research. Designed for use with Claude Code as a custom skill.

## Usage

This is a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills). Place `SKILL.md` in your skills directory and it will be auto-discovered by the `Skill` tool.

## Features

- **Query Expansion**: Auto-expand 1 question into 3-5 search variants across languages and perspectives
- **Parallel Search**: Concurrent queries across WebSearch, Semantic Scholar, and Google Scholar
- **Cross-Validation**: Internal quality assessment before synthesis
- **Synthesis**: Multi-source merge with dedup, extracting 3-5 key insights
- **Follow-up**: Auto-generated deep-dive directions

## License

MIT
