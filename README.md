# PersoMemory

PersoMemory is the source of truth for the memory-system half of Florian's personal
assistant setup.

It stores the artifacts needed to rebuild the system on a new machine: the memory skills,
vault note templates, ontology and architecture docs, the lifecycle MCP, session hooks, and
operational scripts.

It is **not** the active memory store. The active memory content lives in the Obsidian vault:

`C:\Users\flpydde\Repos\ObsidianVaultMemory`

The global Copilot instructions and personal agent profiles are managed separately in the
dotfiles repo (`~/repos/dotfiles/.copilot/`), not here.

## Setup and recovery

Setup is driven interactively by an AI agent following [`SETUP.md`](SETUP.md). There is no
install script: the agent checks prerequisites, asks the user where to install things, and
performs each step. `SETUP.md` covers prerequisites, the vault, the Smart Connections
plugin, the memory skills, the MCP servers, hooks, scheduling, and validation.

## Repository layout

```text
SETUP.md         Interactive, agent-driven setup and recovery guide
config/hooks/    Copilot CLI session hook templates and scripts (.sh + .ps1 variants)
docs/            Ontology, conceptual model, hooks, scheduling, and ADRs
docs/decisions/  Architecture decision records
mcp/lifecycle/   Source for the persomemory-lifecycle MCP
scripts/         Operational scripts (vault validation, evening sweep)
skills/memory-*  The four runtime memory skills
templates/       Vault note templates
```

## Runtime pieces

1. Obsidian vault: durable memory content (git-backed, `FlorianPydde/ObsidianVaultMemory`).
2. `~/.copilot/skills/memory-*`: the four memory skills (router, brief, sweep, maintenance).
3. `~/.copilot/mcp-config.json`: MCP servers (workiq, workiq-teams, mcpvault,
   smart-connections, persomemory-lifecycle).
4. `~/.copilot/hooks/persomemory-session.json`: optional session start/stop/end hooks.
5. `~/smart-connections-mcp` and `~/persomemory-lifecycle-mcp`: local MCP projects.
6. `governance/ontology/contract.md` (in the vault): canonical live routing, retrieval,
   decay, and maintenance policy.
7. The local data home (`%LOCALAPPDATA%\persomemory` or `~/.local/share/persomemory`):
   disposable pointer-only queue and hook runtime state.

## The memory skills

MCPs provide access. The memory skill family provides judgment, routing, and workflow.

1. `memory-router`: core retrieval, live capture, routing, and write gates.
2. `memory-brief`: broad day-level attention.
3. `memory-sweep`: WorkIQ and Copilot evidence intake.
4. `memory-maintenance`: consolidation, promotion, stale review, archive, merge, supersede,
   and cleanup modes.

Invoke the relevant skill directly. Do not route memory work through nested subagents, which
may not inherit the parent session's MCP connections or permissions.

## Validate vault structure

```bash
./scripts/validate-memory-vault.sh "<VAULT_PATH>"
```

## Architecture notes

1. `docs/memory-challenge.md`: top-down model of the personal memory problem.
2. `docs/ontology.md`: note types, schemas, graph rules, and a pointer to the
   vault-canonical ontology contract.
3. `docs/hooks.md`: Copilot hook behavior and the local pointer-only queue design.
4. `docs/scheduling.md`: unattended evening sweep setup.
5. `docs/decisions/`: architecture decision records.

## Operating model

1. WorkIQ retrieves Microsoft 365 evidence; Work IQ Teams sends/manages Teams messages on
   explicit intent.
2. Copilot conversation hooks queue transcript pointers as local evidence.
3. MCPVault reads and writes the Obsidian vault.
4. Smart Connections retrieves related notes from the plugin-generated `.smart-env/` index.
5. persomemory-lifecycle surfaces stale outcomes, overdue review dates, and aged loops.
6. The vault `governance/ontology/contract.md` defines category boundaries, routing,
   retrieval triggers, decay rules, durable-entity thresholds, and maintenance policy.

Approval items live in the vault under `governance/approvals/` because they are curated
hard-gate decisions. Workflows load `governance/preferences/approval-routing.md` before
creating or reviewing approvals so repeated decisions can become explicit preferences.

The durable memory store is the Obsidian vault. The local queue is disposable working state.
