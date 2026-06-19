# PersoMemory Setup

This is the single source of truth for setting up (or recovering) the personal memory
system on a new machine. It is written to be driven **interactively by an AI agent**:
work through it top to bottom, ask the user before each step, check what already exists,
and only do the work that is actually needed.

There is no install script. The agent performs the setup by following these steps.

## How an agent should run this

1. Go step by step. Before each step, **ask the user** whether the prerequisite is already
   in place (e.g. "Is Obsidian installed?", "Is Node.js installed?").
2. If a prerequisite exists, skip to verification. If not, help install it.
3. Let the user **choose install locations (PATHs)**. Do not hardcode paths. Record the
   user's choices and reuse them in later steps (especially the vault path and the two
   local MCP directories).
4. Never overwrite an existing `~/.copilot/copilot-instructions.md`, `mcp-config.json`, or
   skills without backing up first and confirming with the user.
5. Never copy secrets, tokens, or local session state.

Collect these values up front and reuse them:

| Variable | Meaning | Example |
| --- | --- | --- |
| `VAULT_PATH` | Where the Obsidian vault lives | `C:\Users\<user>\Repos\ObsidianVaultMemory` |
| `PERSOMEMORY_REPO` | Where this repo is checked out | `C:\Users\<user>\Repos\PersoMemory` |
| `SC_MCP_DIR` | Smart Connections MCP install dir | `C:\Users\<user>\smart-connections-mcp` |
| `LIFECYCLE_MCP_DIR` | Lifecycle MCP install dir | `C:\Users\<user>\persomemory-lifecycle-mcp` |
| `COPILOT_DIR` | Copilot CLI config dir | `~/.copilot` |

## Path placeholders (important)

This repo ships **no hardcoded user paths**. Several files contain placeholder tokens that
must be replaced with the user's chosen paths when the files are copied into place:

| Token | Replace with | Appears in |
| --- | --- | --- |
| `<VAULT_PATH>` | the user's `VAULT_PATH` | `config/hooks/persomemory-session*.json`, `skills/memory-*/SKILL.md`, `scripts/run-evening-sweep.sh`, `scripts/validate-memory-vault.sh` |
| `<PERSOMEMORY_REPO>` | the user's `PERSOMEMORY_REPO` | `docs/scheduling.md` (cron examples) |

The agent substitutes these tokens **after copying** a file to its install location (skills,
hooks), or when invoking a script (pass the real path as an env var / argument instead of
relying on the placeholder default). Use the OS-appropriate path style: Windows uses
backslashes (escaped in JSON, e.g. `C:\\Users\\<user>\\Repos\\ObsidianVaultMemory`);
Linux/macOS/WSL use forward slashes.

Example substitution after copying the skills (PowerShell):

```powershell
Get-ChildItem $HOME\.copilot\skills\memory-* -Recurse -Filter SKILL.md |
  ForEach-Object {
    (Get-Content $_.FullName -Raw).Replace('<VAULT_PATH>', $VaultPath) |
      Set-Content $_.FullName
  }
```

Example substitution (bash):

```bash
grep -rl '<VAULT_PATH>' ~/.copilot/skills/memory-* ~/.copilot/hooks |
  xargs sed -i "s|<VAULT_PATH>|${VAULT_PATH}|g"
```

## Components being installed

1. Obsidian vault (`ObsidianVaultMemory`) — durable memory content. Git-backed.
2. Obsidian **Smart Connections** community plugin — generates the `.smart-env/` semantic index.
3. Four memory skills in `~/.copilot/skills/memory-*`.
4. MCP servers in `~/.copilot/mcp-config.json`: `workiq`, `workiq-teams`, `mcpvault`,
   `smart-connections`, `persomemory-lifecycle`.
5. Two local MCP projects: `smart-connections-mcp` (cloned/built) and
   `persomemory-lifecycle-mcp` (copied from `mcp/lifecycle/`).
6. Copilot CLI session hooks in `~/.copilot/hooks/`.
7. Scheduled evening sweep.

## Prerequisites

Ask the user which of these exist; install what is missing.

1. **Node.js** (for `npx`, mcpvault, the local MCP builds). Verify: `node --version`.
2. **git**. Verify: `git --version`.
3. **GitHub Copilot CLI**. Verify: `copilot --version`.
4. **Obsidian** desktop app.
5. **Microsoft 365 Copilot license** (enables WorkIQ MCP and Teams MCP). Tenant admin may
   need to approve WorkIQ consent.

## Step 1 — Obsidian vault

Ask the user where they want the vault (`VAULT_PATH`).

1. Clone the vault repo into the chosen location:
   ```bash
   git clone https://github.com/FlorianPydde/ObsidianVaultMemory.git "<VAULT_PATH>"
   ```
2. If recovering, pull latest instead of cloning.
3. Confirm the six top-level folders exist: `evidence/`, `outcomes/`, `execution/`,
   `reusable/`, `views/`, `governance/`.

## Step 2 — Obsidian + Smart Connections plugin

1. Open the vault in Obsidian (`Open folder as vault` -> `VAULT_PATH`).
2. In `Settings -> Community plugins`, install and enable **Smart Connections**.
3. Let it index. Confirm a `.smart-env/` directory appears in the vault.

Semantic search returns useful results only after this indexing has happened. The MCP
bridge (Step 4) reads this index; without it, semantic queries return nothing.

## Step 3 — Memory skills

Copy the four skill folders from this repo into the Copilot skills directory:

```bash
cp -r skills/memory-router skills/memory-brief skills/memory-sweep skills/memory-maintenance \
  ~/.copilot/skills/
```

Windows PowerShell:

```powershell
Copy-Item -Recurse -Force skills\memory-router,skills\memory-brief,skills\memory-sweep,skills\memory-maintenance $HOME\.copilot\skills\
```

Then remove any obsolete `persomemory*` skill folders from `~/.copilot/skills/` if present.

**Substitute the `<VAULT_PATH>` placeholder** in the copied skill files (see "Path
placeholders" above) so each skill's Memory Store section points at the real vault.

Verify each skill has a `SKILL.md` with a matching `name:` field and no remaining
`<VAULT_PATH>` token.

## Step 4 — MCP servers

### 4a. Build the two local MCPs

Ask the user for `SC_MCP_DIR` and `LIFECYCLE_MCP_DIR`.

Smart Connections MCP (clone + build):

```bash
git clone https://github.com/msdanyg/smart-connections-mcp.git "<SC_MCP_DIR>"
cd "<SC_MCP_DIR>" && npm install && npm run build
```

Lifecycle MCP (copy from this repo + install):

```bash
cp -r mcp/lifecycle/. "<LIFECYCLE_MCP_DIR>/"
cd "<LIFECYCLE_MCP_DIR>" && npm install
```

### 4b. Write `~/.copilot/mcp-config.json`

If the file exists, back it up and merge rather than overwrite. Use this template,
substituting `VAULT_PATH`, `SC_MCP_DIR`, and `LIFECYCLE_MCP_DIR` with the user's chosen
paths (use the path style for the OS — Windows uses escaped backslashes in JSON):

```json
{
  "mcpServers": {
    "workiq": {
      "command": "npx",
      "args": ["-y", "@microsoft/workiq@latest", "mcp"]
    },
    "workiq-teams": {
      "type": "http",
      "url": "https://agent365.svc.cloud.microsoft/agents/tenants/72f988bf-86f1-41af-91ab-2d7cd011db47/servers/mcp_TeamsServer"
    },
    "mcpvault": {
      "command": "npx",
      "args": ["@bitbonsai/mcpvault@latest", "<VAULT_PATH>"]
    },
    "smart-connections": {
      "command": "node",
      "args": ["<SC_MCP_DIR>/dist/index.js"],
      "env": { "SMART_VAULT_PATH": "<VAULT_PATH>" }
    },
    "persomemory-lifecycle": {
      "command": "node",
      "args": ["<LIFECYCLE_MCP_DIR>/index.js"],
      "env": { "VAULT_PATH": "<VAULT_PATH>" }
    }
  }
}
```

## Step 5 — Session hooks

Hooks queue pointer-only conversation review breadcrumbs and inject a pointer-only startup
reminder. They capture the session evidence the sweep reconciles against open loops — see `docs/hooks.md`.

Install the variant for the current OS into `~/.copilot/hooks/` (the runtime filename is
`persomemory-session.json` on every OS):

- **Linux/macOS:** copy `config/hooks/persomemory-session.json` and the three
  `config/hooks/scripts/*.sh` files.
- **Windows:** copy `config/hooks/persomemory-session.windows.json` as
  `persomemory-session.json`, plus the three `config/hooks/scripts/*.ps1` files.

Replace the `<VAULT_PATH>` placeholder in the copied hook JSON (the
`PERSOMEMORY_VAULT_PATH` env value) with the user's `VAULT_PATH`, using the OS-appropriate
path style (escaped backslashes in the Windows JSON).

## Step 6 — Scheduled evening sweep

See `docs/scheduling.md`. The `scripts/run-evening-sweep.sh` helper runs `/memory-sweep`
with narrow tool permissions and writes approval-gated decisions to
`governance/approvals/YYYY-MM-DD.md`. Provide the vault path by exporting
`VAULT_PATH=<VAULT_PATH>` before running (preferred over relying on the placeholder
default), and substitute `<PERSOMEMORY_REPO>` in any cron entry. Add a cron entry for
unattended nightly runs.

## Step 7 — Validate

1. Vault structure and frontmatter schema (pass the real vault path as the argument):
   ```bash
   ./scripts/validate-memory-vault.sh "<VAULT_PATH>"
   ```
2. Confirm the local MCP build artifacts exist:
   - `<SC_MCP_DIR>/dist/index.js`
   - `<LIFECYCLE_MCP_DIR>/index.js`
3. Confirm `.smart-env/` exists in the vault (Step 2).
4. Start Copilot CLI and confirm `workiq`, `mcpvault`, `smart-connections`, and
   `persomemory-lifecycle` are available.
5. Behavioural checks:
   - Ask for a recall on a known project; confirm `memory-router` retrieves only relevant context.
   - Ask "What should I focus on today?"; confirm `memory-brief` handles broad day-level attention.
   - Ask "I am working on <project>. What should I focus on today?"; confirm `memory-router`
     handles scoped attention.
   - Run a daily sweep only after WorkIQ authentication is confirmed.
