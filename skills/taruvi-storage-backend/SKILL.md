---
name: taruvi-storage-backend
description: >
  Use this skill to understand what the Taruvi storage backend supports —
  bucket configuration, object filters, visibility rules, quota behavior,
  and batch operation limits.
metadata:
  author: taruvi-ai
  version: "1.0.0"
---

## Overview

Documents the capabilities of the Taruvi storage backend so the frontend is built correctly.

## Bucket Configuration

| Field | Required | Values / Default |
|---|---|---|
| `name` | Yes | Display name |
| `slug` | Auto | URL-safe identifier (unique per app) |
| `app_category` | Yes | `assets` or `attachments` |
| `visibility` | No | `private` (default) or `public` |
| `file_size_limit` | No | Max bytes per file (default: 50MB / 52428800) |
| `allowed_mime_types` | No | Array of exact (`application/pdf`) or wildcard (`image/*`). Empty = all allowed |
| `max_size_bytes` | No | Total bucket quota in bytes (advisory only) |
| `max_objects` | No | Max object count (advisory only) |

## Object Filters

The backend supports these filters on object listings:

### Size
| Filter | Example |
|---|---|
| `size__gte`, `size__lte`, `size__gt`, `size__lt` | `?size__gte=1048576` |
| `min_size`, `max_size` | Friendly aliases for `size__gte`/`size__lte` |

### Dates
| Filter | Example |
|---|---|
| `created_at__gte`, `created_at__lte` | `?created_at__gte=2024-01-01` |
| `updated_at__gte`, `updated_at__lte` | Date range on modified date |
| `created_after`, `created_before` | Friendly aliases |

### Search
| Filter | Meaning |
|---|---|
| `search` | Searches both filename and path (case-insensitive) |
| `prefix` | Bucket-relative path prefix (e.g., `users/123/`) |
| `file__startswith`, `file__istartswith` | File path prefix (case-sensitive / insensitive) |
| `file__icontains` | File path contains |
| `filename__icontains`, `filename__istartswith` | Filename search |
| `metadata_search` | Search inside metadata JSON (case-insensitive) |

### MIME Type
| Filter | Example |
|---|---|
| `mimetype` | Exact: `?mimetype=application/pdf` |
| `mimetype__in` | Multiple: `?mimetype__in=image/png,image/jpeg` |
| `mimetype_category` | Category: `?mimetype_category=image` (matches `image/*`) |

### Visibility & Ownership
| Filter | Meaning |
|---|---|
| `visibility` | `public` or `private` |
| `created_by_me` | Files created by authenticated user |
| `modified_by_me` | Files modified by authenticated user |
| `created_by__username`, `created_by__username__icontains` | Filter by creator username |

## Visibility Rules

- Bucket has a default visibility (`private` or `public`)
- Per-object visibility overrides the bucket default
- `null` visibility = inherit from bucket
- A `private` file in a `public` bucket stays private

## Batch Limits

| Operation | Limit |
|---|---|
| Batch upload | Max 10 files, max 100MB per call. No partial success — all fail if limit exceeded |
| Batch delete | Max 100 paths per call. Supports partial success |

## Quota Behavior

- Quotas (`max_size_bytes`, `max_objects`) are **advisory only**
- The API does **not** block uploads when quota is exceeded
- Surface quota usage as a warning in the UI, not as a blocker

## Upload Behavior

- Uploading to an existing path **replaces** the object silently (upsert)
- No warning from the API on overwrite
- `allowed_mime_types` rejection returns a generic 400 with no mention of MIME types


## MCP Tools

| Tool | Purpose |
|---|---|
| `manage_storage` (action: create_bucket) | Create a bucket |
| `manage_storage` (action: list_buckets) | List buckets |
| `manage_storage` (action: list_objects) | List objects in a bucket |
| `manage_storage` (action: get_quota) | Get bucket usage/quota |
