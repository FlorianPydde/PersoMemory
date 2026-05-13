#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COPILOT_DIR="${HOME}/.copilot"

mkdir -p "${COPILOT_DIR}/skills/persomemory"
cp -r "${REPO_DIR}/skills/persomemory/." "${COPILOT_DIR}/skills/persomemory/"
echo "Installed persomemory skill to ${COPILOT_DIR}/skills/persomemory/SKILL.md"

mkdir -p "${COPILOT_DIR}/agents"
cp "${REPO_DIR}/config/agents/persomemory-agent.agent.md" "${COPILOT_DIR}/agents/persomemory-agent.agent.md"
echo "Installed persomemory-agent to ${COPILOT_DIR}/agents/persomemory-agent.agent.md"

mkdir -p "${COPILOT_DIR}/hooks/scripts"
cp "${REPO_DIR}/config/hooks/persomemory-session.json" "${COPILOT_DIR}/hooks/persomemory-session.json"
cp "${REPO_DIR}/config/hooks/scripts/persomemory-session-start.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-session-start.sh"
cp "${REPO_DIR}/config/hooks/scripts/persomemory-agent-stop.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-agent-stop.sh"
cp "${REPO_DIR}/config/hooks/scripts/persomemory-session-end.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-session-end.sh"
chmod +x "${COPILOT_DIR}/hooks/scripts/persomemory-session-start.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-agent-stop.sh" "${COPILOT_DIR}/hooks/scripts/persomemory-session-end.sh"
echo "Installed PersoMemory hooks to ${COPILOT_DIR}/hooks/persomemory-session.json"

LIFECYCLE_MCP_DIR="${HOME}/persomemory-lifecycle-mcp"
mkdir -p "${LIFECYCLE_MCP_DIR}"
cp -r "${REPO_DIR}/mcp/lifecycle/." "${LIFECYCLE_MCP_DIR}/"
(cd "${LIFECYCLE_MCP_DIR}" && npm install --silent)
echo "Installed persomemory-lifecycle MCP to ${LIFECYCLE_MCP_DIR}"
echo "Register it in ${COPILOT_DIR}/mcp-config.json — see config/mcp-config.example.json for the entry."

echo "Review config/mcp-config.example.json before copying it to ${COPILOT_DIR}/mcp-config.json"
echo "Review config/copilot-instructions.md before copying it to ${COPILOT_DIR}/copilot-instructions.md"
