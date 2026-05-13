# PersoMemory

PersoMemory is the source of truth for Florian's personal memory system setup.

It stores the artifacts needed to rebuild the system on a new machine: Copilot instructions, MCP config examples, the PersoMemory skill, templates, ontology docs, recovery docs, optional hook guidance, and setup scripts.

It is not the active memory store. The active memory content lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

## Runtime Pieces

1. `~/.copilot/copilot-instructions.md`: global Copilot behavior.
2. `~/.copilot/mcp-config.json`: runtime MCP configuration.
3. `~/.copilot/skills/persomemory/SKILL.md`: runtime PersoMemory skill.
4. `~/.copilot/agents/persomemory-agent.agent.md`: runtime PersoMemory operator agent.
5. `~/.copilot/hooks/persomemory-session.json`: optional session start and session end hooks.
6. `~/.local/share/persomemory`: disposable local queue and hook runtime state.
7. Obsidian vault: durable memory content.
8. This repo: versioned recovery source.

## Repository Layout

```text
.github/copilot-instructions.md     Repo instructions for agents working on PersoMemory
config/                             Recovery copies and examples for runtime config
config/agents/                      Personal Copilot agent profiles
config/hooks/                       User-level Copilot hook templates and scripts
docs/                               Spec, ontology, hooks, and recovery docs
scripts/                            Install and validation scripts
scripts/run-evening-sweep.sh         Cron/systemd helper for unattended evening sweep
skills/persomemory/SKILL.md         Source copy of the runtime skill
skills/persomemory/prompts/         Reusable PersoMemory prompt templates
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

## Architecture Notes

1. `docs/memory-challenge.md`: top down model of the personal memory problem.
2. `docs/ontology.md`: note types, schemas, and graph rules.
3. `docs/hooks.md`: Copilot hook behavior and local queue design.
4. `docs/scheduling.md`: unattended evening sweep setup.

## Validate Runtime Behavior

```bash
bash ./scripts/test-runtime.sh
```

## Scheduled Evening Sweep

```bash
./scripts/run-evening-sweep.sh
```

The helper runs the PersoMemory evening sweep with narrow Copilot permissions: read access to the local queue plus the required MCP servers. Approval-gated decisions are written to `memory/inbox/approvals/YYYY-MM-DD.md` and picked up by the morning brief.

## Operating Model

MCPs provide access. The `persomemory` skill provides judgment and routing. The `persomemory-agent` operates the workflow.

1. WorkIQ retrieves Microsoft 365 evidence.
2. Copilot conversation hooks queue transcript pointers as local evidence under `~/.local/share/persomemory`.
3. MCPVault reads and writes the Obsidian vault.
4. Smart Connections retrieves related notes.
5. persomemory-lifecycle surfaces stale projects, overdue review dates, and aged loops.
6. The PersoMemory skill defines what to capture, route, defer, or promote.
7. The PersoMemory agent runs the daily and weekly routines using those rules.

The durable memory store is the Obsidian vault. The local queue is disposable working state and can be rebuilt only by future activity.

Approval inbox items are stored in the vault under `memory/inbox/approvals/` because they are curated pending decisions, not raw local queue data.

For interactive memory work, the current MCP-enabled session should run PersoMemory workflows directly. The agent markdown can list MCP tools, but it does not by itself grant a nested delegated agent access to the parent session's MCP connections or permissions.
