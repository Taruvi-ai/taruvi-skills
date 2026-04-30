---
name: taruvi-app-deploy
description: Deploy frontend to Taruvi Frontend Workers. Triggers on "deploy frontend", "deploy app", "publish app", "upload build".
metadata:
  author: EOX Vantage
  version: "1.4.0"
---

# Taruvi App Deploy

Deploy the frontend build to Taruvi Frontend Workers API.

## Steps

1. Read `.env` or `.env.local` to get `TARUVI_SITE_URL`, `TARUVI_API_KEY`, `TARUVI_APP_SLUG`
2. Build the app: `npm run build`
3. Zip the dist folder: `zip -r dist.zip dist/`
4. Deploy:
   ```bash
   # Get default worker slug from app settings
   WORKER_SLUG=$(curl -s "${TARUVI_SITE_URL}/api/apps/${TARUVI_APP_SLUG}/settings/" \
     -H "Authorization: Api-Key ${TARUVI_API_KEY}" | jq -r '.data.default_frontend_worker_slug')

   if [ "$WORKER_SLUG" != "null" ] && [ -n "$WORKER_SLUG" ]; then
     # Update existing worker
     RESPONSE=$(curl -s -X PATCH "${TARUVI_SITE_URL}/api/cloud/frontend_workers/${WORKER_SLUG}/" \
       -H "Authorization: Api-Key ${TARUVI_API_KEY}" \
       -F "file=@dist.zip;type=application/zip")
     
     # Get the new build UUID and set it as active
     BUILD_UUID=$(echo "$RESPONSE" | jq -r '.data.latest_build.uuid')
     if [ "$BUILD_UUID" != "null" ] && [ -n "$BUILD_UUID" ]; then
       curl -X PATCH "${TARUVI_SITE_URL}/api/cloud/frontend_workers/${WORKER_SLUG}/set-active-build/" \
         -H "Authorization: Api-Key ${TARUVI_API_KEY}" \
         -H "Content-Type: application/json" \
         -d "{\"build_uuid\": \"${BUILD_UUID}\"}"
     fi
   else
     # Create new worker (first build auto-activates)
     curl -X POST "${TARUVI_SITE_URL}/api/cloud/frontend_workers/" \
       -H "Authorization: Api-Key ${TARUVI_API_KEY}" \
       -F "name=${TARUVI_APP_SLUG}" \
       -F "subdomain_input=${TARUVI_APP_SLUG}" \
       -F "is_internal=true" \
       -F "file=@dist.zip;type=application/zip"
   fi
   ```
5. Clean up: `rm -f dist.zip`

## Alternative

If the project has `npm run deploy`, use that instead.
