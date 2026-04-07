# Taruvi Skills

AI agent skills for building Taruvi applications. Compatible with [npx skills](https://skills.sh) — works with Cursor, Claude Code, Codex, Gemini, and 40+ other agents.

## Install

```bash
# Install all Taruvi skills
npx skills add Taruvi-ai/taruvi-skills

# Install a specific skill
npx skills add Taruvi-ai/taruvi-skills --skill functions
npx skills add Taruvi-ai/taruvi-skills --skill refine-providers
```

## Available Skills

| Skill | Description |
|---|---|
| `taruvi-app-developer` | Entry-point router — runtime/packages/deploy references, then routes to the right module |
| `functions` | Serverless function guardrails, modes, triggers, SDK usage, event subscriptions |
| `refine-providers` | Frontend provider wiring — database, storage, app, user, auth, access control |
| `database` | Datatable queries, aggregation, graph operations |
| `storage` | Bucket/object management, batch operations, quotas |

## Manage

```bash
# List installed skills
npx skills list

# Update to latest
npx skills check
npx skills update

# Remove a skill
npx skills remove functions
```

## Skill Structure

Each skill follows the standard format:

```
<skill-name>/
  SKILL.md            # Frontmatter (name, description) + instructions
  reference/*.md      # Supporting reference documents
```

The `skills/` directory is auto-discovered by the `npx skills` CLI.

## License

MIT
