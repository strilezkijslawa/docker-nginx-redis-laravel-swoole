#!/usr/bin/env bash
set -e

ROOT=${ROOT:-/var/www/html}

echo "─── Starting Laravel Octane (Swoole) ───"

# Ensure storage & cache dirs exist with correct permissions
mkdir -p \
    "${ROOT}/storage/framework/sessions" \
    "${ROOT}/storage/framework/views" \
    "${ROOT}/storage/framework/cache" \
    "${ROOT}/storage/logs" \
    "${ROOT}/bootstrap/cache"

# Run startup tasks only if artisan exists (i.e. Laravel is installed)
if [ -f "${ROOT}/artisan" ]; then
    echo "→ Optimising application..."
    php "${ROOT}/artisan" config:cache  --no-interaction
    php "${ROOT}/artisan" route:cache   --no-interaction
    php "${ROOT}/artisan" view:cache    --no-interaction
    php "${ROOT}/artisan" event:cache   --no-interaction

    echo "→ Running migrations..."
    php "${ROOT}/artisan" migrate --force --no-interaction
fi

echo "→ Launching Swoole HTTP server on 0.0.0.0:8000"
exec php "${ROOT}/artisan" octane:start \
    --server=swoole \
    --host=0.0.0.0 \
    --port=8000 \
    --workers="${OCTANE_WORKERS:-4}" \
    --max-requests="${OCTANE_MAX_REQUESTS:-500}" \
    --no-interaction
