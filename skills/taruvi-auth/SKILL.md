---
name: taruvi-auth
description: >
  Use this skill when the user is implementing login, logout, signup, session
  management, token handling, or debugging authentication errors (401, redirect
  loops, token extraction). Also use when the user encounters "not authenticated"
  errors or needs to understand the auth redirect flow.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for Taruvi authentication — redirect-based login/logout, token extraction, session checks, and error handling.

**Compliance rule:** This skill's prescribed auth flow (redirect-based, provider-handled token extraction) is mandatory. Do not intercept redirects, parse URL tokens manually, or build custom auth flows. If a requirement cannot be met, stop and ask the user.

## When to Use This Skill

- Implementing login/logout/signup flows
- Debugging 401 errors or redirect loops
- Understanding the token extraction flow
- Configuring `authProvider` in `<Refine>`

**Do not use this skill for:** access control / permission checks (use `taruvi-access-control`), user CRUD (use `taruvi-users`).

## Auth Flow

1. `login()` → redirects to backend `/accounts/login/`
2. User authenticates on backend
3. Backend redirects back with tokens in URL hash
4. Client extracts and stores tokens automatically

## API Reference

### Login

```tsx
const { mutate: login } = useLogin();
login({ callbackUrl: "/dashboard" });
```

### Logout

```tsx
const { mutate: logout } = useLogout();
logout({ callbackUrl: "/login" });
```

### Register

```tsx
const { mutate: register } = useRegister();
register({ callbackUrl: "/welcome" });
```

### Get Current User

```tsx
const { data: user } = useGetIdentity<UserData>();
```

### Get Permissions

```tsx
const { data: permissions } = usePermissions();
// permissions.roles, permissions.permissions, permissions.groups
// permissions.is_staff, permissions.is_superuser
```

### Auth Check Behavior

- `check()` returns `{ authenticated: true }` if a session token exists, otherwise redirects to `/login`
- `onError()` returns `{ logout: true, redirectTo: "/login" }` for 401/403. Other errors pass through.

### Parameter Types

```tsx
import type { LoginParams, LogoutParams, RegisterParams } from "@taruvi/refine-providers";
// LoginParams:   { callbackUrl?: string; username?: string; password?: string; redirect?: boolean }
// LogoutParams:  { callbackUrl?: string }
// RegisterParams:{ callbackUrl?: string }
```

## Gotchas

- **Auth redirect loop** — `authProvider.login()` redirects to `/accounts/login/` and tokens come back in the URL hash. Do not intercept mid-redirect or parse the URL yourself.
- **401 vs 403 confusion** — 401 means session expired (trigger re-login), 403 means authenticated but forbidden (show access denied). Treating 403 as 401 causes infinite re-login loops.
- **Calling `check()` too early** — `check()` only verifies a token exists locally. Server-side validation happens via `onError` when API calls fail.
