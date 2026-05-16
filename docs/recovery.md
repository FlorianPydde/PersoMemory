# Recovery Guide

This repo is the source of truth for rebuilding the personal memory system on a new machine.

## Runtime Components

1. Obsidian vault: `/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory`
2. Copilot MCP config: `~/.copilot/mcp-config.json`
3. Copilot global instructions: `~/.copilot/copilot-instructions.md`
4. Memory skills: `~/.copilot/skills/memory*/SKILL.md`
5. Smart Connections MCP project: `/home/flpydde/smart-connections-mcp`

## Restore Order

1. Restore the Obsidian vault from OneDrive.
2. Restore or clone this PersoMemory repo.
3. Run `./scripts/install.sh` to install the four memory skills, Copilot instructions, hooks, evening sweep helper, and lifecycle MCP. If doing this manually, copy `skills/memory*` to `~/.copilot/skills/`.
4. Review `config/mcp-config.example.json` and create `~/.copilot/mcp-config.json` with local paths.
5. Review `config/copilot-instructions.md` and create `~/.copilot/copilot-instructions.md` if you did not use the installer.
6. Build or restore the Smart Connections MCP project.
7. Start Copilot CLI and verify WorkIQ, MCPVault, Smart Connections, and persomemory-lifecycle are available.

## Validation

1. Ask for a memory recall on a known project and confirm the `memory` router retrieves only relevant vault context.
2. Ask "What should I focus on today?" and confirm `memory-brief` handles broad day-level attention.
3. Ask "I am working on Phoenix. What should I focus on today?" and confirm `memory` handles scoped attention.
4. Ask for a daily sweep only after WorkIQ authentication is confirmed.
5. Tail `~/.local/share/persomemory/session-start-events.jsonl` and confirm startup loaded a pointer, not full memory content.
