#!/usr/bin/env bash
set -euo pipefail

VAULT="${1:-/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory}"

required=(
  "MEMORY.md"
  "memory/governance/dreams.md"
  "memory/content/active/now.md"
  "memory/content/commitments/open-loops.md"
  "memory/governance/ontology/contract.md"
  "memory/registries/projects.md"
  "memory/content/daily"
  "memory/content/projects"
  "memory/content/people"
  "memory/content/patterns"
  "memory/content/decisions"
  "memory/content/career"
  "memory/content/toolkits"
  "memory/governance/approvals"
  "memory/governance/maintenance"
  "memory/governance/preferences"
)

for path in "${required[@]}"; do
  if [ ! -e "${VAULT}/${path}" ]; then
    echo "Missing: ${VAULT}/${path}" >&2
    exit 1
  fi
done

for old_path in \
  "DREAMS.md" \
  "memory/active" \
  "memory/approvals" \
  "memory/career" \
  "memory/commitments" \
  "memory/daily" \
  "memory/decisions" \
  "memory/maintenance" \
  "memory/ontology" \
  "memory/patterns" \
  "memory/people" \
  "memory/preferences" \
  "memory/projects" \
  "memory/toolkits"; do
  if [ -e "${VAULT}/${old_path}" ]; then
    echo "Obsolete path still exists: ${VAULT}/${old_path}" >&2
    exit 1
  fi
done

echo "Vault structure looks valid: ${VAULT}"
