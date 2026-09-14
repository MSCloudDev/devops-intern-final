#!/usr/bin/env bash
set -euo pipefail

echo "User: $(id -un) (UID $(id -u))"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "Date: $(date -Iseconds)"

echo "Disk usage:"
df -h /

echo "Memory usage:"
if command -v free >/dev/null 2>&1; then
    free -h
else
    echo "free is not available on this host"
fi

echo "Docker daemon:"
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "running"
else
    echo "not available or not running"
fi