---
name: taruvi-app-developer
description: >
  Use this skill when the user is building, modifying, debugging, or deploying
  a Taruvi-powered application — even if they don't mention "Taruvi" directly.
  Activate whenever you see @taruvi/sdk, @taruvi/refine-providers, TARUVI_API_KEY,
  sdk_client, taruvi.cloud, or Taruvi provider/function code in the project.
  This is the entry-point skill — always read it before any other Taruvi skill.
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

## Examples

**Greenfield:** User says "build me an employee directory". Read references, wire `dataProvider` and `userDataProvider`, scaffold list/detail pages with Refine hooks. No function needed (single-resource CRUD).

**Existing app refactor:** User says "the cascade delete is broken". Read existing delete handler first, detect multi-resource pattern (tasks + attachments + activities), route to `taruvi-functions/SKILL.md` and rewrite as a serverless function.

**Deploy task:** User says "deploy the frontend". Ask for their deploy target and follow their project's build and deploy workflow.

## Edge Cases

- **Unclear mode** — when signals are mixed, ask the user: "Is this a new app or does it already have Taruvi providers set up?"
- **Task spans multiple modules** — load all relevant SKILL.md files before starting; don't guess from memory.
- **Function vs provider unclear** — default to a function whenever there is any cross-resource side effect, even if it seems minor.
- **Existing code uses deprecated providers** — flag `functionsDataProvider`/`analyticsDataProvider` as deprecated; migrate to `appDataProvider + useCustom`. See `taruvi-refine-providers` skill for migration notes.

## References

- `references/runtime-and-packages.md` — mandatory runtime split, package list, query strategy
