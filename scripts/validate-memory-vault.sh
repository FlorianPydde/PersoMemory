#!/usr/bin/env bash
set -euo pipefail

VAULT="${1:-/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory}"

required=(
  "MEMORY.md"
  "DREAMS.md"
  "memory/active/now.md"
  "memory/commitments/open-loops.md"
  "memory/daily/TEMPLATE.md"
  "memory/projects"
  "memory/people"
  "memory/patterns"
  "memory/decisions"
  "memory/career"
  "memory/toolkits"
)

for path in "${required[@]}"; do
  if [ ! -e "${VAULT}/${path}" ]; then
    echo "Missing: ${VAULT}/${path}" >&2
    exit 1
  fi
done

echo "Vault structure looks valid: ${VAULT}"
