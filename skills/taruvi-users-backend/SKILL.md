---
name: taruvi-users-backend
description: >
  Use this skill to understand what the Taruvi user management backend supports —
  user fields, search/filter capabilities, role assignment, user attributes,
  and preferences.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Documents the Taruvi user management backend capabilities so the frontend is built correctly.

## User Fields

| Field | Type | Notes |
|---|---|---|
| `id` | UUID | Primary key |
| `username` | string | Unique, supports special characters |
| `email` | string | Unique |
| `first_name`, `last_name` | string | Display name |
| `is_active` | boolean | Account status |
| `is_staff` | boolean | Staff access |
| `is_superuser` | boolean | Full admin |
| `is_deleted` | boolean | Soft delete |
| `date_joined` | datetime | Registration date |
| `last_login` | datetime | Last login timestamp |
| `attributes` | JSONB | Custom user attributes (schema-validated) |
| `roles` | array | Assigned app roles |
| `groups` | array | Django groups |
| `user_permissions` | array | Direct permissions |

## List Filters

| Filter | Type | Meaning |
|---|---|---|
| `search` | string | Searches username, email, first_name, last_name (case-insensitive) |
| `is_active` | boolean | Filter by active status |
| `is_staff` | boolean | Filter by staff status |
| `is_superuser` | boolean | Filter by superuser |
| `is_deleted` | boolean | Filter by soft-deleted |
| `roles` | string | Comma-separated role slugs |
| `department_id` | integer | Filter by department (if applicable) |

## Sorting

Single field ordering: `ordering=username`, `ordering=-date_joined`

## Role Assignment

- Roles are assigned/revoked separately from user CRUD
- Max 100 roles and 100 usernames per assignment call
- Supports expiration: `expires_at` (ISO datetime)
- Role types: `app_role` (app-specific), `site_role` (site-wide)
- Roles can be inherited from site roles

## User Attributes

- Custom JSONB field validated against a tenant-level JSON Schema
- Schema is defined per-tenant, not per-user
- `missing_attributes` field lists required attributes not yet set

## User Preferences

- Key-value store per user (e.g., `theme`, `timezone`, `language`)
- Separate from attributes — preferences are user-controlled, attributes are admin-controlled

## User Apps

Each user can access multiple apps. The `/users/{username}/apps/` endpoint returns:
```json
[{ "name": "HRMS", "slug": "hrms", "icon": "...", "url": "...", "display_name": "HR Management" }]
```


## MCP Tools

| Tool | Purpose |
|---|---|
| `create_user` | Create a new user |
| `update_user` | Update user details |
| `list_users` | List/search users |
| `manage_roles` | Create/delete app roles |
| `manage_role_assignments` | Assign/revoke roles to users |
| `user_attributes_schema` | Get/update tenant user attributes schema |
