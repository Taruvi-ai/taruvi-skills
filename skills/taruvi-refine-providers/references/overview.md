# @taruvi/refine-providers — Overview

Refine.dev data providers for Taruvi. Bridges Refine hooks (`useList`, `useOne`, `useCreate`, etc.) with the Taruvi backend via `@taruvi/sdk`.

## Installation

```bash
npm install @taruvi/refine-providers @taruvi/sdk @refinedev/core
```

## Quick Start

```tsx
import { Refine } from "@refinedev/core";
import { Client } from "@taruvi/sdk";
import {
  dataProvider,
  storageDataProvider,
  appDataProvider,
  userDataProvider,
  authProvider,
  accessControlProvider,
} from "@taruvi/refine-providers";

const client = new Client({
  apiKey: "your-api-key",
  appSlug: "your-app-slug",
  apiUrl: "https://your-site.taruvi.cloud",
});

function App() {
  return (
    <Refine
      dataProvider={{
        default: dataProvider(client),
        storage: storageDataProvider(client),
        app: appDataProvider(client),
        user: userDataProvider(client),
      }}
      authProvider={authProvider(client)}
      accessControlProvider={accessControlProvider(client)}
      resources={[{ name: "posts" }]}
    >
      {/* Your app */}
    </Refine>
  );
}
```

## Providers at a Glance

| Provider | `dataProviderName` | Purpose | Supported Hooks |
|---|---|---|---|
| `dataProvider` | `"default"` | Database CRUD & graph operations | `useList`, `useOne`, `useMany`, `useCreate`, `useUpdate`, `useDelete`, `useCustom` |
| `storageDataProvider` | `"storage"` | File storage operations | `useList`, `useOne`, `useCreate`, `useUpdate`, `useDelete`, `useDeleteMany`, `useCustom` |
| `appDataProvider` | `"app"` | App config, edge functions, analytics | `useList`, `useOne`, `useCustom` |
| `userDataProvider` | `"user"` | User management | `useList`, `useOne`, `useCreate`, `useUpdate`, `useDelete` |
| `authProvider` | — | Authentication (redirect-based) | `useLogin`, `useLogout`, `useRegister`, `useGetIdentity`, `usePermissions` |
| `accessControlProvider` | — | Cerbos-based authorization | `useCan` |
