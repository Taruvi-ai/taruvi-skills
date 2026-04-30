---
name: taruvi-app-export
description: Export Taruvi backend config to version control. Triggers on "export backend", "export app config", "backup app", "sync backend".
metadata:
  author: EOX Vantage
  version: "1.0.0"
---

# Taruvi App Export

Export backend configuration to `.taruvi-backend/` for version control.

## Steps

1. Read `.env` or `.env.local` to get `TARUVI_SITE_URL`, `TARUVI_API_KEY`, `TARUVI_APP_SLUG`
2. Run the export script with these values as parameters
3. The script calls the export API, downloads the ZIP, extracts it to `.taruvi-backend/`
4. Tell user to commit the changes

## Script

```bash
bash scripts/export-backend.sh "$TARUVI_SITE_URL" "$TARUVI_API_KEY" "$TARUVI_APP_SLUG"
```

The script:
- Calls `POST {SITE_URL}/api/apps/{APP_SLUG}/packages/` 
- Downloads the ZIP response
- Extracts to `.taruvi-backend/` folder in project root
- Cleans up the ZIP file

## After Export

Tell user to commit the taruvi-backend folder.
```
