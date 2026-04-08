---
name: functions
description: Use when writing, editing, or debugging Taruvi serverless functions. Covers APP/PROXY/SYSTEM execution modes, sdk_client usage, manage_function, executeFunction, executeFunctionAsync, event-driven triggers, scheduled cron jobs, multi-resource orchestration, async long-running tasks, and webhook forwarding.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Guide for authoring Taruvi serverless functions — deciding when a function is needed, which execution mode to use, how to call the injected `sdk_client`, and how to invoke functions from the frontend.

## When to Use This Skill

- Any action that touches **2 or more resources** (database + storage, users + database, etc.)
- Custom backend logic beyond simple CRUD
- Reacting to data events (`RECORD_CREATE`, `RECORD_UPDATE`, `RECORD_DELETE`)
- Reacting to user lifecycle events (`POST_USER_CREATE`, `POST_USER_DELETE`, etc.)
- Scheduled / cron background jobs
- Calling external APIs using stored secrets
- Long-running tasks (>30s) that must not block the UI
- Public unauthenticated endpoints
- Function-to-function pipelines
- Authorization-gated operations

**Do not use functions for:** single-table CRUD, file serving, login/logout, simple filtered lists, or single-source KPI queries. Use Refine provider hooks instead.

## Step-by-Step Instructions

1. Open and read `references/guardrails.md` — non-negotiables before any code.
2. Open and read `references/modes-and-triggers.md` — pick APP / PROXY / SYSTEM and the right trigger.
3. Open and read `references/sdk-surfaces.md` — available `sdk_client` modules.
4. Open and read `references/sdk-in-functions-key-points.md` — runtime contract details.
5. Open and read `references/resources.md` — common patterns per resource module.
6. Open and read `references/sdk-docs-workflow.md` — how to validate SDK behavior before coding.
7. Open and read `references/frontend-calling.md` — `executeFunction` vs `executeFunctionAsync`.
8. Open and read `references/when-not-to-use-functions.md` — confirm a function is actually needed.
9. Open and read `references/events-and-filters.md` — for event-triggered functions.
10. Open and read `references/scenarios.md` — complete worked examples.

Write function code only after reading all relevant references.

## Examples

**APP mode — minimal valid function:**
```python
def main(params, user_data, sdk_client):
    record = sdk_client.database.get("orders", record_id=params["order_id"])
    return {"success": True, "data": record}
```

**Frontend call — wait for result:**
```typescript
const result = await executeFunction("calculate-total", { items: [1, 2, 3] });
```

**Frontend call — fire and forget:**
```typescript
executeFunctionAsync("cleanup-deleted-tasks", { task_ids: ids }).catch(console.warn);
```

See `references/scenarios.md` for 8 complete end-to-end examples.

## Edge Cases

- **Wrong signature** — `main` must accept exactly `(params, user_data, sdk_client)`. Any deviation causes an immediate `SandboxError` before any code runs.
- **Trying to re-authenticate** — `sdk_client` is already authenticated. Never call auth methods on it.
- **Hardcoded secrets** — always use `sdk_client.secrets.get("KEY")`. Hardcoded values are a security violation.
- **PROXY vs APP** — if you only need to forward a payload to an external URL, use PROXY mode. APP mode is for custom Python logic.
- **Sync vs async** — tasks that may take >30s must use `is_async=True`. Synchronous calls will time out and leave the UI blocked.
- **print() vs log()** — `print()` is unstructured stdout only. `log()` produces structured, leveled, queryable entries on the invocation record.
- **Frontend cascade** — if you see multi-resource operations chained in frontend code, that is a bug. Move them to a function.

## References

- `references/guardrails.md` — core non-negotiables
- `references/modes-and-triggers.md` — APP/PROXY/SYSTEM and trigger types
- `references/sdk-surfaces.md` — available sdk_client modules
- `references/sdk-in-functions-key-points.md` — runtime contract
- `references/resources.md` — per-resource operation patterns
- `references/sdk-docs-workflow.md` — how to validate SDK behavior
- `references/frontend-calling.md` — executeFunction / executeFunctionAsync
- `references/when-not-to-use-functions.md` — decision table
- `references/events-and-filters.md` — event triggers and CEL filters
- `references/scenarios.md` — 8 complete worked examples
