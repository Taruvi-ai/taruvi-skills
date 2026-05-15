# Taruvi Skills

AI agent skills for building Taruvi applications. Compatible with [npx skills](https://skills.sh) — works with Cursor, Claude Code, Codex, Gemini, and 40+ other agents.

## Install

```bash
# Install all Taruvi skills
npx skills add Taruvi-ai/taruvi-skills

# Install a specific skill
npx skills add Taruvi-ai/taruvi-skills --skill taruvi-app-developer
npx skills add Taruvi-ai/taruvi-skills --skill taruvi-refine-providers
```

## Available Skills

Two skills, split along the runtime boundary (browser vs Taruvi backend):

| Skill | Description |
|---|---|
| `taruvi-app-developer` | **Backend.** Provisioning via the Taruvi MCP server (datatables, Frictionless schemas, Cerbos policies, roles, users, buckets, secrets, analytics queries, audited raw SQL) and authoring Python serverless function bodies (`def main(params, user_data, sdk_client)`) for the Taruvi function runtime. |
| `taruvi-refine-providers` | **Frontend.** Wiring `@taruvi/refine-providers` and `@taruvi/sdk` into a Refine.dev app — data/storage/app/user data providers, authProvider, accessControlProvider, list/dashboard/dropdown UX defaults, multi-file upload, calling functions and analytics from the frontend, permission checks. |

## When to use which

- Working in `.py` files, MCP tool calls, schema definitions, policy authoring → **`taruvi-app-developer`**
- Working in `.tsx`/`.ts` Refine components, hooks, providers, frontend bug fixes → **`taruvi-refine-providers`**
- Cross-layer features (e.g., "add comments to blog posts") use both: provision backend with `taruvi-app-developer`, build UI with `taruvi-refine-providers`.

## Manage

```bash
# List installed skills
npx skills list

# Update to latest
npx skills check
npx skills update

# Remove a skill
npx skills remove taruvi-app-developer
```

## Skill Structure

Each skill follows the standard format:

```
<skill-name>/
  SKILL.md              # Frontmatter (name, description) + instructions
  references/*.md       # Supporting reference documents
  scripts/*             # Optional helper scripts
```

The `skills/` directory is auto-discovered by the `npx skills` CLI.

## License

MIT
