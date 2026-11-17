# Function authoring — runtime contract, modes, triggers, guardrails

This is the canonical reference for authoring Taruvi serverless function bodies. Read this before writing any function code. For per-module SDK signatures, see [`function-sdk-reference.md`](function-sdk-reference.md). For event filters, see [`function-events.md`](function-events.md). For worked end-to-end examples, see [`function-scenarios.md`](function-scenarios.md).

## Guardrails (non-negotiable)

- Use the exact APP-mode signature: `main(params, user_data, sdk_client)`.
- Never re-authenticate the injected `sdk_client` — it's already authenticated.
- Never hardcode secret values. Read via `sdk_client.secrets.get(...)`.
- Return JSON-serializable payloads only.
- Use serverless functions for multi-resource side effects, not frontend cascades.
- Read this skill's references for SDK shapes — never invent method names, event names, or API URLs.

## Runtime contract

### APP-mode entrypoint

```python
def main(params, user_data, sdk_client):
    # params: user-supplied input dict; may include params["__function__"] metadata
    # user_data: authenticated user context (None for public functions)
    # sdk_client: pre-authenticated SyncClient — do not re-authenticate
    ...
    return {"key": "value"}   # JSON-serializable only
```

Any deviation from this signature causes an immediate `SandboxError` before any code runs.
Extra parameters — including `*args` / `**kwargs` — are rejected; the signature must be
exactly `main(params, user_data, sdk_client)`.

### Sandbox limitations (RestrictedPython / Celery engine)

On the default Celery engine, function bodies run under **RestrictedPython**, which forbids
several ordinary Python constructs. `eval` / `exec` are rejected at **save time** by the
security scan; the rest are simply absent from the sandbox builtins and raise an opaque
`NameError` at **run time**. Write to these limits — the newer runner engine executes
ordinary Python in a kernel jail and lifts them, but code that avoids them runs on both:

- **No `class` statements** — defining a class raises `NameError: __metaclass__` at run
  time. Use plain functions and dicts instead of classes.
- **No argument unpacking at call sites** — `f(*args)` / `f(**kwargs)` raises
  `NameError: _apply_` at run time. Pass arguments explicitly, e.g. `f(a, b)` or
  `dict(a=1, b=2)`.
- **No `next()` or `iter()` builtins** — not in the sandbox's allowed builtins. Iterate
  with `for` loops / comprehensions instead of manual `next(iter(...))`; use `seq[0]` for
  the first element.
- **No `eval()` / `exec()`** — rejected at save time. There is no supported alternative,
  by design.

Separately, extra parameters on `main` itself — including `*args` / `**kwargs` **in the
signature** — are rejected at save time by the signature check, before any code runs. That
is a different mechanism from the call-site unpacking above: the signature check is a
save-time rejection, call-site unpacking is a run-time `NameError`.

### `sdk_client` execution identity and permissions

The injected `sdk_client` is **not** a privileged service account. It authenticates with a
short-lived SYSTEM token minted **for the calling user** — their identity is preserved — or
for the **function's creator** on scheduled runs and anonymous calls to a public function
(an anonymous caller supplies no identity of its own). Running a function grants no resource
access the token's user doesn't already have: a datatable, storage or policy operation the
caller couldn't perform directly is **denied the same way inside the function** (the server
authorizes it against that same principal). Treat an authorization failure as expected
behavior, not a function bug:

```python
def main(params, user_data, sdk_client):
    # If the calling user lacks read access to this table, the SDK call is rejected
    # (HTTP 403 / FORBIDDEN, surfaced as an SDK error). The function cannot read it on
    # the caller's behalf. Let it propagate, or handle it explicitly:
    try:
        rows = sdk_client.database.from_("payroll").execute()
    except Exception as exc:
        log("payroll read denied", level="warning", data={"error": str(exc)})
        return {"ok": False, "error": "not authorized"}
    return {"ok": True, "count": len(rows)}
```

**One deliberate exception — secrets.** The SYSTEM token bypasses the per-user secret
permission and sensitivity checks, so `sdk_client.secrets.get(...)` can read `sensitive`
secrets the caller could **not** read directly. Treat secret values as privileged: never
return them to the caller or write them into a result the caller can read.

### Injected `sdk_client` modules

All available at `sdk_client.<module>`:

- `database`
- `functions`
- `storage`
- `secrets`
- `users`
- `analytics`
- `policy`
- `app`
- `settings`

Use module-native methods. Do not invent method names. Full reference: [`function-sdk-reference.md`](function-sdk-reference.md).

### Common patterns

- Long-running tasks → `sdk_client.functions.execute(..., is_async=True)` and poll with `get_result`.
- Policy checks → `policy.check_resources(...)`; pass `principal=None` so the server resolves the principal.
- Secrets → `sdk_client.secrets.get(...)` / `list(...)`; never hardcode.

### Safety and reliability

- Use `log()` (not `print()`) for structured, leveled, queryable logging.
- Validate input `params` before any side effects.
- Keep cross-resource orchestration in functions, not frontend.

## Execution modes

| Mode | Use for | Required input |
|---|---|---|
| `app` | Custom Python logic with SDK access | `code` |
| `proxy` | Forward request to an external webhook URL | `webhook_url` |
| `system` | Internal registered platform logic | (internal registration) |

The mode must be set at creation time. Without it, the function cannot be routed and creation fails.

### Examples — function definitions

Send these through the MCP server's function create/update tool (check its input schema for the exact shape):

```jsonc
// APP mode — custom Python logic
{
  "name": "process-order",
  "execution_mode": "app",
  "code": "def main(params, user_data, sdk_client):\n    return {}"
}

// PROXY mode — forward to a webhook
{
  "name": "notify-slack",
  "execution_mode": "proxy",
  "webhook_url": "https://hooks.slack.com/services/xxx"
}

// SYSTEM mode — registered internal function
{
  "name": "cleanup_logs",
  "execution_mode": "system"
}
```

To change an existing function, update it by its slug rather than creating it again by name.

## Trigger types

| Trigger | Use for |
|---|---|
| API | Manual or user-initiated, called from frontend |
| Event | React to row or user events (`RECORD_CREATE`, `POST_USER_CREATE`, …) |
| Schedule | Periodic / cron (e.g., `0 8 * * 1` = Monday 8am) |
| API async (`is_async=True`) | Long-running workloads — returns `task_id` immediately |
| API public (`is_public=True`) | Unauthenticated external endpoints (webhooks, payments) |

For event triggers and CEL filter expressions, see [`function-events.md`](function-events.md).

## Frontend invocation

Functions registered with API trigger are called from the Refine frontend using `appDataProvider` + `useCustom` with `meta.kind: "function"`. The contract is documented in the `taruvi-refine-providers` skill. Brief example:

```typescript
const { data } = useCustom({
  url: "calculate-total",                  // function slug
  method: "post",
  dataProviderName: "app",
  payload: { items: [1, 2, 3] },           // function input
  meta: { kind: "function" },
});
```

For long-running work, prefer async functions and polling/status UX on the frontend.

## SDK docs workflow

Before writing any APP-mode body, read in this order:

1. This file (`function-authoring.md`) — runtime contract, modes, triggers.
2. [`function-sdk-reference.md`](function-sdk-reference.md) — per-module operation patterns (`database`, `storage`, `secrets`, `users`, `analytics`, `policy`, `app`, `settings`, `functions`).
3. [`function-events.md`](function-events.md) — only if the function is event-triggered.
4. [`function-scenarios.md`](function-scenarios.md) — when you want a worked example.

Rules:

- Never write Taruvi SDK code from memory — always check the bundled references first.
- Never invent SDK method names, event names, or API URLs.
- If the references don't cover a method or behavior, stop and ask for clarification instead of guessing.
- Match examples to the runtime: Python (`sdk_client`) for function bodies, TypeScript for frontend.
