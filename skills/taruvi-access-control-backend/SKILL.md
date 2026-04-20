---
name: taruvi-access-control-backend
description: >
  Use this skill to understand how Taruvi's Cerbos-based access control works
  on the backend — policy structure, resource kind format, principal resolution,
  and how frontend permission checks map to backend policy evaluation.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Documents how Cerbos policies work on the Taruvi backend so the frontend sends correct permission check requests.

## Resource Kind Format

Backend policies use prefixed resource identifiers: `{entity_type}:{resource_name}`

| Prefix | Example | Used for |
|---|---|---|
| `datatable` | `datatable:employees` | Table CRUD |
| `function` | `function:employee-terminate` | Function execution |
| `query` | `query:hrms-dashboard-summary` | Analytics query execution |
| Custom | `invoice:sales_invoices` | Custom entity types |

The separator is `:` (defined in `CERBOS_RESOURCE_SEPARATOR`).

## Principal Resolution

The backend auto-resolves the authenticated user as the Cerbos principal. Frontend never sends principal data — it's extracted from the session token server-side.

Principal structure sent to Cerbos:
```
{
  id: "<user_id>",
  roles: ["admin", "editor", ...],
  attr: { username, email, first_name, last_name, is_staff, is_superuser, groups: [...] }
}
```

## Policy Structure

Policies are resource policies with rules:
```json
{
  "entity_type": "datatable",
  "entity_id": "employees",
  "rules": [
    { "actions": ["read", "create"], "effect": "EFFECT_ALLOW", "roles": ["admin", "hr_manager"] },
    { "actions": ["read"], "effect": "EFFECT_ALLOW", "roles": ["viewer"] },
    { "actions": ["delete"], "effect": "EFFECT_DENY", "roles": ["*"] }
  ]
}
```

## Actions

Standard actions the backend recognizes:
- `read` — view/list records
- `create` — create new records
- `update` — modify existing records
- `delete` — remove records
- `execute` — run a function or analytics query
- `*` — wildcard (all actions)

## Check Endpoint

`POST /api/apps/{app_slug}/policy/check/resources/`

The frontend `accessControlProvider` batches multiple `useCan` calls into a single request to this endpoint. Each resource in the batch payload has:
- `resource.kind` — must be the prefixed string (e.g., `datatable:employees`)
- `resource.id` — record ID or `*` for collection-level checks
- `actions` — array of actions to check

## Caching

- Backend policy version: `default`
- Frontend caches results for 5 minutes (staleTime) via TanStack Query
- Policy changes take effect after cache expires or page refresh

## Derived Roles

Cerbos supports derived roles — roles computed from conditions (e.g., "owner" if `request.resource.attr.created_by == request.principal.id`). These are configured in Cerbos policy files, not via the API.


## MCP Tools

| Tool | Purpose |
|---|---|
| `manage_policies` (action: create_update) | Create or update Cerbos policies |
| `manage_policies` (action: get) | Get policy by ID or list policies |
| `manage_policies` (action: enable/disable) | Enable or disable a policy |
