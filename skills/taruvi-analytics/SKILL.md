---
name: taruvi-analytics
description: >
  Use this skill when the user needs to create, execute, or debug saved
  analytics queries — including dashboard elements that combine data from
  2 or more tables, cross-table reports, KPI queries that need SQL joins, or
  any visualization that cannot be expressed as a single-table aggregate.
  Also use when the user mentions analytics queries, saved queries,
  appDataProvider with meta.kind "analytics", or cross-table dashboards.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for Taruvi saved analytics queries — when to use them, how to create them, and how to call them from the frontend.

**Compliance rule:** Analytics queries are required when a dashboard element needs data from 2 or more tables. Do not substitute with multiple datatable aggregate calls or client-side data merging. If the analytics secret or query cannot be created, stop and ask the user.

## When to Use This Skill

- A dashboard element (card, chart, metric) needs data from 2 or more tables
- Building cross-table reports or summaries
- Creating or editing saved SQL queries
- Executing analytics queries from the frontend via `appDataProvider`
- Debugging analytics query errors or missing data

**Do not use this skill for:** single-table aggregates (use `taruvi-database` with datatable `aggregate`/`groupBy`), serverless function logic (use `taruvi-functions`).

## Decision Rule

**Before writing any dashboard query, check:** does this element need data from more than one table?

- **Yes (2 or more tables)** → use this skill — create a saved analytics query
- **No (single table)** → use `taruvi-database` with `useList` + `meta.aggregate`/`groupBy`

Examples:
- "Revenue by department" → orders + departments = 2 tables → analytics
- "Orders by status" → orders only = 1 table → datatable aggregate
- "Average salary by job title" → salaries + employees = 2 tables → analytics
- "Employee count by status" → employees only = 1 table → datatable aggregate

## Step-by-Step Instructions

### Step 1 — Create the analytics query

Use the `manage_query` MCP tool to create a saved SQL query:

```
manage_query(
  action="create",
  name="Revenue by Department",
  query_text="SELECT d.name as department, SUM(o.amount) as revenue FROM orders o JOIN departments d ON o.department_id = d.id GROUP BY d.name",
  connection_type="internal"
)
```

For queries against external databases, provide a `secret_key` pointing to an analytics database connection secret.

### Step 2 — Call from frontend

Use `appDataProvider` + `useCustom` with `meta.kind: "analytics"`. The `url` is the query slug:

```tsx
const { result } = useCustom({
  url: "revenue-by-department",
  method: "post",
  dataProviderName: "app",
  config: { payload: {} },
  meta: { kind: "analytics" },
});
```

### Step 3 — Use parameterized queries for filters

Analytics queries support Jinja2 templates for dynamic parameters:

```sql
SELECT d.name, SUM(o.amount) as revenue
FROM orders o
JOIN departments d ON o.department_id = d.id
WHERE o.created_at >= '{{ start_date }}'
  AND o.created_at <= '{{ end_date }}'
GROUP BY d.name
```

Pass parameters via payload:

```tsx
const { result } = useCustom({
  url: "revenue-by-department",
  method: "post",
  dataProviderName: "app",
  config: {
    payload: { start_date: "2024-01-01", end_date: "2024-12-31" },
  },
  meta: { kind: "analytics" },
});
```

## Verification Checklist

- [ ] Every dashboard element needing data from 2 or more tables uses a saved analytics query
- [ ] No client-side merging of multiple datatable queries to build a single visualization
- [ ] Analytics queries use `dataProviderName: "app"` and `meta: { kind: "analytics" }`
- [ ] Query slug in `url` matches the created query's slug
- [ ] Parameterized queries pass values via `config.payload`, not hardcoded in SQL

## Gotchas

- **Missing `dataProviderName: "app"`** — omitting it routes the call to the database provider, returning "resource not found."
- **Missing `meta.kind: "analytics"`** — without it, the app provider doesn't know to route to the analytics engine and throws an error.
- **Query slug mismatch** — the `url` must be the exact slug returned by `manage_query`, not the display name.
- **Using datatable aggregate for cross-table data** — if the metric needs data from 2 or more tables, datatable `aggregate`/`groupBy` cannot express it. Use analytics.
- **Client-side data merging** — fetching from 2 tables separately and combining in React is fragile, slow, and breaks pagination. Always push cross-table logic to a saved query.

## References

- `../taruvi-refine-providers/references/app-provider.md` — analytics execution API, useCustom patterns
