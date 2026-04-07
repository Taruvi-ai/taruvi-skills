# Resource Surface Patterns

Use this as the single function-side reference for common resource operations.

## Database

- Query builder: `from_(...).filter(...).sort(...).page(...).page_size(...).execute()`
- CRUD helpers: `create`, `get`, `update`, `delete`
- Advanced: `aggregate`, `group_by`, `having`, `search`, graph edges/traversal

## Functions

- Invoke sync: `sdk_client.functions.execute("slug", params={...})`
- Invoke async: `sdk_client.functions.execute("slug", params={...}, is_async=True)`
- Poll async status with `sdk_client.functions.get_result(task_id)`

## Storage

- Buckets: list/create/update/delete
- Objects: list/upload/download/update/delete/copy/move
- Prefer batch operations for bulk workflows

## Secrets

- Single: `sdk_client.secrets.get("KEY")`
- Batch/filtered: `sdk_client.secrets.list(...)`
- Use app-scoped lookup where inheritance context matters

## Users

- List/get/create/update/delete users
- Assign/revoke roles
- Read/update user preferences

## Analytics

- Execute predefined analytics query slugs with parameter payloads

## Policy

- `check_resources` for per-action allow/deny
- `filter_allowed` for resource filtering
- `get_allowed_actions` for UI action resolution

## App and Settings

- `sdk_client.app.settings()` and `sdk_client.app.roles()`
- `sdk_client.settings.get()` for site metadata
