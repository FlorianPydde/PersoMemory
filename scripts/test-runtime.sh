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
node -e "const config = JSON.parse(require('fs').readFileSync('config/mcp-config.example.json','utf8')); for (const name of ['workiq','workiq-teams','mcpvault','smart-connections','persomemory-lifecycle']) if (!config.mcpServers[name]) throw new Error('missing MCP config: '+name); if (!config.mcpServers['smart-connections'].args.includes('/home/flpydde/smart-connections-mcp/dist/index.js')) throw new Error('smart-connections MCP path drifted'); if (!config.mcpServers['persomemory-lifecycle'].args.includes('/home/flpydde/persomemory-lifecycle-mcp/index.js')) throw new Error('lifecycle MCP path drifted')"
grep -q 'ObsidianVaultMemory' config/mcp-config.example.json
! grep -q 'ObsidianVaultPersoMemory' config/mcp-config.example.json
node -e "const evals = JSON.parse(require('fs').readFileSync('evals/skill-triggers/memory-skills.json','utf8')); if (evals.length < 20) throw new Error('expected at least 20 trigger evals'); for (const skill of ['memory-router','memory-brief','memory-sweep','memory-maintenance']) if (!evals.some(e => e.expected_skill === skill)) throw new Error('missing eval for '+skill); if (!evals.some(e => e.expected_skill === null && e.should_trigger === false)) throw new Error('missing negative eval')"

cmp -s config/copilot-instructions.md .github/copilot-instructions.md
test "$(wc -c < config/copilot-instructions.md)" -le 5000
grep -q 'invoke the relevant memory skill' config/copilot-instructions.md
grep -q 'Detailed memory behavior belongs in the installed memory skills' config/copilot-instructions.md
grep -q 'Use `memory-router`' config/copilot-instructions.md
grep -q 'Backed up existing Copilot instructions' scripts/install.sh
grep -q 'install_mcp_config' scripts/install.sh
grep -q 'SMART_CONNECTIONS_MCP_REPO' scripts/install.sh
grep -q 'npm run build --silent' scripts/install.sh
grep -q 'install_lifecycle_mcp' scripts/install.sh
grep -q 'install_smart_connections_mcp' scripts/install.sh

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
mkdir -p "${fixture_vault}/evidence/daily" "${fixture_vault}/evidence/sessions"
mkdir -p "${fixture_vault}/outcomes" "${fixture_vault}/execution" "${fixture_vault}/reusable" "${fixture_vault}/views"
mkdir -p "${fixture_vault}/governance/ontology" "${fixture_vault}/governance/approvals" "${fixture_vault}/governance/maintenance" "${fixture_vault}/governance/preferences"
printf '# V2 Vault\n' > "${fixture_vault}/README.md"
printf '# Active Now\n' > "${fixture_vault}/views/active-now.md"
printf '# Career Impact\n' > "${fixture_vault}/views/career-impact.md"
printf '# Open Loops\n' > "${fixture_vault}/execution/open-loops.md"
printf '# Ontology Contract\n' > "${fixture_vault}/governance/ontology/contract.md"
printf '# Approval Routing\n' > "${fixture_vault}/governance/preferences/approval-routing.md"

printf '{"sessionId":"startup","source":"manual-test","cwd":"/tmp/project"}' \
  | PERSOMEMORY_DATA_HOME="${tmpdir}" PERSOMEMORY_VAULT_PATH="${fixture_vault}" bash config/hooks/scripts/persomemory-session-start.sh >"${tmpdir}/session-start.out"

test -f "${tmpdir}/session-start-events.jsonl"
grep -q '"additionalContext":false' "${tmpdir}/session-start-events.jsonl"
grep -q '"memoryContentLoaded":false' "${tmpdir}/session-start-events.jsonl"
grep -q '"filesLoaded":\[\]' "${tmpdir}/session-start-events.jsonl"
grep -q '"availableSkills":\["memory-router","memory-brief","memory-sweep","memory-maintenance"\]' "${tmpdir}/session-start-events.jsonl"
grep -q '{}' "${tmpdir}/session-start.out"
! grep -q 'additionalContext' "${tmpdir}/session-start.out"
! grep -q 'No memory content was loaded' "${tmpdir}/session-start.out"
! grep -q '# Memory' "${tmpdir}/session-start.out"
! grep -q '# Now' "${tmpdir}/session-start.out"
! grep -q '# Open Loops' "${tmpdir}/session-start.out"

printf '{"sessionId":"startup-unsafe-data-home","source":"manual-test","cwd":"/tmp/project"}' \
  | PERSOMEMORY_DATA_HOME="/" PERSOMEMORY_VAULT_PATH="${fixture_vault}" bash config/hooks/scripts/persomemory-session-start.sh >"${tmpdir}/session-start-unsafe-data-home.out" 2>"${tmpdir}/session-start-unsafe-data-home.err"
grep -q '{}' "${tmpdir}/session-start-unsafe-data-home.out"
! grep -q 'additionalContext' "${tmpdir}/session-start-unsafe-data-home.out"
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

for skill in memory-router memory-brief memory-sweep memory-maintenance; do
  test -f "skills/${skill}/SKILL.md"
  grep -q "name: ${skill}" "skills/${skill}/SKILL.md"
done
test ! -e skills/persomemory/SKILL.md
test ! -e skills/persomemory-morning-brief/SKILL.md
test ! -e skills/persomemory-daily-sweep/SKILL.md
test ! -e skills/persomemory-consolidation/SKILL.md
test ! -e skills/persomemory-graph-steward/SKILL.md

install_home="${tmpdir}/install-home"
HOME="${install_home}" bash -c '
  set -euo pipefail
  source scripts/install.sh
  mkdir -p "${COPILOT_DIR}/skills/persomemory-old-workflow" "${COPILOT_DIR}/skills/memory-sweep" "${COPILOT_DIR}/skills/unrelated-skill"
  printf stale > "${COPILOT_DIR}/skills/memory-sweep/stale.txt"
  install_skills >/dev/null
  test ! -e "${COPILOT_DIR}/skills/persomemory-old-workflow"
  test ! -e "${COPILOT_DIR}/skills/memory-sweep/stale.txt"
  test -d "${COPILOT_DIR}/skills/unrelated-skill"
  test -f "${COPILOT_DIR}/skills/memory-router/SKILL.md"
  test -f "${COPILOT_DIR}/skills/memory-brief/SKILL.md"
  test -f "${COPILOT_DIR}/skills/memory-sweep/SKILL.md"
  test -f "${COPILOT_DIR}/skills/memory-maintenance/SKILL.md"
'

HOME="${install_home}" bash -c '
  set -euo pipefail
  source scripts/install.sh
  mkdir -p "${COPILOT_DIR}/agents"
  touch "${COPILOT_DIR}/agents/persomemory-agent.agent.md" "${COPILOT_DIR}/agents/persomemory-graph-steward.agent.md"
  install_agents >/dev/null
  test ! -e "${COPILOT_DIR}/agents/persomemory-agent.agent.md"
  test ! -e "${COPILOT_DIR}/agents/persomemory-graph-steward.agent.md"
  test -f "${COPILOT_DIR}/agents/et.agent.md"
  test -f "${COPILOT_DIR}/agents/vscode-et.agent.md"
'

grep -q 'Router and policy skill' skills/memory-router/SKILL.md
grep -q 'Project-scoped attention' skills/memory-router/SKILL.md
grep -q 'no memory content should be loaded by default' skills/memory-router/SKILL.md
grep -q 'memory-brief' skills/memory-router/SKILL.md
grep -q 'memory-sweep' skills/memory-router/SKILL.md
grep -q 'memory-maintenance' skills/memory-router/SKILL.md
! grep -q 'WorkIQ Question Battery' skills/memory-router/SKILL.md
! grep -q 'Required Multi-Pass Checklist' skills/memory-router/SKILL.md
grep -q 'broad day-level' skills/memory-brief/SKILL.md
grep -q 'route through `memory-router`' skills/memory-brief/SKILL.md
grep -q 'Pending Approvals' skills/memory-brief/SKILL.md
grep -q 'ObsidianVaultMemory' skills/memory-sweep/SKILL.md
grep -q "VAULT_PATH, 'outcomes'" mcp/lifecycle/index.js
grep -q "VAULT_PATH, 'execution', 'open-loops.md'" mcp/lifecycle/index.js
grep -q 'WorkIQ Question Battery' skills/memory-sweep/SKILL.md
grep -q 'Obligations and Requests' skills/memory-sweep/SKILL.md
grep -q 'Project or Outcome Changes' skills/memory-sweep/SKILL.md
grep -q 'Career, Feedback, and Guidance' skills/memory-sweep/SKILL.md
grep -q 'Decisions, Risks, and Dependencies' skills/memory-sweep/SKILL.md
grep -q 'Reusable Artifacts and Ideas' skills/memory-sweep/SKILL.md
grep -q 'Direct Mentions and Questions to Florian' skills/memory-sweep/SKILL.md
grep -q 'No candidates found' skills/memory-sweep/SKILL.md
grep -q 'Copilot CLI Session Sweep' skills/memory-sweep/SKILL.md
grep -q 'governance/approvals/YYYY-MM-DD.md' skills/memory-sweep/SKILL.md
grep -q 'Maintains the memory vault over time' skills/memory-maintenance/SKILL.md
grep -q 'promote' skills/memory-maintenance/SKILL.md
grep -q 'steward' skills/memory-maintenance/SKILL.md
grep -q 'scoped-maintenance' skills/memory-maintenance/SKILL.md
grep -q 'monthly-compression' skills/memory-maintenance/SKILL.md
grep -q 'Required Multi-Pass Checklist' skills/memory-maintenance/SKILL.md
grep -q 'Supersede' skills/memory-maintenance/SKILL.md
grep -q 'outcomes' scripts/validate-memory-vault.sh
grep -q 'execution/open-loops.md' scripts/validate-memory-vault.sh
grep -q 'governance/maintenance' scripts/validate-memory-vault.sh
grep -q 'workflow output shapes live in the relevant memory skill' docs/spec.md
! grep -q 'memory/content/daily/TEMPLATE.md' scripts/validate-memory-vault.sh
grep -q '"MEMORY.md"' scripts/validate-memory-vault.sh
grep -q '"governance/dreams.md"' scripts/validate-memory-vault.sh
! grep -R -q 'name: persomemory' skills
test ! -e config/agents/persomemory-agent.agent.md
test ! -e config/agents/persomemory-graph-steward.agent.md
grep -q 'Career Direction and Feedback Updates' templates/approvals.md
grep -q 'Decision required' templates/approvals.md
grep -q 'Recommended answer' templates/approvals.md
grep -q 'Why this is gated' templates/approvals.md
grep -q 'Default if no answer' templates/approvals.md
grep -q 'Preference signal to watch' templates/approvals.md
grep -q 'Approval Routing Preference Candidates' templates/approvals.md
grep -q 'type: maintenance-report' templates/maintenance-report.md
grep -q 'Entity Disposition' templates/maintenance-report.md
grep -q 'Cold Evidence / Daily Notes' templates/maintenance-report.md
grep -q 'governance/approvals/YYYY-MM-DD.md' templates/maintenance-report.md
grep -q 'governance/approvals/YYYY-MM-DD.md' README.md
grep -q 'governance/preferences/approval-routing.md' README.md
grep -q 'smart-connections-mcp' README.md
grep -q '.smart-env/' README.md
grep -q 'persomemory-lifecycle-mcp' docs/recovery.md
grep -q 'SMART_CONNECTIONS_MCP_REPO' docs/recovery.md
grep -q '.smart-env/' docs/recovery.md
grep -q 'scripts/run-evening-sweep.sh' docs/spec.md
! grep -q 'node scripts/sweep.js' docs/spec.md
! grep -R -q 'memory/inbox/approvals' README.md docs scripts config skills templates

PERSOMEMORY_DATA_HOME="${tmpdir}/runtime" COPILOT_BIN=/bin/echo ./scripts/run-evening-sweep.sh 2026-05-13 >"${tmpdir}/sweep.out"
! grep -q -- '--agent persomemory-agent' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=workiq' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=mcpvault' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=smart-connections' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=persomemory-lifecycle' "${tmpdir}/sweep.out"
grep -q 'Do not delegate this sweep to a nested subagent' "${tmpdir}/sweep.out"
grep -q 'Use the /memory-sweep skill' "${tmpdir}/sweep.out"
grep -q 'not captured' "${tmpdir}/sweep.out"
grep -q 'Obligations and Requests' "${tmpdir}/sweep.out"
grep -q 'Project or Outcome Changes' "${tmpdir}/sweep.out"
grep -q 'Career, Feedback, and Guidance' "${tmpdir}/sweep.out"
grep -q 'Decisions, Risks, and Dependencies' "${tmpdir}/sweep.out"
grep -q 'Reusable Artifacts and Ideas' "${tmpdir}/sweep.out"
grep -q 'Direct Mentions and Questions to Florian' "${tmpdir}/sweep.out"
grep -q 'No candidates found' "${tmpdir}/sweep.out"
grep -q 'Copilot session sweep' "${tmpdir}/sweep.out"
grep -q 'Session Inventory and Coverage Check' "${tmpdir}/sweep.out"
grep -q 'Outcome and Loop Closure Audit' "${tmpdir}/sweep.out"
grep -q 'Decision and Rationale Audit' "${tmpdir}/sweep.out"
grep -q 'Direction-Setting and Feedback Audit' "${tmpdir}/sweep.out"
grep -q 'Reusable Asset and Pattern Audit' "${tmpdir}/sweep.out"
grep -q 'Risk and Weak Signal Audit' "${tmpdir}/sweep.out"
grep -q 'Routing and Approval Audit' "${tmpdir}/sweep.out"
grep -q 'Merge contract' "${tmpdir}/sweep.out"
grep -q 'Career Direction and Feedback Updates' "${tmpdir}/sweep.out"
grep -q 'governance/approvals/2026-05-13.md' "${tmpdir}/sweep.out"
grep -q 'governance/preferences/approval-routing.md' "${tmpdir}/sweep.out"
grep -q 'governance/ontology/contract.md' "${tmpdir}/sweep.out"
grep -q 'Approvals are hard gates, not a suggestion inbox' "${tmpdir}/sweep.out"
grep -q 'Approval Routing Preference Candidates' "${tmpdir}/sweep.out"

./scripts/validate-memory-vault.sh

echo "PersoMemory runtime checks passed"
