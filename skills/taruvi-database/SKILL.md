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

**Compliance rule:** This skill's prescribed query strategies (server-side search/filter/sort for lists, debounced Autocomplete for dropdowns) are mandatory, not suggestions. Do not fall back to simpler patterns. If a requirement cannot be met, stop and ask the user.

## When to Use This Skill

- Building a list, table, or detail screen backed by a Taruvi datatable
- Writing or optimizing filtered/sorted/paginated queries
- Building dashboard KPI cards or summary charts
- Using `useList`, `useOne`, `useMany`, `useCreate`, `useUpdate`, `useDelete`, or `useDeleteMany`
- Implementing `groupBy`, `aggregate`, or `having` for grouped metrics
- Modeling graph relationships between datatables

**Do not use this skill for:** raw storage file queries (use `taruvi-storage` skill), user management CRUD (use `taruvi-users` skill), or multi-resource operations (use `taruvi-functions` skill).

## Step-by-Step Instructions

1. Confirm the current non-deprecated package path for the data operation you are about to use.
   - Do not introduce new code on deprecated providers, hooks, or compatibility helpers.
2. Identify the query shape needed:
   - **List/table UI** → plain filtered row query with pagination
   - **Dashboard card / KPI (single table)** → datatable `groupBy` + `aggregate`
   - **Dashboard element needing data from 2 or more tables** → saved analytics query via `appDataProvider` + `useCustom`
   - **Related data** → graph options with `include`/`depth` meta keys
3. Apply the preference order:
   - single-table aggregates via datatable provider for most dashboard metrics
   - saved analytics queries when a dashboard element needs data from 2 or more tables
   - raw row queries only when the page actually needs rows
   - never fetch full row sets into React to derive summary metrics
4. For every backend-backed list UI:
   - backend pagination is required by default
   - default list `pageSize` is `10`; recommend supporting `10`, `20`, `50`, and `100` as selectable sizes
   - search, filters, and sort order must be pushed into the backend query by default
   - list pages should expose visible search input and relevant filter controls by default
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

- [ ] Single-table dashboard metrics use datatable `aggregate` + `groupBy`; dashboard elements needing data from 2 or more tables use saved analytics queries
- [ ] Dashboard/summary views use one `aggregate + groupBy` query, not N separate filtered queries
- [ ] All list UIs include `pagination` with a reasonable `pageSize`
- [ ] List views default to `pageSize` `10` and support `10`/`20`/`50`/`100` options unless explicitly scoped otherwise
- [ ] All backend-backed list filtering, search, and sorting are server-side by default
- [ ] Backend-backed list pages include visible search and relevant filter controls by default (or explicit user-requested omission)
- [ ] Backend-backed MUI `DataGrid` lists use `useDataGrid` by default (or include an explicit reason they cannot)
- [ ] Network-backed dropdown/typeahead options are loaded with debounced server-side search and pagination
- [ ] Graph queries have an explicit `depth` limit
- [ ] `having` is only used after a `groupBy`, never as a substitute for `filters`
- [ ] No N+1 patterns (e.g., looping `useOne` calls inside a list render)
- [ ] No page fetches full row sets into React just to derive cards, pies, or trend charts
- [ ] No backend-backed list page applies its primary search/filter logic in React unless the user explicitly requested client-side behavior

## API Reference

### Return Values

All hooks return `{ result, query }` (queries) or `{ mutate, mutation }` (mutations).

```tsx
const { result, query } = useList({ resource: "posts" });
result.data;        // TData[] — records
result.total;       // number — total count for pagination
query.isLoading;    // boolean
query.isError;      // boolean
query.error;        // HttpError | null
query.refetch;      // () => void
```

### CRUD Operations

```tsx
const { result } = useList({ resource: "posts" });
const { result } = useOne({ resource: "posts", id: 1 });
const { result } = useMany({ resource: "posts", ids: [1, 2, 3] });

const { mutate } = useCreate();
mutate({ resource: "posts", values: { title: "Hello" } });

const { mutate } = useUpdate();
mutate({ resource: "posts", id: 1, values: { title: "Updated" } });

const { mutate } = useDelete();
mutate({ resource: "posts", id: 1 });
```

### Filtering

```tsx
const { result } = useList({
  resource: "posts",
  filters: [
    { field: "status", operator: "eq", value: "published" },
    { field: "views", operator: "gte", value: 100 },
    { field: "title", operator: "contains", value: "refine" },
    { field: "category", operator: "in", value: ["tech", "news"] },
  ],
});
```

| Operator | Description |
|---|---|
| `eq` / `ne` | Equal / Not equal |
| `lt`, `gt`, `lte`, `gte` | Comparison |
| `contains` / `ncontains` | Contains (case-sensitive) |
| `containss` / `ncontainss` | Contains (case-insensitive) |
| `startswith` / `nstartswith` | Starts with (case-sensitive) |
| `startswiths` / `nstartswiths` | Starts with (case-insensitive) |
| `endswith` / `nendswith` | Ends with (case-sensitive) |
| `endswiths` / `nendswiths` | Ends with (case-insensitive) |
| `in` / `nin` | In / Not in array |
| `null` / `nnull` | Is null / Is not null |
| `between` / `nbetween` | Between / Not between two values |

### Sorting & Pagination

```tsx
const { result } = useList({
  resource: "posts",
  sorters: [{ field: "created_at", order: "desc" }],
  pagination: { currentPage: 1, pageSize: 20 },
});
```

### Meta Options (`TaruviMeta`)

```tsx
meta: {
  tableName: "blog_posts",          // override table name
  populate: ["author", "category"], // populate FKs ("*" for all)
  select: ["id", "title", "status"],
  idColumnName: "post_id",          // custom PK column
  upsert: true,                     // insert or update on conflict (useCreate)
  deleteByFilter: true,             // delete by filter instead of IDs (useDeleteMany)
}
```

### Aggregations

```tsx
const { result } = useList({
  resource: "orders",
  meta: {
    aggregate: ["sum(total)", "count(*)", "avg(quantity)"],
    groupBy: ["status", "category"],
    having: [{ field: "sum(total)", operator: "gte", value: 1000 }],
  },
});
```

Supported functions: `sum`, `avg`, `count`, `min`, `max`, `array_agg`, `string_agg`, `json_agg`, `stddev`, `variance`.

### Graph Operations

When `format`, `include`, `depth`, or `graph_types` is set in `meta`, the provider switches to graph mode.

```tsx
const { result } = useOne({
  resource: "employees",
  id: "1",
  meta: {
    format: "graph",        // "tree" or "graph"
    include: "descendants", // "descendants", "ancestors", "both"
    depth: 2,
    graph_types: ["manager"],
  },
});
```

## Gotchas

- **N separate queries for a dashboard** — if you see separate `useList` calls per status/category to build a summary, that is a performance bug. Replace with one `groupBy` query for single-table data, or a saved analytics query if the element needs data from 2 or more tables.
- **Full row fetch for KPI pages** — if a dashboard pulls complete table rows into React and then computes totals/charts client-side, that is a bug. Always push aggregation to the server.
- **Graph data without depth limit** — always set `depth` when using graph/edge queries. Without it, the query traverses unbounded relationships and will time out on any non-trivial dataset.
- **`having` without `groupBy`** — `having` only works after a `groupBy`. It is not a substitute for a `filters` clause. Using `having` alone silently returns no results.
- **Large datasets without pagination** — always add `pagination` for list UIs. Unbounded queries will time out on tables with >1000 rows.
- **Client-side list filtering on backend data** — move that logic into backend filters/sorters unless the user explicitly asked for local filtering.
- **`aggregate` expects an array** — `aggregate: "count"` will fail silently. Use `aggregate: ["count"]`.
- **Filter operator typos** — the operator is `"eq"`, not `"equals"` or `"="`.
