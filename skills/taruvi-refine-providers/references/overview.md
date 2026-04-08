# Overview

Install:

```bash
npm install @taruvi/refine-providers @taruvi/sdk @refinedev/core
```

Client setup uses `@taruvi/sdk`:

```tsx
import { Client } from "@taruvi/sdk";

const client = new Client({
  apiKey: "your-api-key",
  appSlug: "your-app-slug",
  baseUrl: "https://your-site.taruvi.cloud",
});
```

Typical Refine setup includes:

- `default`: `dataProvider(client)`
- `storage`: `storageDataProvider(client)`
- `app`: `appDataProvider(client)`
- `user`: `userDataProvider(client)`
- `authProvider(client)`
- `accessControlProvider(client)`

Provider names:

- `default` -> database CRUD/graph
- `storage` -> storage object flows
- `app` -> roles/settings/functions/analytics
- `user` -> user CRUD
