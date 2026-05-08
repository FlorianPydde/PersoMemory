# Spec: PersoMemory

## Objective

Build a personal, evolving memory system that:
1. Uses **Copilot CLI** as the primary agent interface
2. Reads daily work context from Microsoft 365 via **WorkIQ MCP server** (Teams, emails, calls, calendar)
3. Extracts and stores signal as structured Markdown in an **Obsidian vault** (synced via OneDrive)
4. Reads/writes the vault via **MCPVault MCP server**
5. Uses **Smart Connections** (free Obsidian plugin) for semantic search inside Obsidian
6. Runs a nightly ingestion pipeline via **GitHub Actions** (private repo)
7. Over time, consolidates into durable knowledge: project playbooks, decision patterns, org context, career trajectory

**User:** Solo, knowledge worker at Microsoft with M365 Copilot license.

**Success:** When a new project lands, you open your terminal and the agent already knows your past similar work, your decision frameworks, your org context, and can advise strategically.

## Assumptions

```
1. M365 Copilot license available (confirmed) -> enables WorkIQ MCP
2. M365 tenant admin can approve WorkIQ consent
3. Running on Windows with WSL
4. Obsidian installed on Windows
5. OneDrive set up and syncing
6. Node.js available
7. Copilot CLI supports MCP server configuration
8. Private GitHub repo for the pipeline code + Actions workflow
9. OAuth refresh token can be stored as GitHub secret for CI auth
```

## Architecture

```
                       +---------------------------+
                       |    GitHub Actions (CI)    |
                       |    (nightly cron job)     |
                       +---------------------------+
                                   |
                    Runs agent with WorkIQ + MCPVault
                                   |
                                   v
+----------------+       +------------------+       +-------------------+
|  WorkIQ MCP    | ----> |   Agent (LLM)    | ----> |  MCPVault MCP     |
| (@microsoft/   |       |  Extracts signal |       | (@bitbonsai/      |
|  workiq)       |       |  from raw M365   |       |  mcpvault)        |
|                |       |  data            |       |                   |
| Reads: Teams,  |       +------------------+       | Writes: Obsidian  |
| Email, Calls,  |                                  | vault on OneDrive |
| Calendar       |                                  +-------------------+
+----------------+                                           |
                                                             v
                                                  +-------------------+
                                                  | Obsidian Vault    |
                                                  | (OneDrive sync)   |
                                                  |                   |
                                                  | + Smart           |
                                                  |   Connections     |
                                                  |   (semantic       |
                                                  |    search)        |
                                                  +-------------------+
                                                             ^
                                                             |
                                                  +-------------------+
                                                  | You (terminal)    |
                                                  | Copilot CLI +     |
                                                  | MCPVault MCP      |
                                                  | (read/write vault)|
                                                  +-------------------+
```

**Two modes of operation:**

1. **Nightly sweep (GitHub Actions):** Automated. Agent queries WorkIQ for the day's M365 activity, extracts signal, writes to vault via MCPVault. Runs as a scheduled GitHub Actions workflow.

2. **Interactive (terminal):** You talk to Copilot CLI about projects, strategy, problems. The agent reads vault context via MCPVault and writes new insights back. You can also trigger a manual sweep: "sweep my day."

## Tech Stack

| Component | Technology | Cost |
|---|---|---|
| Memory Store | Obsidian vault (Markdown) | Free |
| Sync | OneDrive | Included with M365 |
| Semantic Search | Smart Connections plugin (core) | Free |
| M365 Data Access | WorkIQ MCP (`@microsoft/workiq`) | Free (M365 Copilot license required) |
| Vault Access | MCPVault (`@bitbonsai/mcpvault`) | Free, open source |
| CLI Agent | Copilot CLI | Existing subscription |
| CI/CD | GitHub Actions (private repo) | Free tier (2000 min/month) |
| Auth in CI | M365 OAuth refresh token (GitHub secret) | Free |

## Commands

```bash
# WorkIQ setup
npm install -g @microsoft/workiq
workiq accept-eula
workiq ask -q "What meetings did I have today?"    # test

# MCPVault setup
npm install -g @bitbonsai/mcpvault

# Smart Connections
# Install via Obsidian: Settings > Community Plugins > Browse > "Smart Connections"

# Run the nightly sweep locally (for testing)
node scripts/sweep.js

# GitHub Actions: runs automatically on schedule
```

## Copilot CLI MCP Configuration

```json
{
  "mcpServers": {
    "workiq": {
      "command": "npx",
      "args": ["-y", "@microsoft/workiq", "mcp"]
    },
    "mcpvault": {
      "command": "npx",
      "args": ["-y", "@bitbonsai/mcpvault", "--vault", "/mnt/c/Users/flpydde/OneDrive - Microsoft/ObsidianVault"]
    }
  }
}
```

## Obsidian Vault Structure

```
ObsidianVault/                          (on OneDrive)
  MEMORY.md                             Top-level durable memory (loaded every agent session)
  memory/
    daily/
      2026-05-08.md                     Daily extracted knowledge
    projects/
      {project-name}.md                 Per-project accumulated knowledge
    people/
      {person-name}.md                  Relationship context
    decisions/
      {decision-slug}.md                Key decisions with rationale
    career/
      goals.md                          Current goals, aspirations
      accomplishments.md                Track record
      feedback.md                       Feedback received
    patterns/
      decision-frameworks.md            Reusable heuristics extracted over time
      project-evaluation.md             How you evaluate new projects
```

## GitHub Actions Pipeline

### Workflow File (`.github/workflows/nightly-sweep.yml`)

```yaml
name: Nightly Memory Sweep

on:
  schedule:
    - cron: '0 21 * * 1-5'    # 9pm UTC, weekdays only
  workflow_dispatch:            # manual trigger

jobs:
  sweep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Run memory sweep
        env:
          M365_REFRESH_TOKEN: ${{ secrets.M365_REFRESH_TOKEN }}
          M365_CLIENT_ID: ${{ secrets.M365_CLIENT_ID }}
          VAULT_REPO_TOKEN: ${{ secrets.VAULT_REPO_TOKEN }}
        run: node scripts/sweep.js

      - name: Commit vault changes
        run: |
          # Push updated vault files back (if vault is in this repo)
          # OR: use OneDrive API / rclone to sync to OneDrive
```

### Auth Strategy

1. **One-time local setup:** Run `workiq accept-eula` and complete OAuth login in browser. Capture the refresh token.
2. **Store in GitHub Secrets:** `M365_REFRESH_TOKEN`, `M365_CLIENT_ID`
3. **In the workflow:** The sweep script uses the refresh token to obtain a fresh access token, runs WorkIQ queries, extracts signal, writes Markdown.
4. **Token rotation:** M365 refresh tokens last ~90 days. The workflow can output the new refresh token and update the secret (via GitHub API), or you re-authenticate quarterly.

### Vault Sync from CI

Two options for getting the generated Markdown back to your OneDrive-synced vault:

**Option A: Vault lives in the same private repo**
- CI writes Markdown files, commits, and pushes
- You clone/pull the repo on your machine (or symlink into OneDrive)
- Simple, git-versioned, but adds a sync step

**Option B: CI writes directly to OneDrive via Microsoft Graph API**
- Upload generated Markdown files to OneDrive using Graph API
- Files appear in your Obsidian vault automatically
- More complex auth, but seamless sync

**Option C: Vault lives in repo AND syncs to OneDrive**
- CI commits to repo
- Local machine has the repo inside OneDrive folder
- Git pull syncs new content, OneDrive syncs across devices

**Recommended: Option A** (simplest to start, git gives you version history).

## Agent Workflows

### 1. Nightly Sweep (automated, GitHub Actions)

The sweep script:
1. Authenticates to M365 using refresh token
2. Queries WorkIQ: "Summarize my Teams conversations from today"
3. Queries WorkIQ: "What emails did I send or receive today?"
4. Queries WorkIQ: "What meetings did I have and what was discussed?"
5. Filters: extracts only signal (facts, decisions, action items, goals, insights)
6. Generates daily note Markdown (`memory/daily/YYYY-MM-DD.md`)
7. Updates relevant project/people files if significant
8. Commits and pushes to repo

### 2. Interactive Memory (Copilot CLI, manual)

You open terminal, Copilot CLI has MCPVault configured:
- **Recall:** "What do I know about Project X?" -> agent reads vault
- **Write:** After a conversation, agent writes insights to vault
- **Manual sweep:** "Sweep my day" -> same as nightly but interactive
- **Consolidate:** "Consolidate this week" -> dreaming pass

### 3. Weekly Consolidation ("Dreaming")

Can be automated (separate weekly cron) or manual:
1. Read all daily notes from past week
2. Promote durable knowledge to project/people/MEMORY.md
3. Extract recurring decision patterns into `patterns/`
4. Archive or tag processed daily notes

## Daily Note Template

```markdown
# 2026-05-08

## Key Interactions
- **[Person]** re: [Topic] -- [what was discussed/decided]

## Decisions Made
- [Decision]: [rationale]

## Action Items
- [ ] [action] (owner: [person], by: [date])

## Insights
- [anything worth remembering long-term]

## Projects Touched
- [[projects/ProjectX]]: [what happened]

## Source
- Teams: [channels/DMs referenced]
- Email: [thread subjects]
- Meetings: [meeting names]
```

## Boundaries

**Always:**
- Write human-readable Markdown
- Include source attribution (where did this fact come from?)
- Discard low-confidence extractions (90%+ of raw data is noise)
- Keep MEMORY.md concise (max ~2000 words, curated)
- Version control everything (git)

**Ask first:**
- Before deleting or overwriting existing memory files
- Before changing vault structure
- Before modifying the extraction prompts
- Before running consolidation that modifies MEMORY.md

**Never:**
- Store raw email/chat content in the vault (extracted knowledge only)
- Store credentials or secrets in the vault or in code
- Auto-delete daily notes without confirmation
- Commit the `.env` file or tokens

## Success Criteria

1. **WorkIQ answers M365 queries:** `workiq ask -q "What did I discuss today?"` returns real results
2. **MCPVault reads/writes vault:** Copilot CLI can create and read notes
3. **GitHub Actions runs nightly:** Workflow executes on schedule, generates daily note, commits to repo
4. **Daily sweep produces value:** Generated daily notes have >80% useful signal, <20% noise
5. **Memory recall works:** Ask about a past project via Copilot CLI and get relevant context
6. **Smart Connections surfaces connections:** Semantic search in Obsidian finds related notes across dates/projects
7. **Consolidation improves MEMORY.md:** After 2+ weeks, dreaming pass produces meaningful long-term knowledge

## MVP Phases

### Phase 1: Infrastructure
- Create private GitHub repo
- Set up Obsidian vault on OneDrive with folder structure
- Install Smart Connections plugin
- Install and test WorkIQ (`workiq ask` works)
- Install and test MCPVault (Copilot CLI can read/write vault)
- Configure MCP servers in Copilot CLI

### Phase 2: Interactive Memory (Terminal)
- Configure Copilot CLI to read MEMORY.md + recent daily notes at session start
- Test organic memory write: conversation -> vault update
- Test recall: "What do I know about X?" -> relevant vault content
- Use for 1-2 weeks, iterate on quality

### Phase 3: Automated Nightly Sweep (GitHub Actions)
- Build sweep script (`scripts/sweep.js`)
- Set up OAuth token flow + GitHub secrets
- Create GitHub Actions workflow
- Test end-to-end: scheduled run -> daily note generated -> committed to repo
- Solve vault sync (repo -> OneDrive or direct)

### Phase 4: Consolidation / Dreaming
- Build weekly consolidation workflow
- Promote durable knowledge from daily notes to long-term files
- Extract decision patterns
- Iterate on MEMORY.md quality

## Not Doing (and Why)

- **Custom Python ingestion pipeline** -- WorkIQ MCP replaces this. Agent + WorkIQ is the pipeline.
- **Custom embedding infrastructure** -- Smart Connections handles semantic search. No FAISS needed.
- **Real-time ingestion** -- Nightly batch + manual trigger is sufficient. No webhooks.
- **Custom UI** -- Obsidian for browsing, terminal for interacting.
- **Mobile access** -- Obsidian mobile + OneDrive is the escape hatch later.
- **Multi-user** -- Solo tool, no auth or sharing.
- **Proactive meeting briefings** -- Later. Memory should be queryable first, proactive second.

## Open Questions

1. **WorkIQ tenant consent:** Has your admin approved WorkIQ, or is that a prerequisite step?
2. **Vault location:** Confirm: should the Obsidian vault live INSIDE the GitHub repo, or separate (repo = code only, vault = OneDrive only)?
3. **Vault sync from CI:** Option A (vault in repo, git pull locally) vs Option B (CI writes to OneDrive via API)?
4. **Sensitive data exclusion:** Blocklist certain Teams channels or email senders from ingestion?
5. **MEMORY.md bootstrap:** Pre-populate with current projects, goals, org context to give the system a head start?
6. **Token rotation:** Accept manual re-auth every 90 days, or build auto-rotation?
