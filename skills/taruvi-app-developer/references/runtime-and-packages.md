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

Use analytics queries as the default strategy for KPI/reporting dashboards.

- KPI/reporting/executive dashboards should use saved analytics queries via the `app` provider.
- Datatable grouped aggregate (`aggregate` + `groupBy`) is an exception path for lightweight operational summaries and must be explicitly justified.
- Add `having` only when post-aggregation filtering is required.
- Use multiple filtered row queries only when UI actually needs separate row sets.
