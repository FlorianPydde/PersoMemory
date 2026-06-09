# Recovery Guide

This repo is the source of truth for rebuilding the personal memory system on a new machine.

## Runtime Components

1. Obsidian vault: `/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory`
2. Copilot MCP config: `~/.copilot/mcp-config.json`
3. Copilot global instructions: `~/.copilot/copilot-instructions.md`
4. Memory skills: `~/.copilot/skills/memory*/SKILL.md`
5. Smart Connections MCP project: `/home/flpydde/smart-connections-mcp`
6. persomemory-lifecycle MCP project: `/home/flpydde/persomemory-lifecycle-mcp`

## Restore Order

1. Restore the Obsidian vault from OneDrive.
2. Restore or clone this PersoMemory repo.
3. Install the Obsidian Smart Connections community plugin in the restored vault and let it generate `.smart-env/`.
4. Run `./scripts/install.sh` to install the four memory skills, Copilot instructions, MCP config when missing, hooks, evening sweep helper, lifecycle MCP, and Smart Connections MCP. If doing this manually, copy `skills/memory*` to `~/.copilot/skills/`, copy `config/mcp-config.example.json` to `~/.copilot/mcp-config.json`, copy `mcp/lifecycle` to `~/persomemory-lifecycle-mcp`, and clone/build Smart Connections MCP into `~/smart-connections-mcp`.
5. Review `config/mcp-config.example.json` and confirm `~/.copilot/mcp-config.json` uses the local paths for the new laptop.
6. Review `config/copilot-instructions.md` and create `~/.copilot/copilot-instructions.md` if you did not use the installer.
7. Start Copilot CLI and verify WorkIQ, MCPVault, Smart Connections, and persomemory-lifecycle are available.

## Local MCP Setup

`scripts/install.sh` installs the local MCPs expected by `config/mcp-config.example.json`:

```text
~/smart-connections-mcp/dist/index.js
~/persomemory-lifecycle-mcp/index.js
```

The installer clones Smart Connections MCP from `https://github.com/msdanyg/smart-connections-mcp.git` when `~/smart-connections-mcp` is missing, then runs `npm install` and `npm run build`. Override `SMART_CONNECTIONS_MCP_REPO` or `SMART_CONNECTIONS_MCP_DIR` when restoring from a fork or non-default path.

The lifecycle MCP is custom PersoMemory code. The installer copies `mcp/lifecycle/` from this repo into `~/persomemory-lifecycle-mcp` and runs `npm install`.

Smart Connections semantic retrieval depends on the Obsidian plugin index, not only the MCP bridge. If `.smart-env/` is missing or empty, the MCP can be present but semantic search will return no useful note results.

## Validation

1. Ask for a memory recall on a known project and confirm the `memory-router` skill retrieves only relevant vault context.
2. Ask "What should I focus on today?" and confirm `memory-brief` handles broad day-level attention.
3. Ask "I am working on Phoenix. What should I focus on today?" and confirm `memory-router` handles scoped attention.
4. Ask for a daily sweep only after WorkIQ authentication is confirmed.
5. Tail `~/.local/share/persomemory/session-start-events.jsonl` and confirm startup loaded a pointer, not full memory content.
6. Confirm `./scripts/validate-memory-vault.sh` passes without requiring `MEMORY.md`, `dreams.md`, or a `memory/` folder.
7. Confirm `test -f ~/smart-connections-mcp/dist/index.js` and `test -f ~/persomemory-lifecycle-mcp/index.js`.
8. Confirm the vault contains `.smart-env/` after opening it in Obsidian with the Smart Connections plugin enabled.
