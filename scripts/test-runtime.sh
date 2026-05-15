#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_DIR}"

bash -n scripts/install.sh
bash -n scripts/run-evening-sweep.sh
bash -n config/hooks/scripts/persomemory-session-start.sh
bash -n config/hooks/scripts/persomemory-agent-stop.sh
bash -n config/hooks/scripts/persomemory-session-end.sh

node -e "JSON.parse(require('fs').readFileSync('config/hooks/persomemory-session.json','utf8'))"
node -e "const config = JSON.parse(require('fs').readFileSync('config/mcp-config.example.json','utf8')); if (!config.mcpServers['workiq-teams']) throw new Error('missing workiq-teams MCP config')"

cmp -s config/copilot-instructions.md .github/copilot-instructions.md
test "$(wc -c < config/copilot-instructions.md)" -le 1200
grep -q 'invoke the relevant PersoMemory skill' config/copilot-instructions.md
grep -q 'Detailed PersoMemory behavior belongs in the installed PersoMemory skills' config/copilot-instructions.md
grep -q 'Backed up existing Copilot instructions' scripts/install.sh

for forbidden in \
  'Session Naming' \
  '/rename' \
  'PersoMemory setup' \
  'Discuss or modify the memory ontology' \
  '~/.copilot/skills' \
  'workflow prompts' \
  'prompts/morning-brief.md' \
  'prompts/evening-sweep.md' \
  'prompts/weekly-consolidation.md' \
  'ObsidianVaultPersoMemory' \
  'ProjectArchive/PersoMemory' \
  'WorkIQ call 1: Broad Evidence Scan' \
  'Graph-Writing Contract' \
  'Career Evidence Impact Taxonomy' \
  'Frontmatter examples' \
  'Daily Intake Workflow' \
  'Durable Memory Update Workflow'; do
  ! grep -q "${forbidden}" config/copilot-instructions.md
  ! grep -q "${forbidden}" .github/copilot-instructions.md
done

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT

fixture_vault="${tmpdir}/vault"
mkdir -p "${fixture_vault}/memory/active" "${fixture_vault}/memory/commitments"
printf '# Memory\n' > "${fixture_vault}/MEMORY.md"
printf '# Now\n' > "${fixture_vault}/memory/active/now.md"
printf '# Open Loops\n' > "${fixture_vault}/memory/commitments/open-loops.md"

printf '{"sessionId":"startup","source":"manual-test","cwd":"/tmp/project"}' \
  | PERSOMEMORY_DATA_HOME="${tmpdir}" PERSOMEMORY_VAULT_PATH="${fixture_vault}" bash config/hooks/scripts/persomemory-session-start.sh >"${tmpdir}/session-start.out"

test -f "${tmpdir}/session-start-events.jsonl"
grep -q '"additionalContext":true' "${tmpdir}/session-start-events.jsonl"
grep -q 'MEMORY.md' "${tmpdir}/session-start-events.jsonl"
grep -q 'memory/active/now.md' "${tmpdir}/session-start-events.jsonl"
grep -q 'memory/commitments/open-loops.md' "${tmpdir}/session-start-events.jsonl"
grep -q 'additionalContext' "${tmpdir}/session-start.out"

printf '{"sessionId":"startup-unsafe-data-home","source":"manual-test","cwd":"/tmp/project"}' \
  | PERSOMEMORY_DATA_HOME="/" PERSOMEMORY_VAULT_PATH="${fixture_vault}" bash config/hooks/scripts/persomemory-session-start.sh >"${tmpdir}/session-start-unsafe-data-home.out" 2>"${tmpdir}/session-start-unsafe-data-home.err"
grep -q 'additionalContext' "${tmpdir}/session-start-unsafe-data-home.out"
grep -q 'PersoMemory sessionStart diagnostics failed' "${tmpdir}/session-start-unsafe-data-home.err"

printf '{"sessionId":"without-transcript","timestamp":1778683417000,"cwd":"/tmp/project","stopReason":"end_turn"}' \
  | PERSOMEMORY_DATA_HOME="${tmpdir}" bash config/hooks/scripts/persomemory-agent-stop.sh >/dev/null
printf '{"sessionId":"without-transcript","timestamp":1778683417000,"cwd":"/tmp/project","reason":"user_exit"}' \
  | PERSOMEMORY_DATA_HOME="${tmpdir}" bash config/hooks/scripts/persomemory-session-end.sh >/dev/null

test -f "${tmpdir}/agent-stop-events.jsonl"
test -f "${tmpdir}/session-end-events.jsonl"
test ! -e "${tmpdir}/session-reviews/2026-05-13.md"
grep -q '"hasTranscriptPath":false' "${tmpdir}/agent-stop-events.jsonl"

printf '{"sessionId":"with-transcript","timestamp":1778683417000,"cwd":"/tmp/project","conversation":{"transcript_path":"/tmp/transcript.jsonl"},"stopReason":"end_turn"}' \
  | PERSOMEMORY_DATA_HOME="${tmpdir}" bash config/hooks/scripts/persomemory-agent-stop.sh >/dev/null
printf '{"sessionId":"with-transcript","timestamp":1778683417000,"cwd":"/tmp/project","reason":"user_exit"}' \
  | PERSOMEMORY_DATA_HOME="${tmpdir}" bash config/hooks/scripts/persomemory-session-end.sh >/dev/null

test -f "${tmpdir}/session-transcripts/with-transcript.json"
test -f "${tmpdir}/session-reviews/2026-05-13.md"
grep -q '/tmp/transcript.jsonl' "${tmpdir}/session-reviews/2026-05-13.md"
grep -q '"hasTranscriptPath":true' "${tmpdir}/agent-stop-events.jsonl"

for skill in persomemory persomemory-morning-brief persomemory-daily-sweep persomemory-consolidation; do
  test -f "skills/${skill}/SKILL.md"
  grep -q "name: ${skill}" "skills/${skill}/SKILL.md"
done
test ! -e skills/persomemory/prompts

install_home="${tmpdir}/install-home"
HOME="${install_home}" bash -c '
  set -euo pipefail
  source scripts/install.sh
  mkdir -p "${COPILOT_DIR}/skills/persomemory-old-workflow" "${COPILOT_DIR}/skills/unrelated-skill"
  install_skills >/dev/null
  test ! -e "${COPILOT_DIR}/skills/persomemory-old-workflow"
  test -d "${COPILOT_DIR}/skills/unrelated-skill"
  test -f "${COPILOT_DIR}/skills/persomemory-daily-sweep/SKILL.md"
'

grep -q 'Execution Rule' skills/persomemory/SKILL.md
grep -q 'Core PersoMemory operations' skills/persomemory/SKILL.md
! grep -q 'WorkIQ Call 1: Broad Evidence Scan' skills/persomemory/SKILL.md
! grep -q 'WorkIQ Call 2: Action Item Audit' skills/persomemory/SKILL.md
! grep -q 'WorkIQ Call 3: Direction Setting Audit' skills/persomemory/SKILL.md
grep -q 'morning sweep' skills/persomemory-morning-brief/SKILL.md
grep -q 'pending approval' skills/persomemory-morning-brief/SKILL.md
grep -q 'Broad Evidence Scan' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Action Item Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Direction Setting Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Merge Contract' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Copilot Conversation Evidence Bundle' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Session Inventory and Coverage Check' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Outcome and Loop Closure Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Decision and Rationale Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Direction-Setting and Feedback Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Reusable Asset and Pattern Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Risk and Weak Signal Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Routing and Approval Audit' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Sweep Failures' skills/persomemory-daily-sweep/SKILL.md
grep -q 'not captured' skills/persomemory-daily-sweep/SKILL.md
grep -q 'Career Direction and Feedback Updates' skills/persomemory-daily-sweep/SKILL.md
grep -q 'dream' skills/persomemory-consolidation/SKILL.md
grep -q 'DREAMS.md' skills/persomemory-consolidation/SKILL.md
grep -q 'Career Direction and Feedback Updates' skills/persomemory/SKILL.md
grep -q 'workiq-teams' config/agents/persomemory-agent.agent.md
grep -q 'Work IQ Teams is an action surface' skills/persomemory/SKILL.md
grep -q 'not captured' skills/persomemory/SKILL.md
grep -q 'Invocation boundary' config/agents/persomemory-agent.agent.md
grep -q 'not captured' config/agents/persomemory-agent.agent.md
grep -q 'Broad Evidence Scan' config/agents/persomemory-agent.agent.md
grep -q 'Action Item Audit' config/agents/persomemory-agent.agent.md
grep -q 'Direction Setting Audit' config/agents/persomemory-agent.agent.md
grep -q 'Career Direction and Feedback Updates' templates/approval-inbox.md

PERSOMEMORY_DATA_HOME="${tmpdir}/runtime" COPILOT_BIN=/bin/echo ./scripts/run-evening-sweep.sh 2026-05-13 >"${tmpdir}/sweep.out"
grep -q -- '--agent persomemory-agent' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=workiq' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=mcpvault' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=smart-connections' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=persomemory-lifecycle' "${tmpdir}/sweep.out"
grep -q 'Do not delegate this sweep to a nested subagent' "${tmpdir}/sweep.out"
grep -q 'Use the persomemory-daily-sweep skill' "${tmpdir}/sweep.out"
grep -q 'not captured' "${tmpdir}/sweep.out"
grep -q 'Broad Evidence Scan' "${tmpdir}/sweep.out"
grep -q 'Action Item Audit' "${tmpdir}/sweep.out"
grep -q 'Direction Setting Audit' "${tmpdir}/sweep.out"
grep -q 'Copilot Conversation Evidence Bundle' "${tmpdir}/sweep.out"
grep -q 'Session Inventory and Coverage Check' "${tmpdir}/sweep.out"
grep -q 'Outcome and Loop Closure Audit' "${tmpdir}/sweep.out"
grep -q 'Decision and Rationale Audit' "${tmpdir}/sweep.out"
grep -q 'Direction-Setting and Feedback Audit' "${tmpdir}/sweep.out"
grep -q 'Reusable Asset and Pattern Audit' "${tmpdir}/sweep.out"
grep -q 'Risk and Weak Signal Audit' "${tmpdir}/sweep.out"
grep -q 'Routing and Approval Audit' "${tmpdir}/sweep.out"
grep -q 'Merge contract' "${tmpdir}/sweep.out"
grep -q 'Career Direction and Feedback Updates' "${tmpdir}/sweep.out"

./scripts/validate-memory-vault.sh

echo "PersoMemory runtime checks passed"
