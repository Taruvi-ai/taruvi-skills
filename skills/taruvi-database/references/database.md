# Database Reference

## Core Hooks

| Hook | Use |
|---|---|
| `useList` | Filtered, sorted, paginated list of rows |
| `useOne` | Single row by ID |
| `useMany` | Multiple rows by ID array |
| `useCreate` | Create a row |
| `useUpdate` | Update a row by ID |
| `useDelete` | Delete a row by ID |
| `useDeleteMany` | Delete multiple rows by ID array |

## Filter Operators

| Operator | Meaning | Example |
|---|---|---|
| `eq` | Equals | `{ field: "status", operator: "eq", value: "active" }` |
| `ne` | Not equals | `{ field: "status", operator: "ne", value: "archived" }` |
| `lt` / `gt` | Less / greater than | `{ field: "amount", operator: "gt", value: 100 }` |
| `lte` / `gte` | Less/greater or equal | `{ field: "created_at", operator: "gte", value: "2024-01-01" }` |
| `contains` | Substring match | `{ field: "name", operator: "contains", value: "john" }` |
| `in` | Value in array | `{ field: "status", operator: "in", value: ["active", "pending"] }` |

## Sorting and Pagination

```typescript
const { data } = useList({
  resource: "orders",
  sorters: [{ field: "created_at", order: "desc" }],
  pagination: { current: 1, pageSize: 25 },
});
```

Always include `pagination` for list UIs. Unbounded queries time out on large tables.

## Aggregation

Use `meta.aggregate` + `meta.groupBy` for summary views. `aggregate` must be an array.

```typescript
// Count orders by status — one query, not N
const { data } = useList({
  resource: "orders",
  meta: {
    aggregate: ["count"],
    groupBy: ["status"],
  },
});
// Returns: [{ status: "pending", count: 14 }, { status: "completed", count: 82 }]
```

Available aggregate functions: `count`, `sum`, `avg`, `min`, `max`.

```typescript
// Sum revenue by month
meta: {
  aggregate: ["sum:amount"],
  groupBy: ["month"],
}
```

## Post-Aggregation Filtering (`having`)

`having` filters groups after aggregation. Only works with `groupBy`.

```typescript
meta: {
  aggregate: ["count"],
  groupBy: ["team"],
  having: { count__gte: 5 },
}
```

Do not use `having` without `groupBy` — it silently returns no results.

## Graph Relationships

Use graph meta keys to traverse relationships between datatables.

```typescript
const { data } = useList({
  resource: "orders",
  meta: {
    format: "graph",
    include: ["customer", "line_items"],
    depth: 2,
  },
});
```

Always set `depth` to avoid unbounded traversal.

## Performance Rules

1. For grouped metrics/KPIs, use one `aggregate + groupBy` query — never N separate filtered queries.
2. Use `having` only for post-aggregation filters.
3. Use multiple filtered queries only when UI needs separate row sets, not just counts.
4. Always paginate list UIs.
5. Set `depth` on all graph queries.
