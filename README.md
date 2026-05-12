# PersoMemory

PersoMemory is the source of truth for Florian's personal memory system setup.

It stores the artifacts needed to rebuild the system on a new machine: Copilot instructions, MCP config examples, the PersoMemory skill, templates, ontology docs, recovery docs, optional hook guidance, and setup scripts.

It is not the active memory store. The active memory content lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

## Runtime Pieces

1. `~/.copilot/copilot-instructions.md`: global Copilot behavior.
2. `~/.copilot/mcp-config.json`: runtime MCP configuration.
3. `~/.copilot/skills/persomemory/SKILL.md`: runtime PersoMemory skill.
4. Obsidian vault: memory content.
5. This repo: versioned recovery source.

## Repository Layout

```text
.github/copilot-instructions.md     Repo instructions for agents working on PersoMemory
config/                             Recovery copies and examples for runtime config
docs/                               Spec, ontology, hooks, and recovery docs
scripts/                            Install and validation scripts
skills/persomemory/SKILL.md         Source copy of the runtime skill
templates/                          Vault note templates
```

## Install Runtime Skill

```bash
./scripts/install.sh
```

## Validate Vault Structure

```bash
./scripts/validate-memory-vault.sh
```

## Operating Model

MCPs provide access. The `persomemory` skill provides judgment and routing.

1. WorkIQ retrieves Microsoft 365 evidence.
2. MCPVault reads and writes the Obsidian vault.
3. Smart Connections retrieves related notes.
4. The PersoMemory skill decides what to capture, route, defer, or promote.
