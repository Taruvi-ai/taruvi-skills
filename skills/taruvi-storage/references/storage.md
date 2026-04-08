# Storage Reference

## Primary Endpoints

- Buckets:
  - `GET/POST /api/apps/{app_slug}/storage/buckets/`
  - `GET/PATCH/DELETE /api/apps/{app_slug}/storage/buckets/{bucket_slug}/`
- Objects (recommended path-based API):
  - `PUT|POST /api/apps/{app_slug}/storage/buckets/{bucket}/objects/{key}` (upload)
  - `GET /api/apps/{app_slug}/storage/buckets/{bucket}/objects/{key}` (download)
  - `GET ...?metadata=true` (metadata JSON)
  - `DELETE /api/apps/{app_slug}/storage/buckets/{bucket}/objects/{key}`
- Batch:
  - `POST .../objects/batch-upload/` (max 10 files / 100MB)
  - `POST .../objects/batch-delete/` (max 100 paths, partial success supported)

## Bucket Configuration

| Field | Required | Values |
|---|---|---|
| `app_category` | Yes | `assets` or `attachments` |
| `visibility` | No | `private` (default) or `public` |
| `file_size_limit` | No | Default 50MB |
| `allowed_mime_types` | No | Exact (`application/pdf`) or wildcard (`image/*`) |
| `max_size_bytes` | No | Quota — advisory only |
| `max_objects` | No | Quota — advisory only |

## Upload via Refine Hook

```typescript
const { mutate: upload } = useCreate();

upload({
  resource: "my-bucket",
  dataProviderName: "storage",  // Required — omitting routes to database provider
  variables: {
    files: [file],
    paths: ["uploads/profile-photo.jpg"],
    metadatas: [{ description: "Profile photo" }],
  },
});
```

`dataProviderName: "storage"` is required on every storage hook call.

## Batch Upload

Max 10 files / 100MB per call. Split larger sets into chunks.

```typescript
// Upload in chunks of 10
for (let i = 0; i < files.length; i += 10) {
  const chunk = files.slice(i, i + 10);
  await upload({
    resource: "my-bucket",
    dataProviderName: "storage",
    variables: { files: chunk, paths: chunk.map(f => `uploads/${f.name}`) },
  });
}
```

## Batch Delete

Max 100 paths per call. Supports partial success — some paths may delete while others fail.

```typescript
const { mutate: deleteMany } = useDeleteMany();

deleteMany({
  resource: "my-bucket",
  dataProviderName: "storage",
  ids: ["uploads/old-photo.jpg", "uploads/draft.pdf"],
});
```

## List with Filters

```typescript
const { data } = useList({
  resource: "my-bucket",
  dataProviderName: "storage",
  filters: [{ field: "prefix", operator: "eq", value: "uploads/2024/" }],
});
```

### Available Filters

| Filter | Example |
|---|---|
| `prefix` | `"uploads/2024/"` |
| `file__startswith` | `"report"` |
| `file__icontains` | `"invoice"` |
| `size__gte` / `size__lte` | `1048576` (bytes) |
| `created_at__gte` / `created_at__lte` | `"2024-01-01"` |
| `mimetype` | `"application/pdf"` |
| `mimetype__in` | `["image/png", "image/jpeg"]` |
| `mimetype_category` | `"image"` |
| `visibility` | `"public"` or `"private"` |
| `created_by_me` / `modified_by_me` | `true` |
| `metadata_search` | `"invoice"` |

## Object Visibility

- Default: inherits from bucket.
- Override per object: set `visibility` to `"public"` or `"private"`.
- `null` means inherit from bucket.
- A `private` file in a `public` bucket stays private.

## Quota Monitoring

```typescript
// GET /api/apps/{app_slug}/storage/buckets/{slug}/usage/
// Returns: { size_bytes: 1234567, object_count: 42 }
```

Quotas are advisory — the API does not block uploads when quota is exceeded. Surface usage in UI as a warning.
