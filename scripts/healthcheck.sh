#!/usr/bin/env bash
set -euo pipefail

target_url="${1:-http://localhost:8080}"
status_code="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$target_url/healthz")"

if [ "$status_code" = "200" ]; then
    printf 'Health check passed: %s/healthz returned HTTP %s\n' "$target_url" "$status_code"
    exit 0
fi

printf 'Health check failed: %s/healthz returned HTTP %s (expected 200)\n' "$target_url" "$status_code" >&2
exit 1