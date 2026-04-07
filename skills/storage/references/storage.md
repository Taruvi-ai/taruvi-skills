# Storage Reference

## Primary Endpoints

- Buckets:
  - `GET/POST /api/apps/{app_slug}/storage/buckets/`
  - `GET/PATCH/DELETE /api/apps/{app_slug}/storage/buckets/{bucket_slug}/`
- Objects (recommended path-based API):
  - `PUT|POST /api/apps/{app_slug}/storage/buckets/{bucket}/objects/{key}`
  - `GET /api/apps/{app_slug}/storage/buckets/{bucket}/objects/{key}` (download default)
  - `GET ...?metadata=true` (metadata JSON)
  - `DELETE /api/apps/{app_slug}/storage/buckets/{bucket}/objects/{key}`
- Batch:
  - `POST .../objects/batch-upload/` (max 10 files / 100MB)
  - `POST .../objects/batch-delete/` (max 100 paths, partial success supported)

## Bucket Rules

- `app_category` required (`assets` or `attachments`).
- `visibility`: `private` (default) or `public`.
- `file_size_limit` default 50MB unless changed.
- `allowed_mime_types` supports exact and wildcard patterns.

## Object Rules

- Paths are bucket-relative, folder-like.
- Upsert behavior when uploading to existing path.
- Visibility override per object:
  - `null` inherit from bucket
  - `public` or `private` explicit override

## Advanced Filters

Prefer object list GET filters:

- prefix/path: `prefix`, `file__startswith`, `file__icontains`
- ranges: `size__gte`, `size__lte`, `created_at__gte`, `created_at__lte`
- MIME: `mimetype`, `mimetype__in`, `mimetype_category`
- ownership/visibility: `created_by_me`, `modified_by_me`, `visibility`
- metadata: `metadata_search`

## Quotas

- Bucket quota fields: `max_size_bytes`, `max_objects`
- Usage endpoint: `GET /api/apps/{app_slug}/storage/buckets/{slug}/usage/`
- Quotas are monitoring/alerting oriented (not hard upload blocking).
