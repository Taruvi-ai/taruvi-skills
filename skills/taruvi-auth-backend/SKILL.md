---
name: taruvi-auth-backend
description: >
  Use this skill to understand how Taruvi authentication works on the backend —
  the redirect flow, token types, session management, and how the frontend
  auth provider maps to backend endpoints.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Documents the Taruvi authentication backend so the frontend auth flow is built correctly.

## Auth Flow

1. Frontend calls `authProvider.login()` → redirects to `/accounts/login/`
2. Backend renders login page (Django allauth)
3. User authenticates (credentials, OAuth, SSO)
4. Backend redirects back to callback URL with session token in URL hash: `#session_token=xxx`
5. Frontend SDK extracts token from hash and stores it automatically

## Token Types

- **Session token** — stored client-side, sent as `Authorization: Bearer <token>` on API requests
- Token is a JWT containing user identity claims
- Backend validates token on every API request via middleware

## Endpoints

| Endpoint | Purpose |
|---|---|
| `/accounts/login/` | Login page (redirect target) |
| `/accounts/signup/` | Registration page (redirect target) |
| `/accounts/logout/` | Logout (clears server session) |
| `/api/users/me/` | Get current authenticated user profile |

## Error Codes

| Status | Meaning | Frontend should |
|---|---|---|
| 401 | Not authenticated / token expired | Redirect to login |
| 403 | Authenticated but forbidden | Show access denied (do NOT redirect to login) |

## User Profile

`/api/users/me/` returns:
```json
{
  "id": 123,
  "username": "john",
  "email": "john@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "is_active": true,
  "is_staff": false,
  "is_superuser": false,
  "roles": [{ "name": "Editor", "slug": "editor", "type": "app_role" }],
  "groups": [],
  "user_permissions": [],
  "attributes": {},
  "date_joined": "2024-01-01T00:00:00Z",
  "last_login": "2024-06-15T10:30:00Z"
}
```


## MCP Tools

| Tool | Purpose |
|---|---|
| `create_update_secret` | Create or update secrets (e.g., API keys, DB credentials) |
| `list_secrets` | List secrets or secret types |
| `get_secret` | Get a specific secret |
| `manage_secret_types` | Create/manage secret type schemas |
