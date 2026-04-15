---
name: taruvi-app-developer
description: >
  Use this skill when the user wants to build, add features to, debug, or
  deploy a web application that uses Taruvi as its backend — including CRUD
  pages, dashboards, file uploads, serverless functions, auth, or access
  control. Activate on any app-building request when the project contains
  @taruvi/sdk, @taruvi/refine-providers, TARUVI_API_KEY, sdk_client, or
  taruvi.cloud in its files. Also activate when the user mentions Taruvi,
  Refine providers, dataProvider, storageDataProvider, appDataProvider,
  userDataProvider, or sdk_client. Always read this skill first before
  loading any other Taruvi skill.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Entry-point orchestrator for all Taruvi app development. This skill detects the project context, decides whether a serverless function is needed, and routes to the right module skill before any code is written.

## When to Use This Skill

- Starting a new Taruvi-powered app from scratch
- Adding a feature to an existing Taruvi app
- Refactoring or enhancing provider/hook/function code
- Debugging a broken query, upload flow, or function
- Deploying a frontend worker
- Any task that involves `@taruvi/sdk`, `@taruvi/refine-providers`, or `sdk_client`

## Step-by-Step Instructions

### Step 1 — Detect Project Mode

Identify which mode applies before doing anything:

| Mode | Signals |
|---|---|
| **Greenfield** | No existing Taruvi code, scaffolding from scratch |
| **Existing app** | Project has `@taruvi/sdk`, `.env` with `TARUVI_*` keys, or existing provider/function code |

For existing apps — read the relevant existing files first. Understand what is already built before proposing changes.

### Step 2 — Read Foundation Reference

Open and read `references/runtime-and-packages.md` before writing any code.

For deploy tasks, ask the user for their deploy target and workflow details.

### Step 2.5 — Identify the Current Package API

Before writing code against Taruvi packages, identify the current non-deprecated API surface in the installed package for this repo.

- Never introduce new usage of deprecated package APIs.
- If old examples, README snippets, or existing code use deprecated providers or hooks, do not copy them into new work.
- If the canonical path is unclear, resolve that before building the feature.
- If the only apparent working path is deprecated, treat that as a provider/docs issue to fix before finalizing the app code.

### Step 3 — Decide: Function or Provider?

Answer this question before routing:

**Does this task touch more than one resource?**
(resources = database tables, storage buckets, users, secrets, analytics)

- **Yes** → a serverless function is required
- **No** → use provider hooks directly

Functions are required when the task involves:
- 2+ resources (multi-resource create/update/delete/mix)
- Backend logic beyond simple CRUD
- Reacting to data or user lifecycle events
- Scheduled / cron background jobs
- Calling external APIs using stored secrets
- Long-running tasks (>30s)
- Public unauthenticated endpoints
- Authorization-gated operations
- Function-to-function pipelines

For everything else — use provider hooks directly, no function needed.

### Step 4 — Route to the Right Module

Only load modules relevant to the task. Use your file reading tool to open and read each relevant `SKILL.md` before writing any code.

| Task | Skill to load |
|---|---|
| Writing, editing, or debugging a serverless function | `taruvi-functions` |
| Building or refactoring frontend provider/hook code | `taruvi-refine-providers` |
| Building or optimizing data queries, dashboards, aggregations | `taruvi-database` |
| Adding or changing file upload/download/storage features | `taruvi-storage` |
| Task touches 2+ of the above | Load all relevant skills |

Find and read the `SKILL.md` for the required skill. Do not hardcode a path — use your file search tool to locate it.

### Step 5 — Decide Dashboard Query Strategy Explicitly

If the task includes a dashboard, KPI cards, trends, reporting, or an executive summary, make an explicit choice before coding:

- **Analytics-backed dashboard** → default for KPI-first, executive, reporting, and trend pages
- **Datatable aggregate/groupBy** → acceptable for lightweight operational summaries when a saved analytics query would be unnecessary
- **Row query + derive in React** → only acceptable when the UI primarily renders rows and the summary is incidental

For summary-first pages, do not skip this decision. Record it in your implementation notes or plan.

### Step 6 — Default List Views to Backend-Driven Queries

For any backend-backed list or table page, the default implementation must be backend-driven:

- backend pagination is required by default
- default list `pageSize` is `10`; recommend exposing `10`, `20`, `50`, and `100` as user-selectable options
- search, filters, and sorting must be server-side by default
- when the list is rendered with MUI `DataGrid`, default to Refine `useDataGrid`
- client-side filtering or search is only allowed if the user explicitly asks for it or the list is intentionally local-only
- do not fetch one page of backend rows and then apply the primary list filtering logic in React
- if a backend-backed MUI `DataGrid` list is not using `useDataGrid`, document the reason explicitly
- if the current schema or query path cannot support the needed server-side list behavior, fix the backend/query path before calling the feature done

### Step 7 — Default Network-Backed Dropdowns to Autocomplete

For any dropdown whose options come from network calls:

- use `Autocomplete` (or equivalent typeahead), not a static `Select`
- query options from the backend with pagination (default option `pageSize` `10`)
- debounce input before sending search requests
- send the current search term as server-side filters, not client-side filtering over previously fetched options
- if the field cannot support server-side search + pagination, treat that as a query/schema gap and fix it before calling the feature done

### Step 8 — Enforce Access-Control Contract

For permission checks in app code:

- use only the published non-deprecated SDK/provider contract with prefixed ACL resource strings
- `useCan`/`CanAccess` resources must be in prefixed form (for example `datatable:employees`, `function:employee-terminate`, `query:hrms-dashboard-summary`)
- do not rely on `params.entityType` for access-control checks
- verify runtime payloads in browser network logs: each `check/resources` `resource.kind` must exactly match the requested `resource` string
- when SDK/provider ACL contract changes, app code must be updated in the same release cycle and versioned accordingly

### Step 9 — Default Bulk Actions to Backend Bulk Operations

For bulk update/delete/status-change flows:

- execute bulk changes through backend bulk operations by default (`updateMany`, `deleteMany`, or a batch serverless function)
- define and show selection scope clearly (selected rows vs filtered result set)
- return and display partial-failure details per record when applicable
- invalidate/refetch affected list and related summary queries after completion

### Step 10 — Use Refine Notification Provider

For user-facing success/error feedback:

- use the app’s existing Refine notification integration (`notificationProvider`) by default
- do not introduce custom toast/snackbar systems when Refine notification provider is available

## Examples

**Greenfield:** User says "build me an employee directory". Read references, wire `dataProvider` and `userDataProvider`, scaffold list/detail pages with Refine hooks. No function needed (single-resource CRUD).

**Existing app refactor:** User says "the cascade delete is broken". Read existing delete handler first, detect multi-resource pattern (tasks + attachments + activities), route to `taruvi-functions/SKILL.md` and rewrite as a serverless function.

**Deploy task:** User says "deploy the frontend". Ask for their deploy target and follow their project's build and deploy workflow.

**List + feedback baseline:** For backend-backed list pages, use `useDataGrid` (`pageSize: 10`) and surface success/error via Refine `notificationProvider` (`useNotification`) rather than custom toasts.

## Edge Cases

- **Unclear mode** — when signals are mixed, ask the user: "Is this a new app or does it already have Taruvi providers set up?"
- **Task spans multiple modules** — load all relevant SKILL.md files before starting; don't guess from memory.
- **Function vs provider unclear** — default to a function whenever there is any cross-resource side effect, even if it seems minor.
- **Existing code uses deprecated providers** — flag `functionsDataProvider`/`analyticsDataProvider` as deprecated; migrate to `appDataProvider + useCustom`. See `taruvi-refine-providers` skill for migration notes.
- **Dashboard implementation unclear** — if the page is KPI-first or reporting-heavy, default to analytics queries through the `app` provider. Do not fetch full row sets into React just to compute cards and charts.
- **Package API unclear** — use the installed package’s current non-deprecated API surface. Do not normalize deprecated and current patterns together in new code.
- **List implementation unclear** — default to backend pagination plus server-side search, filtering, and sorting. Treat client-side filtering on backend-backed lists as an exception that must be explicitly justified.
- **MUI `DataGrid` list implementation unclear** — default to `useDataGrid` for backend-backed lists unless there is a concrete reason the page cannot use it.
- **Network-backed dropdown implementation unclear** — default to debounced server-side `Autocomplete` with pagination and search filters. Do not ship client-filtered option lists by default.

## References

- `references/runtime-and-packages.md` — mandatory runtime split, package list, query strategy
