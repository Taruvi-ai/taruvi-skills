---
name: taruvi-storage
description: >
  Use this skill when the user needs to upload, download, list, or manage files
  in Taruvi storage — including building file managers, attachment lists, media
  galleries, configuring buckets, handling visibility, batch operations, or
  showing quota usage. Also use when the user is working with file-related UI
  and needs the storageDataProvider, even if they don't mention "storage."
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Reference module for Taruvi storage workflows — bucket management, object upload/download via REST path-based API or Refine provider hooks, visibility control, batch operations, and quota-aware UX patterns.

**Compliance rule:** This skill's prescribed patterns (multi-file upload by default, per-file status reporting, storage+metadata consistency) are mandatory. Do not fall back to simpler patterns. If a requirement cannot be met, stop and ask the user.

## When to Use This Skill

- Creating or configuring a storage bucket (`app_category`, `visibility`, `allowed_mime_types`)
- Uploading files from the frontend using `storageDataProvider` + `useCreate`
- Downloading or serving files via the path-based GET API
- Deleting files individually or in bulk with `useDeleteMany`
- Building a file manager, attachment list, or media gallery
- Applying prefix/MIME/size/date filters to object listings
- Surfacing bucket quota usage in the UI

**Do not use this skill for:** database table CRUD (use `taruvi-database` skill), user data (use `taruvi-users` skill), or multi-resource storage + database operations (use `taruvi-functions` skill).

## Step-by-Step Instructions

1. Identify the operation needed:
   - **Single upload** → `useCreate` with `dataProviderName: "storage"`
   - **Bulk upload** → batch-upload (max 10 files / 100MB per call)
   - **Bulk delete** → `useDeleteMany` (max 100 paths per call)
   - **List with filters** → `useList` with `dataProviderName: "storage"`
2. Set bucket `visibility` at the bucket level; override per-object only when needed.
3. For quota-aware UX, call the usage endpoint and display a warning — do not rely on upload blocking.
4. For document/attachment flows, default to multi-file upload UX:
   - allow selecting/uploading multiple files per action by default
   - process each file independently and capture per-file success/failure
   - keep storage object and metadata record creation/deletion consistent
   - after upload/delete, invalidate/refetch file lists so UI reflects current backend state

### Verification checklist

- [ ] Bucket has `app_category` set (`assets` or `attachments`)
- [ ] `allowed_mime_types` is configured if the bucket should restrict file types
- [ ] Batch uploads are split into chunks of ≤10 files / ≤100MB
- [ ] Batch deletes are split into chunks of ≤100 paths
- [ ] Upload UI warns users when overwriting an existing path (upsert behavior)
- [ ] Quota usage is surfaced as a warning, not as an upload blocker
- [ ] Multi-file uploads report per-file status instead of a single aggregate success
- [ ] Metadata and storage-object state remain consistent when one step fails

## API Reference

### List Files

```tsx
const { result } = useList({
  resource: "documents", // bucket name
  dataProviderName: "storage",
});
```

### Get File URL

```tsx
const { result } = useOne({
  resource: "documents",
  dataProviderName: "storage",
  id: "uploads/document.pdf",
});
```

### Upload Files

```tsx
const { mutate } = useCreate();
mutate({
  resource: "documents",
  dataProviderName: "storage",
  values: {
    files: [file1, file2],
    paths: ["file1.pdf", "file2.pdf"],
    metadatas: [{ tag: "report" }, {}],
  },
});
```

### Batch Delete

```tsx
const { mutate } = useDeleteMany();
mutate({
  resource: "documents",
  dataProviderName: "storage",
  ids: ["path/to/file1.pdf", "path/to/file2.pdf"],
});
```

### Update File Metadata

```tsx
const { mutate } = useUpdate();
mutate({
  resource: "documents",
  dataProviderName: "storage",
  id: "uploads/document.pdf",
  values: { metadata: { tag: "reviewed" }, visibility: "public" },
});
```

### Filter Files

```tsx
const { result } = useList({
  resource: "documents",
  dataProviderName: "storage",
  filters: [
    { field: "mimetype_category", operator: "eq", value: "image" },
    { field: "size", operator: "lte", value: 5242880 },
  ],
});
```

## Gotchas

- **Uploading to an existing path** — upsert behavior: the object is replaced silently. Always warn users in UI.
- **Visibility mismatch** — per-object visibility overrides the bucket default. A `private` file in a `public` bucket stays private.
- **Batch upload limit** — max 10 files and 100MB per call. Exceeding returns a 400 with no partial success.
- **Batch delete limit** — max 100 paths per call. Supports partial success.
- **Quota is advisory** — the API does not block uploads when quota is exceeded. Surface as a warning.
- **`allowed_mime_types` rejects silently** — generic 400, no mention of MIME types. Check bucket config first.
- **Missing `app_category`** — bucket creation requires `app_category` (`assets` or `attachments`).
- **`dataProviderName: "storage"` is required** — forgetting it routes to the database provider.
- **Single-file-only UX** — attachment flows should support multi-file selection by default.
