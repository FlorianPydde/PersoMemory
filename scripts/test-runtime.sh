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

grep -q 'Do not delegate this workflow to a nested subagent' skills/persomemory/prompts/evening-sweep.md
grep -q 'Do not use scheduled prompt tools' skills/persomemory/prompts/evening-sweep.md
grep -q 'not captured' skills/persomemory/prompts/evening-sweep.md
grep -q 'Execution Rule' skills/persomemory/SKILL.md
grep -q 'workiq-teams' config/agents/persomemory-agent.agent.md
grep -q 'Work IQ Teams is an action surface' skills/persomemory/SKILL.md
grep -q 'not captured' skills/persomemory/SKILL.md
grep -q 'Invocation boundary' config/agents/persomemory-agent.agent.md
grep -q 'not captured' config/agents/persomemory-agent.agent.md

PERSOMEMORY_DATA_HOME="${tmpdir}/runtime" COPILOT_BIN=/bin/echo ./scripts/run-evening-sweep.sh 2026-05-13 >"${tmpdir}/sweep.out"
grep -q -- '--agent persomemory-agent' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=workiq' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=mcpvault' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=smart-connections' "${tmpdir}/sweep.out"
grep -q -- '--allow-tool=persomemory-lifecycle' "${tmpdir}/sweep.out"
grep -q 'Do not delegate this sweep to a nested subagent' "${tmpdir}/sweep.out"
grep -q 'not captured' "${tmpdir}/sweep.out"

./scripts/validate-memory-vault.sh

echo "PersoMemory runtime checks passed"
