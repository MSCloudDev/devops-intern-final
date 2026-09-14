#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://localhost:8080}"

status="$(curl -sS -o /dev/null -w '%{http_code}' "$URL")" || {
    echo "Health check FAILED: unable to reach $URL" >&2
    exit 1
}

if [ "$status" = "200" ]; then
    echo "Health check OK: $URL returned HTTP 200"
else
    echo "Health check FAILED: $URL returned HTTP $status" >&2
    exit 1
fi