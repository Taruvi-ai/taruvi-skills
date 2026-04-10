# Access Control Provider

Resource-based authorization using Cerbos policies. Batches multiple `useCan` calls into a single API request using DataLoader.

## Setup

```tsx
<Refine
  authProvider={authProvider(client)}
  accessControlProvider={accessControlProvider(client)}
/>
```

## Options

```tsx
accessControlProvider(client, {
  batchDelayMs: 50, // ms to wait before batching (default: 50)
});
```

## Check Permissions

```tsx
const { data } = useCan({
  resource: "posts",
  action: "edit",
  params: { id: 1 },
});

if (data?.can) {
  // User can edit this post
}
```

## CanAccess Component

```tsx
<CanAccess resource="posts" action="delete" params={{ id: 1 }}>
  <DeleteButton />
</CanAccess>
```

## Entity Type Resolution

Cerbos policies use entity types. Resolution priority:

1. `params.entityType` — direct override in `useCan`
2. `resource.meta.entityType` — from Refine resource config
3. Resource name — fallback

```tsx
// Set via resource config
<Refine resources={[{ name: "posts", meta: { entityType: "blog" } }]} />

// Override per-check
useCan({
  resource: "posts",
  action: "edit",
  params: { id: 1, entityType: "article" },
});
```

## Caching

Uses Refine's built-in TanStack Query caching:
- `staleTime`: 5 minutes
- `gcTime`: 10 minutes

DataLoader handles request batching only (its own cache is disabled).

## Default UI Behavior

- `buttons.enableAccessControl`: `true` — access control checks enabled on all buttons
- `buttons.hideIfUnauthorized`: `true` — buttons are hidden (not just disabled) when unauthorized
