---
name: taruvi-access-control
description: >
  Use this skill when the user is implementing permission checks, role-based
  UI visibility, menu item access control, or debugging 403 errors and
  missing/hidden UI elements. Also use when the user mentions Cerbos policies,
  useCan, CanAccess, or permission denied errors.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for Taruvi access control — Cerbos-based permission checks, prefixed ACL resource strings, menu integration, and batching behavior.

**Compliance rule:** This skill's prescribed ACL contract (prefixed resource strings, no `params.entityType`) is mandatory. Do not use bare resource names in `useCan`/`CanAccess` page-level checks. If a requirement cannot be met, stop and ask the user.

## When to Use This Skill

- Wiring `accessControlProvider` into `<Refine>`
- Using `useCan` or `CanAccess` in pages
- Setting up menu item permission checks
- Debugging 403 errors or hidden UI elements

**Do not use this skill for:** login/logout/session (use `taruvi-auth`), user CRUD (use `taruvi-users`).

## Setup

```tsx
<Refine
  authProvider={authProvider(client)}
  accessControlProvider={accessControlProvider(client)}
/>
```

## API Reference

### Check Permissions

Use prefixed ACL resource strings — format: `<kind>:<name>`.

```tsx
const { data } = useCan({
  resource: "datatable:posts",
  action: "edit",
  params: { id: 1 },
});

if (data?.can) {
  // User can edit this post
}
```

Do **not** use `params.entityType` — pass the prefixed resource string directly.

### CanAccess Component

```tsx
<CanAccess resource="datatable:posts" action="delete" params={{ id: 1 }}>
  <DeleteButton />
</CanAccess>
```

### Resource Prefixes

| Prefix | Use for |
|---|---|
| `datatable:<name>` | Datatable CRUD operations |
| `function:<slug>` | Serverless function execution |
| `query:<slug>` | Analytics query execution |

### Menu Integration

Menu components use `getAclResource(item)` from `src/utils/aclResource.ts` which reads `meta.aclResource` from the Refine resource definition:

```tsx
resources={[
  { name: "employees", meta: { aclResource: "datatable:employees" }, list: "/employees" },
  { name: "reports", meta: { aclResource: "query:monthly-report" }, list: "/reports" },
]}
```

No menu component changes needed — just set `meta.aclResource` on each resource.

### Options

```tsx
accessControlProvider(client, {
  batchDelayMs: 50, // ms to wait before batching (default: 50)
});
```

### Caching

- `staleTime`: 5 minutes
- `gcTime`: 10 minutes
- DataLoader handles request batching only (its own cache is disabled).

### Default UI Behavior

- `buttons.enableAccessControl`: `true` — access control checks enabled on all buttons
- `buttons.hideIfUnauthorized`: `true` — buttons are hidden (not just disabled) when unauthorized

## Gotchas

- **Bare resource names in page checks** — `useCan`/`CanAccess` in pages must use prefixed strings (`datatable:employees`), not bare names.
- **`params.entityType` is removed** — do not pass `entityType` in params. The prefix in the resource string replaces it.
- **DataLoader batching** — the provider batches `useCan` calls automatically. Do not debounce or throttle manually.
- **403 vs hidden** — by default, unauthorized buttons are hidden (`hideIfUnauthorized: true`), not disabled.
- **Network payload mismatch** — verify in browser network logs that each `check/resources` `resource.kind` exactly matches the requested `resource` string.
