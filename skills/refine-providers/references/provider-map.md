# Provider Map

- `default` provider:
  - datatable CRUD, filters, sorting, pagination, aggregates, graph mode
  - graph mode is activated by meta keys such as `format`, `include`, `depth`, `graph_types`
- `storage` provider:
  - file upload/list/update/delete operations
  - supports bucket override via `meta.bucketName`
  - upload via `useCreate` / `useCreateMany` with `files`, optional `paths`, optional `metadatas`
  - delete bulk via `useDeleteMany`
- `app` provider:
  - app roles/settings/secrets, function execution, analytics execution
  - execute functions with `useCustom` + `meta.kind: "function"`
  - execute analytics with `useCustom` + `meta.kind: "analytics"`
- `user` provider:
  - user CRUD and user-related resources

## Auth Provider Notes

- Redirect flow: `login()` redirects to `/accounts/login/`, then tokens are extracted from callback URL hash.
- `check()` verifies auth and refreshes expired tokens.
- `onError()` handles 401/403 behavior for session state and authorization.

## Access Control Notes

- `accessControlProvider` batches `useCan` checks with DataLoader (`batchDelayMs` configurable).
- Entity type resolution priority:
  1. `params.entityType`
  2. `resource.meta.entityType`
  3. resource name fallback
- Uses Refine query caching (`staleTime`/`gcTime`) while DataLoader cache is disabled.

## Types and Migration Notes

- Use `TaruviMeta`, `FunctionMeta`, `AnalyticsMeta`, `AppCustomMeta`, and `StorageUploadVariables` from package types.
- `functionsDataProvider` and `analyticsDataProvider` are deprecated; prefer `appDataProvider + useCustom`.
