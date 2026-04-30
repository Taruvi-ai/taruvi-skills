#!/usr/bin/env bash
# export-backend.sh — Export Taruvi app backend config to .taruvi-backend/
#
# Usage:
#   bash scripts/export-backend.sh <SITE_URL> <API_KEY> <APP_SLUG>
#
# Example:
#   bash scripts/export-backend.sh "https://mysite.taruvi.app" "my-api-key" "my-app"

set -euo pipefail

SITE_URL="${1:-}"
API_KEY="${2:-}"
APP_SLUG="${3:-}"

if [[ -z "$SITE_URL" || -z "$API_KEY" || -z "$APP_SLUG" ]]; then
  echo "Error: Missing required arguments"
  echo "Usage: $0 <SITE_URL> <API_KEY> <APP_SLUG>"
  exit 1
fi

echo "Exporting app '$APP_SLUG' from $SITE_URL..."

# Call export API
HTTP_CODE=$(curl -s -w "%{http_code}" -o app-package.zip \
  -X POST "${SITE_URL}/api/apps/${APP_SLUG}/packages/" \
  -H "Authorization: Api-Key ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "include_app_roles": true,
    "include_datatables": true,
    "include_functions": true,
    "include_events": true,
    "include_widgets": true,
    "include_secrets": true,
    "include_policies": true,
    "include_analytics": true,
    "include_storage": true
  }')

if [[ "$HTTP_CODE" -ne 200 ]]; then
  echo "Error: Export failed with status $HTTP_CODE"
  cat app-package.zip 2>/dev/null || true
  rm -f app-package.zip
  exit 1
fi

# Prepare target directory
rm -rf .taruvi-backend
mkdir -p .taruvi-backend

# Extract
unzip -o app-package.zip -d .taruvi-backend
rm -f app-package.zip

# Report
FILE_COUNT=$(find .taruvi-backend -type f | wc -l)
echo ""
echo "Export complete! $FILE_COUNT files extracted to .taruvi-backend/"
echo ""
echo "Next steps:"
echo "  git add .taruvi-backend"
echo "  git commit -m 'chore: export backend config'"
echo "  git push"
