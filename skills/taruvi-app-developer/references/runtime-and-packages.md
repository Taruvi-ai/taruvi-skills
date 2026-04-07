# Runtime and Packages

## Mandatory Runtime Split

| Runtime | Use | Packages |
|---|---|---|
| Frontend (React + Refine) | UI, CRUD hooks, auth/access control in browser | `@taruvi/sdk`, `@taruvi/refine-providers`, `@refinedev/core` |
| Python (functions/services/scripts) | Backend orchestration, multi-resource operations | Taruvi Python SDK |

## Non-Negotiables

- Never use Python SDK in browser code.
- Never use frontend providers as a substitute for backend orchestration.
- Never answer Taruvi-specific behavior from memory only; read the relevant module references first.
- Never invent endpoints or method names.

## Query Strategy for Dashboards

Prefer one aggregated server-side query over multiple filtered queries when rendering summary metrics.

- Use grouped aggregate (`aggregate` + `groupBy`) for KPI cards/charts.
- Add `having` only when post-aggregation filtering is required.
- Use multiple filtered row queries only when UI actually needs separate row sets.
