#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COPILOT_DIR="${HOME}/.copilot"

mkdir -p "${COPILOT_DIR}/skills/persomemory"
cp "${REPO_DIR}/skills/persomemory/SKILL.md" "${COPILOT_DIR}/skills/persomemory/SKILL.md"
echo "Installed persomemory skill to ${COPILOT_DIR}/skills/persomemory/SKILL.md"

LIFECYCLE_MCP_DIR="${HOME}/persomemory-lifecycle-mcp"
mkdir -p "${LIFECYCLE_MCP_DIR}"
cp -r "${REPO_DIR}/mcp/lifecycle/." "${LIFECYCLE_MCP_DIR}/"
(cd "${LIFECYCLE_MCP_DIR}" && npm install --silent)
echo "Installed persomemory-lifecycle MCP to ${LIFECYCLE_MCP_DIR}"
echo "Register it in ${COPILOT_DIR}/mcp-config.json — see config/mcp-config.example.json for the entry."

echo "Review config/mcp-config.example.json before copying it to ${COPILOT_DIR}/mcp-config.json"
echo "Review config/copilot-instructions.md before copying it to ${COPILOT_DIR}/copilot-instructions.md"
