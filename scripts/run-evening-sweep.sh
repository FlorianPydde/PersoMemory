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
Do not delegate this sweep to a nested subagent.

Use the /memory-sweep skill to run the memory evening sweep for ${DATE}.

Process both evidence streams:
1. WorkIQ evidence for ${DATE}, collected as six candidate-list evidence passes.
2. Copilot conversation evidence from pointer-only queue entries in ${PERSOMEMORY_DATA_HOME}/session-reviews/.
3. Treat queued missing, empty, unreadable, or "not captured" transcripts as Sweep Failures rather than silent skips.

Run the skill's six WorkIQ candidate-list passes before summarizing or writing:
1. Obligations and Requests: concrete asks, promises, deliverables, owners, due dates, blockers, and direct requests to Florian.
2. Project or Outcome Changes: status, scope, owner, date, blocker, dependency, next step, risk, success criterion, or priority changes.
3. Career, Feedback, and Guidance: manager, skip-level, mentor, leadership, customer, or senior stakeholder feedback, recognition, role guidance, and career direction.
4. Decisions, Risks, and Dependencies: explicit decisions, reversals, tradeoffs, approvals, unresolved questions, blockers, waiting-on items, assumptions, and constraints.
5. Reusable Artifacts and Ideas: decks, one-slides, code artifacts, prompts, demos, blogs, templates, workshops, playbooks, checklists, frameworks, architecture patterns, evaluation methods, reusable narratives, and lessons.
6. Direct Mentions and Questions to Florian: @mentions, direct questions, ownership assignments, and expected responses.

For every WorkIQ pass, require candidate lists with source type, source detail, sender or speaker, date/time, exact wording or close paraphrase, confidence, ambiguity, and the literal phrase "No candidates found" when empty. Do not ask WorkIQ to decide what is memory-worthy.

Merge contract:
1. Deduplicate across all six WorkIQ outputs, Copilot conversation evidence, and current vault state.
2. Preserve source attribution from the originating evidence call.
3. If one WorkIQ call fails, continue with the other evidence streams and write a Sweep Failures approval item.
4. If WorkIQ and Copilot evidence conflict, do not resolve it silently. Write an approval item with both sources.

Run the skill's structured Copilot session sweep before memory routing:
1. Session Inventory and Coverage Check: classify queued sessions as reviewable, not captured, or duplicate/superseded.
2. Outcome and Loop Closure Audit: identify the loop, Teams ask, repo task, bug, feature, plan, or decision moved or closed.
3. Action Item Audit: capture concrete follow-ups with owner, expected output, timing, explicit/inferred status, confidence, and keep/discard reason.
4. Decision and Rationale Audit: capture decisions, tradeoffs, rejected options, constraints, and why the choice matters later.
5. Direction-Setting and Feedback Audit: capture career, role, leadership, manager, customer, or strategy guidance separately from recognition or impact evidence.
6. Reusable Asset and Pattern Audit: capture prompts, scripts, checklists, workflow changes, tests, docs, playbooks, and reusable reasoning patterns.
7. Risk and Weak Signal Audit: capture unresolved uncertainty, shallow-capture risk, missing data, conflicting evidence, fragile assumptions, and follow-ups that could be lost.
8. Routing and Approval Audit: route each retained signal as daily evidence, open loop update, active context update, durable promotion candidate, approval item, approval routing preference candidate, or discard.

Apply low-risk daily and operational writes:
1. Merge the daily note for ${DATE}.
2. Add clear new open loops. Mirror every still-open concrete action into memory/content/commitments/open-loops.md, including one-slide summaries, review tasks, next-meeting deliverables, follow-ups, and delegated asks.
3. Update active context only when explicit and low ambiguity.
4. Mark processed local conversation queue entries as reviewed or superseded when permissions allow. If not, rely on deduplication and local retention cleanup.

Before routing ambiguous signals, read memory/governance/ontology/contract.md. Use it to decide whether a signal belongs in daily evidence, active context, commitments, durable memory, a maintenance report, approvals, or discard.

For anything requiring Florian approval, do not resolve it. Write a pending approval item to:

memory/governance/approvals/${DATE}.md

Before creating approval items, read memory/governance/preferences/approval-routing.md if it exists. Approvals are hard gates, not a suggestion inbox. Suppress weak approval candidates according to those preferences.

Approval gates:
1. Editing MEMORY.md.
2. Creating career evidence.
3. Updating durable career goals or feedback from manager/mentor direction.
4. Promoting durable project, people, pattern, decision, or toolkit notes.
5. Closing projects.
6. Closing ambiguous commitments.
7. Resolving conflicting evidence.
8. Capturing potentially sensitive content.

Each approval item must include Decision required, Recommended answer, Why this is gated, Evidence, If approved, If rejected, Default if no answer, and Preference signal to watch.

Use an approval section named "Career Direction and Feedback Updates" when a manager, mentor, or leader gives future role or career guidance that should update memory/content/career/feedback.md or memory/content/career/goals.md.

If Florian explicitly asks to remember an approval-routing preference, or at least three matching approval decisions suggest the same preference, create an "Approval Routing Preference Candidates" item with the proposed rule, supporting examples, risks of learning it, risks of not learning it, and a recommendation. Do not update memory/governance/preferences/approval-routing.md without approval.

If WorkIQ, MCP, permission, vault, or transcript access fails, write a Sweep Failures item in approvals if possible and continue with whatever evidence is available.

Do not use scheduled prompt tools or schedule management tools during this sweep.
PROMPT
)"

cd "${VAULT_PATH}"

"${COPILOT_BIN}" \
  --add-dir "${PERSOMEMORY_DATA_HOME}" \
  --allow-tool='read' \
  --allow-tool='workiq' \
  --allow-tool='mcpvault' \
  --allow-tool='smart-connections' \
  --allow-tool='persomemory-lifecycle' \
  --no-ask-user \
  --prompt "${PROMPT}" \
  2>&1 | tee -a "${LOG_DIR}/evening-sweep-${DATE}.log"
