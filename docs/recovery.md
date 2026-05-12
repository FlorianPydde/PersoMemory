# Recovery Guide

This repo is the source of truth for rebuilding the personal memory system on a new machine.

## Runtime Components

1. Obsidian vault: `/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`
2. Copilot MCP config: `~/.copilot/mcp-config.json`
3. Copilot global instructions: `~/.copilot/copilot-instructions.md`
4. PersoMemory skill: `~/.copilot/skills/persomemory/SKILL.md`
5. Smart Connections MCP project: `/home/flpydde/smart-connections-mcp`

## Restore Order

1. Restore the Obsidian vault from OneDrive.
2. Restore or clone this PersoMemory repo.
3. Copy `skills/persomemory/SKILL.md` to `~/.copilot/skills/persomemory/SKILL.md`.
4. Review `config/mcp-config.example.json` and create `~/.copilot/mcp-config.json` with local paths.
5. Review `config/copilot-instructions.md` and create `~/.copilot/copilot-instructions.md`.
6. Build or restore the Smart Connections MCP project.
7. Start Copilot CLI and verify WorkIQ, MCPVault, and Smart Connections are available.

## Validation

1. Ask the agent to read `MEMORY.md`.
2. Ask the agent to read `memory/active/now.md`.
3. Ask the agent to read `memory/commitments/open-loops.md`.
4. Ask for a memory recall on a known project.
5. Ask for a daily sweep only after WorkIQ authentication is confirmed.
