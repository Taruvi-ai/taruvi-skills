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
2. Run the export script (path relative to project root):
   ```bash
   bash skills/taruvi-app-export/scripts/export-backend.sh "$TARUVI_SITE_URL" "$TARUVI_API_KEY" "$TARUVI_APP_SLUG"
   ```
3. Tell user to commit the `.taruvi-backend/` folder