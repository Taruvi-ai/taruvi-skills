---
name: taruvi-database
description: >
  Use this skill when the user is building or optimizing data-driven screens
  backed by Taruvi datatables — list pages, detail views, dashboard KPI cards,
  summary charts, filtered tables, or graph relationship queries. Also use when
  the user has performance issues with multiple queries that could be replaced
  by a single aggregate, even if they don't mention "database" directly.
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
2. Confirm the current non-deprecated package path for the data operation you are about to use.
   - Do not introduce new code on deprecated providers, hooks, or compatibility helpers.
2. Identify the query shape needed:
   - **List/table UI** → plain filtered row query with pagination
   - **Dashboard card / KPI** → prefer saved analytics query; use datatable `groupBy` + aggregate only for lightweight operational summaries
   - **Related data** → graph options with `include`/`depth` meta keys
3. Apply the preference order:
   - analytics query for KPI/reporting dashboards
   - one datatable aggregate query over multiple filtered queries for simple summaries
   - raw row queries only when the page actually needs rows
4. For every backend-backed list UI:
   - backend pagination is required by default
   - default list `pageSize` is `10`; recommend supporting `10`, `20`, `50`, and `100` as selectable sizes
   - search, filters, and sort order must be pushed into the backend query by default
   - when the list uses MUI `DataGrid`, default to Refine `useDataGrid` so pagination/filter/sort state stays server-driven
   - do not fetch rows and apply the primary list filtering/search logic in React unless the user explicitly asks for client-side behavior
5. For every network-backed dropdown/typeahead:
   - query options from the backend with pagination (default option `pageSize` `10`)
   - debounce search input
   - push the search term into backend filters
   - avoid preloading large option sets and filtering them client-side
6. Validate the query shape scales — avoid N+1 patterns.

### Verification checklist

After writing queries, verify:

- [ ] KPI/reporting dashboards use analytics queries by default
- [ ] Dashboard/summary views use one `aggregate + groupBy` query, not N separate filtered queries
- [ ] All list UIs include `pagination` with a reasonable `pageSize`
- [ ] List views default to `pageSize` `10` and support `10`/`20`/`50`/`100` options unless explicitly scoped otherwise
- [ ] All backend-backed list filtering, search, and sorting are server-side by default
- [ ] Backend-backed MUI `DataGrid` lists use `useDataGrid` by default (or include an explicit reason they cannot)
- [ ] Network-backed dropdown/typeahead options are loaded with debounced server-side search and pagination
- [ ] Graph queries have an explicit `depth` limit
- [ ] `having` is only used after a `groupBy`, never as a substitute for `filters`
- [ ] No N+1 patterns (e.g., looping `useOne` calls inside a list render)
- [ ] No page fetches full row sets into React just to derive cards, pies, or trend charts
- [ ] No backend-backed list page applies its primary search/filter logic in React unless the user explicitly requested client-side behavior

## Examples

**Filtered list with pagination:**
```typescript
const { data } = useList({
  resource: "orders",
  filters: [{ field: "status", operator: "eq", value: "pending" }],
  sorters: [{ field: "created_at", order: "desc" }],
  pagination: { pageSize: 10 },
});
```
Recommended page-size options for list UIs: `10`, `20`, `50`, `100` (default `10`).

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

**Executive dashboard KPI — saved analytics query (preferred):**
```typescript
const { result } = useCustom({
  url: "hrms-dashboard-summary",
  method: "post",
  dataProviderName: "app",
  config: { payload: {} },
  meta: { kind: "analytics" },
});
```

## Gotchas

- **N separate queries for a dashboard** — if you see separate `useList` calls per status/category to build a summary, that is a performance bug. Replace with one `groupBy` query. This is the single most common mistake.
- **Full row fetch for KPI pages** — if a dashboard pulls complete table rows into React and then computes totals/charts client-side, that is a design smell. Prefer analytics or a single aggregate query.
- **Deprecated query path** — if a dashboard only works through a deprecated package path, do not ship that as the final implementation. Resolve the canonical package API first.
- **Graph data without depth limit** — always set `depth` when using graph/edge queries. Without it, the query traverses unbounded relationships and will time out on any non-trivial dataset.
- **`having` without `groupBy`** — `having` only works after a `groupBy`. It is not a substitute for a `filters` clause. Using `having` alone silently returns no results.
- **Large datasets without pagination** — always add `pagination` for list UIs. Unbounded queries will time out on tables with >1000 rows.
- **Client-side list filtering on backend data** — if a list fetches backend rows and then applies its main search or filter logic in React, that is a correctness and scalability smell. Move that logic into backend filters/sorters unless the user explicitly asked for local filtering.
- **Manual MUI grid state wiring** — if a backend-backed MUI `DataGrid` list hand-wires pagination/filter/sort state with `useList`, prefer `useDataGrid` unless there is a concrete limitation that requires manual wiring.
- **Client-filtered remote dropdown options** — if a dropdown fetches remote options once and filters locally, it will miss matches and fail to scale. Use debounced server-side search with paginated option loading.
- **`aggregate` expects an array** — `aggregate: "count"` will fail silently. Use `aggregate: ["count"]`.
- **Filter operator typos** — the operator is `"eq"`, not `"equals"` or `"="`. Common operators: `eq`, `ne`, `lt`, `gt`, `lte`, `gte`, `contains`, `in`.

## References

- `references/database.md` — core operations, query features, aggregation patterns, performance rules
