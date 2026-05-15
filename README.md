# PersoMemory

PersoMemory is the source of truth for Florian's personal memory system setup.

It stores the artifacts needed to rebuild the system on a new machine: Copilot instructions, MCP config examples, PersoMemory skills, templates, ontology docs, recovery docs, optional hook guidance, and setup scripts.

It is not the active memory store. The active memory content lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

## Replication Model

This repository exists to replicate the local PersoMemory setup from one machine to another. Runtime files should be changed in this repository first, then installed locally with `./scripts/install.sh`.

`config/copilot-instructions.md` is the canonical source for the local global file at `~/.copilot/copilot-instructions.md`. The repository `.github/copilot-instructions.md` intentionally matches it because this repo is a recovery source, not a separate product with different agent behavior.

Detailed memory behavior belongs in the PersoMemory skill family under `skills/*/SKILL.md`. The Copilot instructions are only a concise router into those assets.

## Runtime Pieces

1. `~/.copilot/copilot-instructions.md`: concise global Copilot router installed from `config/copilot-instructions.md`.
2. `~/.copilot/mcp-config.json`: runtime MCP configuration.
3. `~/.copilot/skills/persomemory*/SKILL.md`: runtime PersoMemory skill family.
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
skills/persomemory*/SKILL.md        Source copies of the runtime skill family
templates/                          Vault note templates
```

## Install Runtime Skills

```bash
./scripts/install.sh
```

The installer copies the global Copilot instructions, all PersoMemory skills, PersoMemory agent, hooks, evening sweep helper, and lifecycle MCP into the local runtime locations. If an existing `~/.copilot/copilot-instructions.md` differs from the source copy, the installer creates a timestamped backup before overwriting it.

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

MCPs provide access. The PersoMemory skill family provides judgment, routing, and workflow-specific instructions. The `persomemory-agent` operates the workflow.

1. WorkIQ retrieves Microsoft 365 evidence.
2. Work IQ Teams sends or manages Teams chats and channel messages when explicit user intent is present.
3. Copilot conversation hooks queue transcript pointers as local evidence under `~/.local/share/persomemory`.
4. MCPVault reads and writes the Obsidian vault.
5. Smart Connections retrieves related notes.
6. persomemory-lifecycle surfaces stale projects, overdue review dates, and aged loops.
7. `persomemory` defines core retrieval, live capture, routing, write gates, and graph rules.
8. `persomemory-morning-brief`, `persomemory-daily-sweep`, and `persomemory-consolidation` define the recurring workflows.
9. The PersoMemory agent runs the routines using those rules.

The durable memory store is the Obsidian vault. The local queue is disposable working state and can be rebuilt only by future activity.

Approval inbox items are stored in the vault under `memory/inbox/approvals/` because they are curated pending decisions, not raw local queue data.

For interactive memory work, the current MCP-enabled session should run PersoMemory workflows directly. The agent markdown can list MCP tools, but it does not by itself grant a nested delegated agent access to the parent session's MCP connections or permissions.
