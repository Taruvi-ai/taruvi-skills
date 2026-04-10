# Provider Map

Quick routing guide — read the dedicated reference file for each provider you need.

| Provider | `dataProviderName` | Reference File | Key Operations |
|---|---|---|---|
| `dataProvider` | `"default"` | `database-provider.md` | CRUD, filters, sorting, aggregation, graph edges |
| `storageDataProvider` | `"storage"` | `storage-provider.md` | Upload, download, batch delete, metadata, filters |
| `appDataProvider` | `"app"` | `app-provider.md` | Roles, settings, secrets, function execution, analytics |
| `userDataProvider` | `"user"` | `user-provider.md` | User CRUD, roles, apps |
| `authProvider` | — | `auth-provider.md` | Login/logout/register, token flow, identity, permissions |
| `accessControlProvider` | — | `access-control-provider.md` | `useCan`, `CanAccess`, entity type resolution, batching |

## Key Rules

- Use `appDataProvider` + `useCustom` for function/analytics execution — not the deprecated `functionsDataProvider`.
- Graph mode activates automatically when `format`, `include`, `depth`, or `graph_types` is present in `meta`.
- `storageDataProvider` expects bucket name as the `resource` value.
- `accessControlProvider` batches `useCan` calls automatically — do not debounce manually.
- For types (`TaruviMeta`, `StorageUploadVariables`, `FunctionMeta`, etc.) see `types-and-utilities.md`.
