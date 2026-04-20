---
name: taruvi-analytics-backend
description: >
  Use this skill to understand what the Taruvi analytics backend supports —
  query types, connection types, parameterization, supported databases,
  and execution behavior.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Documents the capabilities of the Taruvi analytics query engine so the frontend is built correctly.

## Connection Types

| Type | When to use | Secret required? |
|---|---|---|
| `internal` | Query the app's own PostgreSQL schema (same database as datatables) | No |
| `external` | Query an external database (separate Postgres, MySQL, Redshift, etc.) | Yes — `secret_key` required |

For cross-table dashboard queries on app data, use `internal`. No secret setup needed.

## Supported Databases (external)

PostgreSQL, MySQL, Amazon Redshift, Elasticsearch, ClickHouse.

## Query Parameterization

Queries support Jinja2 templates for dynamic parameters:

```sql
SELECT d.name, SUM(o.amount) as revenue
FROM orders o JOIN departments d ON o.department_id = d.id
WHERE o.created_at >= '{{ start_date }}'
  AND o.created_at <= '{{ end_date }}'
GROUP BY d.name
```

Parameters are passed at execution time. Secret values can also be templated: `{{ secret.<secret_key> }}`.

## Query Execution

- Queries are saved with a name (auto-generates a slug)
- Executed by slug via the API
- Parameters passed as key-value pairs at execution time
- Results returned as array of row objects

## Validation Rules

- External connections require a `secret_key` — creation fails without it
- Internal connections must not have a `secret_key`
- Query slugs are auto-generated from the name and are unique


## MCP Tools

| Tool | Purpose |
|---|---|
| `manage_query` (action: create) | Create a saved analytics query |
| `manage_query` (action: list) | List saved queries |
| `manage_query` (action: get) | Get query details by slug |
| `execute_query` | Execute a saved query with parameters |
