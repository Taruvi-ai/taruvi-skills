---
name: taruvi-functions
description: >
  Use this skill when the user needs to call a Taruvi serverless function from
  the frontend — including synchronous calls that wait for results, async
  fire-and-forget calls, or wiring function execution into React components
  via useCustom or helper utilities.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for calling Taruvi serverless functions from the frontend — via `appDataProvider` + `useCustom` or helper utilities.

**Compliance rule:** Always use `dataProviderName: "app"` and `meta: { kind: "function" }` for function calls. Do not call function REST endpoints directly from components. If a requirement cannot be met, stop and ask the user.

## When to Use This Skill

- Calling a serverless function from a React component
- Wiring function execution into a button, form submission, or page load
- Choosing between sync (wait for result) and async (fire-and-forget) execution
- Debugging "resource not found" errors on function calls

**Do not use this skill for:** writing the Python function itself (use `taruvi-functions-backend`), analytics query execution (use `taruvi-analytics`).

## API Reference

### Sync Execution (wait for result)

Use `useCustom` with `meta.kind: "function"`. The `url` is the function slug.

```tsx
const { result, query } = useCustom({
  dataProviderName: "app",
  url: "process-order",
  method: "post",
  config: {
    payload: { orderId: 123, action: "confirm" },
  },
  meta: { kind: "function" },
});
```

### Async Execution (fire-and-forget)

```tsx
useCustom({
  dataProviderName: "app",
  url: "long-running-task",
  method: "post",
  config: { payload: { taskId: 789 } },
  meta: { kind: "function", async: true },
});
```

### Helper Utilities

```typescript
import { executeFunction, executeFunctionAsync } from "../../utils/functionHelpers";

// Wait for result
const result = await executeFunction("calculate-total", { items: [1, 2, 3] });

// Fire and forget
executeFunctionAsync("cleanup-tasks", { task_ids: [1, 2] }).catch(console.warn);
```

- `executeFunction(...)`: use when UI must wait for result.
- `executeFunctionAsync(...)`: use for fire-and-forget/background flows.

### Meta Types

```tsx
import type { FunctionMeta } from "@taruvi/refine-providers";
// FunctionMeta: { kind: "function"; async?: boolean }
```

## Gotchas

- **Missing `dataProviderName: "app"`** — forgetting it routes the call to the default database provider, returning "resource not found."
- **Missing `meta.kind: "function"`** — without it, the app provider doesn't know to route to the function engine.
- **Function slug mismatch** — the `url` must be the exact function slug, not the display name.
- **Sync timeout** — functions that take >30s will time out on sync calls. Use `meta.async: true` for long-running work.
- **Frontend cascade** — if you see multi-resource operations chained in frontend code (delete task → delete attachments → delete activities), that is a bug. Move the chain to a single backend function and call it once.
- **Keep payloads small** — move multi-step side effects into backend function code, not frontend.
