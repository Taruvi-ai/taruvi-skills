---
name: taruvi-refine-providers
description: >
  Use this skill when the user is setting up, wiring, debugging, or migrating
  Taruvi Refine providers in a frontend app — including data providers, auth
  provider, access control, or SDK client configuration. Also use when the user
  encounters 401/403 errors, token refresh issues, permission check problems,
  or needs to call a Taruvi function or analytics query from the frontend,
  even if they don't mention "providers" directly.
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

1. Open and read `references/overview.md` — install, quick-start, providers at a glance.
2. Open and read `references/provider-map.md` — routing guide to individual provider files.
3. Open and read the specific provider reference(s) for the task:
   - Database CRUD / filters / aggregation / graph → `references/database-provider.md`
   - File upload / download / storage → `references/storage-provider.md`
   - Functions / analytics / roles / secrets → `references/app-provider.md`
   - User management → `references/user-provider.md`
   - Login / logout / token flow → `references/auth-provider.md`
   - Permissions / `useCan` / `CanAccess` → `references/access-control-provider.md`
   - TypeScript types / utilities / deprecated migration → `references/types-and-utilities.md`
4. Install dependencies:
   ```bash
   npm install @taruvi/refine-providers @taruvi/sdk @refinedev/core
   ```
5. Create the SDK client with `apiKey`, `appSlug`, and `apiUrl`.
6. Wire all relevant providers into `<Refine>`.
7. Use provider-native hooks (`useList`, `useCreate`, `useCustom`, `useCan`) — do not call REST directly from components.

### Verification checklist

After wiring providers, verify:

- [ ] SDK client uses env vars (`import.meta.env.VITE_TARUVI_*`), not hardcoded values
- [ ] All four data providers are wired: `default`, `storage`, `app`, `user`
- [ ] `authProvider` and `accessControlProvider` are both passed to `<Refine>`
- [ ] No direct REST/fetch calls from components — all data flows through hooks
- [ ] No use of deprecated `functionsDataProvider` or `analyticsDataProvider`
- [ ] `useCustom` calls for functions use `dataProviderName: "app"` and `meta.kind: "function"`

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

## Gotchas

- **Deprecated providers** — `functionsDataProvider` and `analyticsDataProvider` are removed. Migrate to `appDataProvider` + `useCustom` with `meta.kind: "function"` or `meta.kind: "analytics"`. Old imports will compile but throw at runtime.
- **Auth redirect loop** — `authProvider.login()` redirects to `/accounts/login/` and tokens come back in the URL hash. Do not try to intercept mid-redirect or parse the URL yourself — the provider handles it.
- **401 vs 403 confusion** — `onError()` handles both: 401 means session expired (trigger re-login), 403 means authenticated but forbidden (show access denied). Treating 403 as 401 causes infinite re-login loops.
- **Access control entity type** — `useCan` resolves the entity type in this order: `params.entityType` → `resource.meta.entityType` → resource name. If permissions seem wrong, the entity type is almost always the cause — check the resolution chain.
- **DataLoader batching** — `accessControlProvider` batches `useCan` calls automatically via DataLoader. Do not debounce or throttle `useCan` manually — it will interfere with the batch delay and cause missed permission checks.
- **Wrong `dataProviderName`** — forgetting `dataProviderName: "app"` on `useCustom` for functions routes the call to the default (database) provider, returning a confusing "resource not found" error. Same applies to `"storage"` and `"user"`.
- **`url: ""` is required** — `useCustom` requires a `url` parameter even for function/analytics calls. Pass an empty string `""` — the provider ignores it and routes via `meta.kind`.

## References

- `references/overview.md` — install, quick-start, providers at a glance
- `references/provider-map.md` — routing guide to individual provider files
- `references/database-provider.md` — CRUD, filters, operators, sorting, pagination, aggregation, graph
- `references/storage-provider.md` — upload, batch upload, delete, metadata, filters
- `references/app-provider.md` — roles, settings, secrets, function execution, analytics
- `references/user-provider.md` — user CRUD, roles, apps
- `references/auth-provider.md` — login/logout/register, token flow, identity, permissions
- `references/access-control-provider.md` — useCan, CanAccess, entity type resolution, batching
- `references/types-and-utilities.md` — TaruviMeta, StorageUploadVariables, utility functions, deprecated migration
