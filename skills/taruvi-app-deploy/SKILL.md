---
name: taruvi-app-deploy
description: Deploy frontend to Taruvi Frontend Workers. Triggers on "deploy frontend", "deploy app", "publish app", "upload build".
metadata:
  author: EOX Vantage
  version: "1.0.0"
---

# Taruvi App Deploy

Deploy the frontend build to Taruvi Frontend Workers API.

## Steps

1. Read `.env` or `.env.local` to get `TARUVI_SITE_URL`, `TARUVI_API_KEY`, `TARUVI_APP_SLUG`
2. Build the app: `npm run build`
3. Zip the dist folder: `zip -r dist.zip dist/`
4. Upload to Taruvi:
   ```bash
   curl -X POST "${TARUVI_SITE_URL}/api/cloud/frontend_workers/" \
     -H "Authorization: Api-Key ${TARUVI_API_KEY}" \
     -F "name=${TARUVI_APP_SLUG}" \
     -F "is_internal=true" \
     -F "file=@dist.zip;type=application/zip"
   ```
5. Clean up: `rm -f dist.zip`

## Alternative: Use deploy script

If the project has `npm run deploy`, use that instead — it handles all steps automatically.

## CI/CD

For automated deploys on PR merge, see `.github/workflows/deploy.yml`. It uses branch-specific secrets:
- `{BRANCH}_SITE_URL` (e.g., `MAIN_SITE_URL`, `DEV_SITE_URL`)
- `{BRANCH}_API_KEY` (e.g., `MAIN_API_KEY`, `DEV_API_KEY`)
- `APP_SLUG` from `package.json` under `taruvi.appSlug`
