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
You are running as the top-level persomemory-agent. Do not delegate this sweep to a nested subagent.

Use the persomemory-daily-sweep skill to run the PersoMemory evening sweep for ${DATE}.

Process both evidence streams:
1. WorkIQ evidence for ${DATE}, collected as three separate evidence calls.
2. Copilot conversation evidence from pointer-only queue entries in ${PERSOMEMORY_DATA_HOME}/session-reviews/.
3. Skip any queue item whose transcript is missing, empty, or "not captured".

Run the skill's three separate WorkIQ evidence calls before summarizing or writing:
1. Broad Evidence Scan: reconstruct daily context, project movement, risks, people signals, reusable assets, and surprise items. This is not the action audit and not the direction-setting audit.
2. Action Item Audit: inspect meeting tasks, transcript action items, Teams asks, email asks, and shared-file comments for every concrete deliverable. Capture owner, expected output, due date or timing, format, source, confidence, and whether the action is explicit or inferred. Do not limit this pass to top signals.
3. Direction Setting Audit: inspect manager, mentor, leadership, and career conversations for guidance that changes future goals, role direction, positioning, exposure, skills, or behavior. Separate past-impact recognition from future direction.

Merge contract:
1. Deduplicate across all three WorkIQ outputs, Copilot conversation evidence, and current vault state.
2. Preserve source attribution from the originating evidence call.
3. If one WorkIQ call fails, continue with the other evidence streams and write a Sweep Failures approval item.

Apply low-risk daily and operational writes:
1. Merge the daily note for ${DATE}.
2. Add clear new open loops. Mirror every still-open concrete action into memory/commitments/open-loops.md, including one-slide summaries, review tasks, next-meeting deliverables, follow-ups, and delegated asks.
3. Update active context only when explicit and low ambiguity.
4. Mark processed local conversation queue entries as reviewed or superseded when permissions allow. If not, rely on deduplication and local retention cleanup.

For anything requiring Florian approval, do not resolve it. Write a pending approval item to:

memory/inbox/approvals/${DATE}.md

Approval gates:
1. Editing MEMORY.md.
2. Creating career evidence.
3. Updating durable career goals or feedback from manager/mentor direction.
4. Promoting durable project, people, pattern, decision, or toolkit notes.
5. Closing projects.
6. Closing ambiguous commitments.
7. Resolving conflicting evidence.
8. Capturing potentially sensitive content.

Use an approval inbox section named "Career Direction and Feedback Updates" when a manager, mentor, or leader gives future role or career guidance that should update memory/career/feedback.md or memory/career/goals.md.

If WorkIQ, MCP, permission, vault, or transcript access fails, write a Sweep Failures item in the approval inbox if possible and continue with whatever evidence is available.

Do not use scheduled prompt tools or schedule management tools during this sweep.
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
