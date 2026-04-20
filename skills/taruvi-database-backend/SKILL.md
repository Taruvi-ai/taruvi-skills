---
name: taruvi-database-backend
description: >
  Use this skill to understand what the Taruvi datatable backend supports —
  filter operators, aggregation functions, sorting, pagination, graph traversal,
  full-text search, and schema capabilities. Read this when building frontend
  queries to know what the backend can handle.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Documents the capabilities of the Taruvi datatable backend so the frontend is built correctly against what actually works.

## Filter Operators

The backend supports these operators via `field__operator=value` query params:

### Comparison
| Operator | Meaning | Example |
|---|---|---|
| `eq` | Equals (default if no operator) | `status=active` |
| `ne` | Not equals | `status__ne=deleted` |
| `gt` | Greater than | `age__gt=18` |
| `gte` | Greater than or equal | `age__gte=18` |
| `lt` | Less than | `price__lt=100` |
| `lte` | Less than or equal | `price__lte=100` |

### String Matching (case-insensitive by default)
| Operator | Meaning |
|---|---|
| `contains` / `ncontains` | Contains / not contains (case-insensitive) |
| `containss` / `ncontainss` | Contains / not contains (case-sensitive) |
| `startswith` / `nstartswith` | Starts with (case-insensitive) |
| `startswiths` / `nstartswiths` | Starts with (case-sensitive) |
| `endswith` / `nendswith` | Ends with (case-insensitive) |
| `endswiths` / `nendswiths` | Ends with (case-sensitive) |

Note: `icontains` is an alias for `contains` — both are case-insensitive.

### Set Operators
| Operator | Meaning | Example |
|---|---|---|
| `in` | Value in comma-separated list | `status__in=active,pending` |
| `nin` | Value not in list | `status__nin=deleted,banned` |

### Range
| Operator | Meaning | Example |
|---|---|---|
| `between` | Between two values | `price__between=10,100` |
| `nbetween` | Not between | `price__nbetween=10,100` |

### Null Checks
| Operator | Meaning |
|---|---|
| `null` | Is NULL (`field__null=true`) |
| `nnull` | Is NOT NULL (`field__nnull=true`) |

### Full-Text Search
| Operator | Meaning |
|---|---|
| `search` | PostgreSQL tsvector search (requires `search_vector` field) |

### Array Operators (PostgreSQL)
| Operator | Meaning |
|---|---|
| `acontains` | Array contains all items (`@>`) |
| `acontainedby` | Array contained by (`<@`) |
| `aoverlap` | Arrays overlap (`&&`) |
| `aelement` | Value exists in array (`= ANY()`) |

Each has a negated version: `nacontains`, `nacontainedby`, `naoverlap`, `naelement`.

### Hierarchy Operators
| Operator | Meaning |
|---|---|
| `descendants` | Filter by descendants in hierarchy |
| `ancestors` | Filter by ancestors in hierarchy |

### Logic Operators
The backend supports nested AND/OR/NOT logic:
```
{ "and": [{ "status": "active" }, { "or": [{ "age__gte": 18 }, { "verified": true }] }] }
```

## Aggregation

### Supported Functions
`count(*)`, `count(field)`, `sum(field)`, `avg(field)`, `min(field)`, `max(field)`, `array_agg(field)`, `string_agg(field)`, `json_agg(field)`, `stddev(field)`, `variance(field)`

### Complex Expressions
The backend supports complex aggregate expressions with aliases:
- `sum(total) as revenue`
- `count(*) as order_count`
- `avg(extract(epoch from (end_time - start_time)) / 86400) as avg_days`

### GROUP BY
Supports field names and SQL expressions:
- `groupBy: ["status", "category"]`
- `groupBy: ["DATE_TRUNC('month', created_at)"]`

### HAVING
Post-aggregation filtering. Only works after GROUP BY:
- `having: [{ field: "count(*)", operator: "gt", value: 5 }]`

## Pagination

- `page` (1-indexed, default: 1)
- `page_size` (max enforced by server config)
- Response includes: `total`, `pagination.current_page`, `pagination.total_pages`, `pagination.has_next`, `pagination.has_previous`

## Sorting

Django-style ordering: `-field` for descending, `field` for ascending. Multiple fields comma-separated:
- `ordering=-created_at,name`

## Graph / Hierarchy

When a table has `hierarchy: true` or `graph.enabled: true`:
- `format=tree` or `format=graph` — output format
- `include=descendants`, `include=ancestors`, `include=both` — traversal direction
- `depth=N` — traversal depth limit (max 10)
- `graph_types=manager,mentor` — filter edges by type

## Full-Text Search

Tables with `search_fields` configured get a `search_vector` column (PostgreSQL tsvector) with a GIN index. Query with:
- `?search=project roadmap`
- Supports weighted fields (A through D priority)

## Populate (FK Expansion)

- `populate=author,category` — expand foreign key fields inline
- `populate=*` — expand all FKs
- Max populate depth: 3

## Schema Capabilities

- Field types: `string`, `integer`, `number`, `boolean`, `date`, `datetime`, `time`, `object` (JSONB), `array`, `uuid`
- Constraints: `required`, `unique`, `enum`, `pattern`, `minimum`, `maximum`, `minLength`, `maxLength`
- Indexes: `btree`, `hash`, `gin`, `gist`, `brin` — with `unique`, `where`, `expression` support
- Foreign keys to other tables or system tables (`auth_user`, `storage_objects`)
- Zero-downtime renames via `x-rename-from`
- Upsert support on create
- Bulk delete by filter


## MCP Tools

| Tool | Purpose |
|---|---|
| `create_update_schema` | Create or update tables (Frictionless Data Package format) |
| `get_datatable_schema` | Read schema for one or all tables |
| `datatable_data` | Query, upsert, or delete rows |
| `datatable_edges` | Manage graph/hierarchy edges |
| `delete_datatable` | Drop a table |
| `execute_raw_sql` | Run arbitrary SQL (use `auto_reflect: true` for DDL) |
