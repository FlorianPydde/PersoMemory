#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COPILOT_DIR="${HOME}/.copilot"

mkdir -p "${COPILOT_DIR}/skills/persomemory"
cp "${REPO_DIR}/skills/persomemory/SKILL.md" "${COPILOT_DIR}/skills/persomemory/SKILL.md"
echo "Installed persomemory skill to ${COPILOT_DIR}/skills/persomemory/SKILL.md"

cp "${REPO_DIR}/scripts/lifecycle-check.py" "${HOME}/.local/bin/lifecycle-check"
chmod +x "${HOME}/.local/bin/lifecycle-check"
echo "Installed lifecycle-check to ${HOME}/.local/bin/lifecycle-check"

echo "Review config/mcp-config.example.json before copying it to ${COPILOT_DIR}/mcp-config.json"
echo "Review config/copilot-instructions.md before copying it to ${COPILOT_DIR}/copilot-instructions.md"
