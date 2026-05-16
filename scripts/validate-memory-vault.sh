#!/usr/bin/env bash
set -euo pipefail

VAULT="${1:-/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory}"

required=(
  "README.md"
  "evidence/daily"
  "evidence/sessions"
  "outcomes"
  "execution/open-loops.md"
  "reusable"
  "views/active-now.md"
  "views/career-impact.md"
  "governance/ontology/contract.md"
  "governance/approvals"
  "governance/maintenance"
  "governance/preferences/approval-routing.md"
)

for path in "${required[@]}"; do
  if [ ! -e "${VAULT}/${path}" ]; then
    echo "Missing: ${VAULT}/${path}" >&2
    exit 1
  fi
done

for old_path in \
  "MEMORY.md" \
  "DREAMS.md" \
  "dreams.md" \
  "governance/dreams.md" \
  "memory" \
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
