---
name: taruvi-refine-providers
description: >
  Use this skill when the user is setting up, wiring, or debugging Taruvi
  Refine providers in a frontend app — including initial client setup, provider
  registration in <Refine>, or diagnosing which provider to use. This is the
  frontend root skill that routes to specific provider skills.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Frontend root skill for Taruvi + Refine apps. Handles client setup, provider wiring, and routes to the specific provider skill for each domain.

**Compliance rule:** This skill and the provider skills it routes to are the source of truth for all frontend provider usage. Do not substitute with simpler patterns, copy outdated project code, or skip prescribed steps. If a requirement cannot be met, stop and ask the user.

## Installation

```bash
npm install @taruvi/refine-providers @taruvi/sdk @refinedev/core
```

## Client Setup

```tsx
import { Client } from "@taruvi/sdk";

const client = new Client({
  apiKey: import.meta.env.VITE_TARUVI_API_KEY,
  appSlug: import.meta.env.VITE_TARUVI_APP_SLUG,
  apiUrl: import.meta.env.VITE_TARUVI_API_URL,
});
```

## Provider Wiring

```tsx
import {
  dataProvider,
  storageDataProvider,
  appDataProvider,
  userDataProvider,
  authProvider,
  accessControlProvider,
} from "@taruvi/refine-providers";

<Refine
  dataProvider={{
    default: dataProvider(client),
    storage: storageDataProvider(client),
    app: appDataProvider(client),
    user: userDataProvider(client),
  }}
  authProvider={authProvider(client)}
  accessControlProvider={accessControlProvider(client)}
/>
```

## Provider Routing

Each provider has its own self-contained skill. Load the one you need:

| Provider | `dataProviderName` | Skill to load |
|---|---|---|
| `dataProvider` | `"default"` | `taruvi-database` |
| `storageDataProvider` | `"storage"` | `taruvi-storage` |
| `appDataProvider` (analytics) | `"app"` | `taruvi-analytics` |
| `appDataProvider` (functions) | `"app"` | `taruvi-functions` |
| `userDataProvider` | `"user"` | `taruvi-users` |
| `authProvider` | — | `taruvi-auth` |
| `accessControlProvider` | — | `taruvi-access-control` |

## App Provider — Roles, Settings, Secrets

These operations use `appDataProvider` directly and don't have a separate skill yet:

```tsx
// Fetch roles
const { result } = useList({ resource: "roles", dataProviderName: "app" });

// Fetch settings
const { result } = useOne({ resource: "settings", dataProviderName: "app", id: "" });

// Fetch single secret
const { result } = useOne({ resource: "secrets", dataProviderName: "app", id: "STRIPE_KEY" });

// Batch fetch secrets
const { result } = useList({
  resource: "secrets",
  dataProviderName: "app",
  meta: { keys: ["API_KEY", "DATABASE_URL"] },
});
```

## Deprecated Providers

`functionsDataProvider` and `analyticsDataProvider` are removed. Use `appDataProvider` with `useCustom` instead. See `taruvi-functions-frontend` and `taruvi-analytics` skills.

## Key Rules

- SDK client must use env vars (`import.meta.env.VITE_TARUVI_*`), not hardcoded values
- All data flows through provider hooks — no direct REST/fetch calls from components
- Use Refine `notificationProvider` for success/error feedback — no custom toast systems
- `dataProviderName` is required on all non-default provider calls (`"storage"`, `"app"`, `"user"`)

## Verification Checklist

- [ ] SDK client uses env vars, not hardcoded values
- [ ] All four data providers are wired: `default`, `storage`, `app`, `user`
- [ ] `authProvider` and `accessControlProvider` are both passed to `<Refine>`
- [ ] No direct REST/fetch calls from components
- [ ] No new usage of deprecated package APIs
