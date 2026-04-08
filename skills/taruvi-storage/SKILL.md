---
name: taruvi-storage
description: Use when working with Taruvi object storage — bucket creation, file upload, file download, metadata, visibility (public/private), batch upload, batch delete, prefix filtering, quota monitoring, storageDataProvider, useCreate for uploads, or useDeleteMany for bulk deletes.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for Taruvi storage workflows — bucket management, object upload/download via REST path-based API or Refine provider hooks, visibility control, batch operations, and quota-aware UX patterns.

## When to Use This Skill

- Creating or configuring a storage bucket (`app_category`, `visibility`, `allowed_mime_types`)
- Uploading files from the frontend using `storageDataProvider` + `useCreate`
- Downloading or serving files via the path-based GET API
- Deleting files individually or in bulk with `useDeleteMany`
- Building a file manager, attachment list, or media gallery
- Applying prefix/MIME/size/date filters to object listings
- Surfacing bucket quota usage in the UI

**Do not use this skill for:** database table CRUD (use `taruvi-database` skill), user data (use `taruvi-refine-providers` skill), or multi-resource storage + database operations (use `taruvi-functions` skill).

## Step-by-Step Instructions

1. Open and read `references/storage.md` for the full API reference.
2. Identify the operation needed:
   - **Single upload** → `PUT|POST /api/apps/{app_slug}/storage/buckets/{bucket}/objects/{key}`
   - **Bulk upload** → batch-upload endpoint (max 10 files / 100MB per call)
   - **Bulk delete** → batch-delete endpoint (max 100 paths per call)
   - **List with filters** → GET with query params (`prefix`, `mimetype`, `size__gte`, etc.)
3. Set bucket `visibility` at the bucket level; override per-object only when needed.
4. For quota-aware UX, call the usage endpoint and display a warning — do not rely on upload blocking.

## Examples

**Upload via Refine provider hook:**
```typescript
const { mutate: upload } = useCreate();

upload({
  resource: "my-bucket",
  dataProviderName: "storage",
  variables: {
    files: [file],
    paths: ["uploads/profile-photo.jpg"],
    metadatas: [{ description: "Profile photo" }],
  },
});
```

**Batch delete:**
```typescript
const { mutate: deleteMany } = useDeleteMany();

deleteMany({
  resource: "my-bucket",
  dataProviderName: "storage",
  ids: ["uploads/old-photo.jpg", "uploads/draft.pdf"],
});
```

**List with prefix filter:**
```typescript
const { data } = useList({
  resource: "my-bucket",
  dataProviderName: "storage",
  filters: [{ field: "prefix", operator: "eq", value: "uploads/2024/" }],
});
```

## Edge Cases

- **Uploading to an existing path** — upsert behavior: the object is replaced silently. Warn users in UI if overwrite is unintentional.
- **Visibility mismatch** — per-object visibility overrides the bucket default. If a public bucket has a private file, the file stays private.
- **Batch upload limit** — max 10 files and 100MB per batch-upload call. Split larger sets into multiple calls.
- **Batch delete limit** — max 100 paths per batch-delete call. Paginate for larger deletes.
- **Quota** — quotas are advisory (monitoring/alerting), not hard upload blockers. Surface the usage warning in UX rather than preventing upload.
- **`allowed_mime_types`** — supports wildcards (`image/*`) and exact values. Misconfigured buckets silently reject uploads at the API level.

## References

- `references/storage.md` — full endpoint reference, bucket/object rules, advanced filters, quota semantics
