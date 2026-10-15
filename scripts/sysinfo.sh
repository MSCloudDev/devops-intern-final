#!/usr/bin/env bash
set -euo pipefail

printf 'Current user: %s\n' "${USER:-$(id -un)}"
printf 'Effective UID: %s\n' "$(id -u)"
printf 'Hostname: %s\n' "$(hostname)"
printf 'Kernel release: %s\n' "$(uname -r)"
printf 'System date: %s\n' "$(date -Iseconds)"
printf '\nDisk usage:\n'
df -h .
printf '\nMemory usage:\n'
if command -v free >/dev/null 2>&1; then free -h
elif command -v vm_stat >/dev/null 2>&1; then vm_stat
else printf 'Memory reporting command is unavailable on this host.\n'; fi
printf '\nDocker daemon status:\n'
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then printf 'Docker daemon is running.\n'
    else printf 'Docker CLI is installed, but the daemon is unavailable.\n'; fi
else printf 'Docker CLI is not installed.\n'; fi