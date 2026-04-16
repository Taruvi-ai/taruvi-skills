---
name: taruvi-users
description: >
  Use this skill when the user is building user management features — user
  lists, user detail pages, user creation/editing, role assignment, or
  user-related data queries. Also use when the user mentions user profiles,
  user CRUD, or the userDataProvider.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for Taruvi user management — user CRUD, role assignment, user apps, and the `userDataProvider`.

**Compliance rule:** This skill's prescribed patterns (userDataProvider for user CRUD, server-side search/filter for user lists) are mandatory. Do not call user REST endpoints directly from components. If a requirement cannot be met, stop and ask the user.

## When to Use This Skill

- Building user list, detail, create, or edit pages
- Assigning or revoking roles
- Fetching user apps or preferences
- Using `userDataProvider` with `useList`, `useOne`, `useCreate`, `useUpdate`, `useDelete`

**Do not use this skill for:** login/logout/session (use `taruvi-auth`), permission checks (use `taruvi-access-control`).

## API Reference

### List Users

```tsx
const { result } = useList({
  resource: "users",
  dataProviderName: "user",
  pagination: { currentPage: 1, pageSize: 10 },
  filters: [
    { field: "is_active", operator: "eq", value: true },
    { field: "search", operator: "eq", value: "john" },
  ],
  sorters: [{ field: "username", order: "asc" }],
});
```

**Supported filters:**

| Field | Type | Description |
|---|---|---|
| `search` | `string` | Search by username, email, or name |
| `is_active` | `boolean` | Filter by active status |
| `is_staff` | `boolean` | Filter by staff status |
| `is_superuser` | `boolean` | Filter by superuser status |
| `is_deleted` | `boolean` | Filter by deleted status |

### Get User

```tsx
const { result } = useOne({ resource: "users", dataProviderName: "user", id: "john_doe" });
// Current authenticated user
const { result } = useOne({ resource: "users", dataProviderName: "user", id: "me" });
```

### Create User

```tsx
const { mutate } = useCreate();
mutate({
  resource: "users",
  dataProviderName: "user",
  values: {
    username: "jane",
    email: "jane@example.com",
    password: "...",
    confirm_password: "...",
    first_name: "Jane",
    last_name: "Doe",
  },
});
```

### Update User

```tsx
const { mutate } = useUpdate();
mutate({
  resource: "users",
  dataProviderName: "user",
  id: "jane",
  values: { first_name: "Jane", last_name: "Doe" },
});
```

### Delete User

```tsx
const { mutate } = useDelete();
mutate({ resource: "users", dataProviderName: "user", id: "jane" });
```

### Get User Roles

```tsx
const { result } = useList({
  resource: "roles",
  dataProviderName: "user",
  meta: { username: "john_doe" },
});
```

### Get User Apps

```tsx
const { result } = useList({
  resource: "apps",
  dataProviderName: "user",
  meta: { username: "john_doe" },
});
```

## Gotchas

- **Missing `dataProviderName: "user"`** — forgetting it routes the call to the default database provider, returning confusing errors.
- **User search** — use the `search` filter field, not `username__contains`. The backend search covers username, email, and name.
- **Role assignment is a separate operation** — creating a user does not assign roles. Use `sdk_client.users.assign_roles()` in a function, or the roles API separately.
