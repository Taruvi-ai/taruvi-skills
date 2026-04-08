---
name: taruvi-refine-providers
description: Use when setting up or working with Taruvi Refine providers — dataProvider, storageDataProvider, appDataProvider, userDataProvider, authProvider, accessControlProvider, @taruvi/refine-providers, @taruvi/sdk Client setup, useList, useCreate, useCustom, useCan, authProvider login flow, or access control batching.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for wiring and using Taruvi's Refine data providers in the frontend — covering client setup, all provider types, hook usage, auth flow, and access control batching.

## When to Use This Skill

- Setting up `@taruvi/refine-providers` for the first time in a project
- Wiring `dataProvider`, `storageDataProvider`, `appDataProvider`, `userDataProvider` into `<Refine>`
- Configuring `authProvider` and understanding the login/token redirect flow
- Configuring `accessControlProvider` and using `useCan`
- Using `useCustom` with `meta.kind: "function"` or `meta.kind: "analytics"`
- Migrating from deprecated `functionsDataProvider` / `analyticsDataProvider`
- Debugging auth errors (401/403), token refresh, or access control resolution

**Do not use this skill for:** Python function authoring (use `taruvi-functions` skill), storage REST endpoints (use `taruvi-storage` skill), or raw database query optimization (use `taruvi-database` skill).

## Step-by-Step Instructions

1. Open and read `references/overview.md` for client setup and provider name map.
2. Open and read `references/provider-map.md` for per-provider behavior details.
3. Install dependencies:
   ```bash
   npm install @taruvi/refine-providers @taruvi/sdk @refinedev/core
   ```
4. Create the SDK client with `apiKey`, `appSlug`, and `baseUrl`.
5. Wire all relevant providers into `<Refine>`.
6. Use provider-native hooks (`useList`, `useCreate`, `useCustom`, `useCan`) — do not call REST directly from components.

## Examples

**Client and provider setup:**
```tsx
import { Client } from "@taruvi/sdk";
import {
  dataProvider,
  storageDataProvider,
  appDataProvider,
  userDataProvider,
  authProvider,
  accessControlProvider,
} from "@taruvi/refine-providers";

const client = new Client({
  apiKey: import.meta.env.VITE_TARUVI_API_KEY,
  appSlug: import.meta.env.VITE_TARUVI_APP_SLUG,
  baseUrl: import.meta.env.VITE_TARUVI_BASE_URL,
});

<Refine
  dataProvider={{
    default: dataProvider(client),
    storage: storageDataProvider(client),
    app: appDataProvider(client),
    user: userDataProvider(client),
  }}
  authProvider={authProvider(client)}
  accessControlProvider={accessControlProvider(client)}
/>
```

**Execute a function via `appDataProvider`:**
```typescript
const { data } = useCustom({
  url: "",
  method: "post",
  dataProviderName: "app",
  meta: { kind: "function", slug: "my-function", params: { id: 1 } },
});
```

**Check permission with `useCan`:**
```typescript
const { data: canEdit } = useCan({
  resource: "orders",
  action: "edit",
  params: { id: record.id },
});
```

## Edge Cases

- **Deprecated providers** — `functionsDataProvider` and `analyticsDataProvider` are removed. Migrate to `appDataProvider` + `useCustom` with `meta.kind: "function"` or `meta.kind: "analytics"`.
- **Auth redirect loop** — `authProvider.login()` redirects to `/accounts/login/` and tokens come back in the URL hash. Do not try to intercept mid-redirect.
- **401 vs 403** — `onError()` handles both: 401 means session expired (trigger re-login), 403 means authenticated but forbidden (show access denied, do not re-login).
- **Access control entity type** — `useCan` resolves the entity type in this order: `params.entityType` → `resource.meta.entityType` → resource name. If permissions seem wrong, check the entity type chain.
- **DataLoader batching** — `accessControlProvider` batches `useCan` calls automatically. Do not debounce manually — it will interfere with the batch delay.

## References

- `references/overview.md` — install, client setup, provider name map
- `references/provider-map.md` — per-provider behavior, auth flow, access control batching, types, migration notes
