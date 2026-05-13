#!/usr/bin/env bash
set -euo pipefail

DATE="${1:-$(date +%F)}"
COPILOT_BIN="${COPILOT_BIN:-copilot}"
VAULT_PATH="${VAULT_PATH:-/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory}"
PERSOMEMORY_DATA_HOME="${PERSOMEMORY_DATA_HOME:-${HOME}/.local/share/persomemory}"
LOG_DIR="${PERSOMEMORY_DATA_HOME}/logs"

mkdir -p "${LOG_DIR}"

if [ ! -d "${VAULT_PATH}" ]; then
  echo "Vault path not found: ${VAULT_PATH}" >&2
  exit 1
fi

PROMPT="$(cat <<PROMPT
Use persomemory-agent.

Run the PersoMemory evening sweep for ${DATE}.

Process both evidence streams:
1. WorkIQ evidence for ${DATE}.
2. Copilot conversation evidence from pointer-only queue entries in ${PERSOMEMORY_DATA_HOME}/session-reviews/.

Apply low-risk daily and operational writes:
1. Merge the daily note for ${DATE}.
2. Add clear new open loops.
3. Update active context only when explicit and low ambiguity.
4. Mark processed local conversation queue entries as reviewed or superseded when permissions allow. If not, rely on deduplication and local retention cleanup.

For anything requiring Florian approval, do not resolve it. Write a pending approval item to:

memory/inbox/approvals/${DATE}.md

Approval gates:
1. Editing MEMORY.md.
2. Creating career evidence.
3. Promoting durable project, people, pattern, decision, or toolkit notes.
4. Closing projects.
5. Closing ambiguous commitments.
6. Resolving conflicting evidence.
7. Capturing potentially sensitive content.

If WorkIQ, MCP, permission, vault, or transcript access fails, write a Sweep Failures item in the approval inbox if possible and continue with whatever evidence is available.
PROMPT
)"

cd "${VAULT_PATH}"

"${COPILOT_BIN}" \
  --agent persomemory-agent \
  --add-dir "${PERSOMEMORY_DATA_HOME}" \
  --allow-tool='read' \
  --allow-tool='workiq' \
  --allow-tool='mcpvault' \
  --allow-tool='smart-connections' \
  --allow-tool='persomemory-lifecycle' \
  --no-ask-user \
  --prompt "${PROMPT}" \
  2>&1 | tee -a "${LOG_DIR}/evening-sweep-${DATE}.log"
