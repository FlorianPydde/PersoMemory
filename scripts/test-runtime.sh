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

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT

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
