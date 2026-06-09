# PersoMemory

PersoMemory is the source of truth for Florian's personal memory system setup.

It stores the artifacts needed to rebuild the system on a new machine: Copilot instructions, MCP config examples, memory skills, templates, ontology docs, recovery docs, optional hook guidance, and setup scripts.

It is not the active memory store. The active memory content lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory`

## Replication Model

This repository exists to replicate the local PersoMemory setup from one machine to another. Runtime files should be changed in this repository first, then installed locally with `./scripts/install.sh`.

`config/copilot-instructions.md` is the canonical source for the local global file at `~/.copilot/copilot-instructions.md`. The repository `.github/copilot-instructions.md` intentionally matches it because this repo is a recovery source, not a separate product with different agent behavior.

Detailed memory behavior belongs in the memory skill family under `skills/*/SKILL.md`. The Copilot instructions are only a concise router into those assets.

## Runtime Pieces

1. `~/.copilot/copilot-instructions.md`: concise global Copilot router installed from `config/copilot-instructions.md`.
2. `~/.copilot/mcp-config.json`: runtime MCP configuration installed from `config/mcp-config.example.json` when missing.
3. `~/.copilot/skills/memory*/SKILL.md`: runtime memory skill family.
4. `~/.copilot/hooks/persomemory-session.json`: optional session start and session end hooks.
5. `~/.local/share/persomemory`: disposable local queue and hook runtime state.
6. Obsidian vault: durable memory content.
7. `governance/ontology/contract.md`: vault-canonical live routing, retrieval, decay, and maintenance policy.
8. `~/persomemory-lifecycle-mcp`: local lifecycle MCP installed from `mcp/lifecycle`.
9. `~/smart-connections-mcp`: local Smart Connections MCP cloned and built by the installer when missing.
10. This repo: versioned recovery source.

## Repository Layout

```text
.github/copilot-instructions.md     Repo instructions for agents working on PersoMemory
config/                             Recovery copies and examples for runtime config
config/agents/                      Optional non-PersoMemory personal agent profiles
config/hooks/                       User-level Copilot hook templates and scripts
docs/                               Spec, ontology, hooks, and recovery docs
evals/                              Lightweight trigger-evaluation prompts
scripts/                            Install and validation scripts
scripts/run-evening-sweep.sh         Cron/systemd helper for unattended evening sweep
skills/memory*/SKILL.md             Source copies of the runtime skill family
templates/                          Vault note templates
```

## Install Runtime Skills

```bash
./scripts/install.sh
```

The installer is a small local bootstrapper, not part of the memory model. It copies the global Copilot instructions, creates `~/.copilot/mcp-config.json` when missing, installs the four memory skills, hooks, evening sweep helper, optional non-memory agent profiles, lifecycle MCP, and Smart Connections MCP into local runtime locations. It also removes obsolete `persomemory*` runtime skills/custom agents and stale managed `memory*` skill installs. If an existing `~/.copilot/copilot-instructions.md` differs from the source copy, the installer creates a timestamped backup before overwriting it.

Smart Connections has two parts:

1. The Obsidian community plugin, installed inside the vault so it creates `.smart-env/`.
2. The local MCP bridge at `~/smart-connections-mcp`, installed by `./scripts/install.sh`.

Semantic search returns useful results only after Obsidian has opened the vault with the Smart Connections plugin enabled and indexed it.

## Validate Vault Structure

```bash
./scripts/validate-memory-vault.sh
```

## Architecture Notes

1. `docs/memory-challenge.md`: top down model of the personal memory problem.
2. `docs/ontology.md`: note types, schemas, graph rules, and pointer to the vault-canonical ontology contract.
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

The helper runs the PersoMemory evening sweep with narrow Copilot permissions: read access to the local queue plus the required MCP servers. Approval-gated decisions are written to `governance/approvals/YYYY-MM-DD.md` and picked up by the morning brief.

## Operating Model

MCPs provide access. The memory skill family provides judgment, routing, and workflow-specific instructions.

1. WorkIQ retrieves Microsoft 365 evidence.
2. Work IQ Teams sends or manages Teams chats and channel messages when explicit user intent is present.
3. Copilot conversation hooks queue transcript pointers as local evidence under `~/.local/share/persomemory`.
4. MCPVault reads and writes the Obsidian vault.
5. Smart Connections retrieves related notes from the plugin-generated `.smart-env/` index.
6. persomemory-lifecycle surfaces stale outcomes, overdue review dates, and aged loops.
7. `governance/ontology/contract.md` defines live category boundaries, routing, retrieval triggers, decay rules, durable-entity thresholds, and maintenance eval examples.
8. `memory-router` defines core retrieval, live capture, routing, and write gates.
9. `memory-brief` defines broad day-level attention.
10. `memory-sweep` defines WorkIQ and Copilot evidence intake.
11. `memory-maintenance` combines consolidation, promotion, stale review, archive, merge, supersede, and cleanup modes.
12. Memory workflows run by invoking the relevant skill directly.

The durable memory store is the Obsidian vault. The local queue is disposable working state and can be rebuilt only by future activity.

Approval items are stored in the vault under `governance/approvals/` because they are curated hard-gate decisions, not raw local queue data or nice-to-have suggestions. PersoMemory workflows load `governance/preferences/approval-routing.md` before creating or reviewing approvals so repeated Florian decisions can become explicit preference candidates.

The ontology contract is stored in the vault under `governance/ontology/contract.md` because it is live memory governance, not only repo documentation. Runtime skills and agents read it when category boundaries, durable promotion, retrieval policy, or maintenance decisions are ambiguous.

For interactive memory work, the current MCP-enabled session should run PersoMemory workflows directly through the relevant skill. Do not route PersoMemory work through custom agents or nested subagents, because delegated agents may not inherit the parent session's MCP connections or permissions.
