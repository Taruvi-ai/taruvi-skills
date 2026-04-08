---
name: taruvi-database
description: Use when building or optimizing Taruvi database queries, datatable CRUD screens, dashboard aggregations, KPI cards, filtered lists, sorting, pagination, graph relationships, or useList/useOne/useCreate/useUpdate/useDelete hooks with the Taruvi data provider.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for all Taruvi datatable and database query work — covering Refine hooks, query operators, aggregation patterns, and performance rules for summary views.

## When to Use This Skill

- Building a list, table, or detail screen backed by a Taruvi datatable
- Writing or optimizing filtered/sorted/paginated queries
- Building dashboard KPI cards or summary charts
- Using `useList`, `useOne`, `useMany`, `useCreate`, `useUpdate`, `useDelete`, or `useDeleteMany`
- Implementing `groupBy`, `aggregate`, or `having` for grouped metrics
- Modeling graph relationships between datatables

**Do not use this skill for:** raw storage file queries (use `taruvi-storage` skill), user management CRUD (use `taruvi-refine-providers` skill with `userDataProvider`), or multi-resource operations (use `taruvi-functions` skill).

## Step-by-Step Instructions

1. Open and read `references/database.md` for the full query API and rules.
2. Identify the query shape needed:
   - **List/table UI** → plain filtered row query with pagination
   - **Dashboard card / KPI** → grouped aggregate with `groupBy` + optional `having`
   - **Related data** → graph options with `include`/`depth` meta keys
3. Apply the preference order: one aggregate query over multiple filtered queries for summary pages.
4. Validate the query shape scales — avoid N+1 patterns.

## Examples

**Filtered list with pagination:**
```typescript
const { data } = useList({
  resource: "orders",
  filters: [{ field: "status", operator: "eq", value: "pending" }],
  sorters: [{ field: "created_at", order: "desc" }],
  pagination: { pageSize: 20 },
});
```

**Dashboard KPI — count by status (one query, not N):**
```typescript
const { data } = useList({
  resource: "orders",
  meta: {
    aggregate: ["count"],
    groupBy: ["status"],
  },
});
// Returns: [{ status: "pending", count: 14 }, { status: "completed", count: 82 }]
```

**Post-aggregation filter with `having`:**
```typescript
meta: {
  aggregate: ["count"],
  groupBy: ["team"],
  having: { count__gte: 5 },
}
```

## Edge Cases

- **Multiple status queries for a dashboard** — if you see separate `useList` calls per status to build a summary, that is a performance bug. Replace with one `groupBy` query.
- **Graph data without depth limit** — always set `depth` when using graph/edge queries to avoid unbounded traversal.
- **`having` without `groupBy`** — `having` only works after a `groupBy`. It is not a substitute for a `filters` clause.
- **Large datasets without pagination** — always add `pagination` for list UIs. Unbounded queries will time out.

## References

- `references/database.md` — core operations, query features, aggregation patterns, performance rules
