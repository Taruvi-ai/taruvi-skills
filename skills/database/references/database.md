# Database Reference

## Core Operations

- `useList`, `useOne`, `useMany`
- `useCreate`, `useUpdate`, `useDelete`, `useDeleteMany`

## Query Features

- filters/operators
- sorting and pagination
- aggregation: `aggregate`, `groupBy`, `having`
- graph options when needed

## Performance Rule

Prefer one aggregate query for summary pages over multiple filtered list calls.

## Required Preference Order

1. For grouped metrics/KPIs, use one `aggregate + groupBy` query.
2. Use `having` for post-aggregation filters.
3. Use multiple filtered queries only when UI needs separate row sets, not just counts.

## Typical Shapes

- Dashboard cards: count by `status`
- Summary charts: sum/avg by month/category/team
- Table pages: plain filtered row queries with pagination
