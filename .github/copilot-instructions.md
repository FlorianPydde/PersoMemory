# PersoMemory Agent Instructions

PersoMemory is the generic setup for Florian's personal memory system. The repo defines how agents retrieve, write, consolidate, and maintain memory. The Obsidian vault stores the memory content.

## Runtime Skill

The runtime implementation of this workflow is the `persomemory` skill. Invoke it when handling personal memory recall, memory writes, WorkIQ daily intake, routing, dreaming, consolidation, or setup changes.

## MCP Servers

1. **WorkIQ** (`workiq`): Queries Microsoft 365 data such as Teams chats, emails, calendar, meeting context, and call transcripts. Use for daily intake and M365 reconstruction only.
2. **Work IQ Teams** (`workiq-teams`): Sends or manages Teams chats and channel messages. Use only when the user explicitly asks to send, edit, or manage Teams content.
3. **MCPVault** (`mcpvault`): Reads and writes Markdown notes in the Obsidian vault. Use for deterministic file operations.
4. **Smart Connections** (`smart-connections`): Semantic retrieval over the vault using local Obsidian Smart Connections embeddings. Use for discovery when exact note paths are unknown.

## Retrieval Strategy

| Need | Tool | Why |
|------|------|-----|
| Read or write a specific note by path | MCPVault | Direct file access |
| List files in a memory folder | MCPVault | Exact inventory |
| Find notes related to an unknown topic | Smart Connections search | Retrieval by topic |
| Find notes similar to a known note | Smart Connections similar notes | Semantic neighborhood |
| Reconstruct a day from M365 | WorkIQ | Source data lives outside the vault |
| Send a Teams chat or channel message | Work IQ Teams | Official Teams MCP exposes message write tools |

**Key rule:** WorkIQ output is not durable memory until it is summarized and written into the vault.

## Memory Vault Structure

```text
vault/
  MEMORY.md                         # Durable self model and stable context only
  DREAMS.md                         # Consolidation diary and promotion log
  memory/
    active/now.md                   # Current priorities and live context
    commitments/open-loops.md       # Follow ups, promises, obligations
    daily/YYYY-MM-DD.md             # Episodic daily intake and evidence
    daily/TEMPLATE.md               # Daily intake schema
    projects/{project-name}.md      # Durable project knowledge
    people/{person-name}.md         # Durable relationship context
    decisions/{decision-slug}.md    # Durable decisions and revisit triggers
    career/goals.md                 # Goals and aspirations
    career/accomplishments.md       # Track record and outcomes
    career/feedback.md              # Feedback received
    patterns/*.md                   # Reusable heuristics and frameworks
    toolkits/                       # Reusable prompts, checklists, workshops, assets
```

## Session Start Behavior

At the start of a meaningful session:

1. Read `MEMORY.md` for durable self model, working style, decision frameworks, and stable people context.
2. Read `memory/active/now.md` for current priorities, active project status, and short lived context.
3. Read `memory/commitments/open-loops.md` for active follow ups and obligations.
4. Use Smart Connections or MCPVault search only when the user asks about a specific topic that needs deeper context.
5. Use daily notes only as episodic evidence, not as primary memory.

Do not load the full vault by default. Retrieval should be selective.

## Daily Intake Workflow

When the user asks for a daily summary, daily memory update, WorkIQ sweep, or similar:

1. Query WorkIQ for the requested date.
2. Summarize into `memory/daily/YYYY-MM-DD.md` using `memory/daily/TEMPLATE.md`.
3. Capture only these categories: state changes, decisions, commitments, people signals, evidence of impact, reusable assets, emerging patterns, promotion candidates, and source.
4. Update `memory/commitments/open-loops.md` for new or closed obligations.
5. Update `memory/active/now.md` only when current priorities or active project status materially change.
6. Do not promote daily facts into durable memory unless they are repeated, identity shaping, relationship shaping, strategy changing, career relevant, or reusable.

## Daily Note Ontology

Daily notes are relevant as intake and evidence. They are not long term memory.

Use this schema:

```markdown
# YYYY-MM-DD

## State Changes

## Decisions Made

## Commitments and Open Loops

## People Signals

## Evidence of Impact

## Reusable Assets

## Emerging Patterns

## Promotion Candidates

## Source
```

Skip sections that have nothing to report. Do not store raw email, raw chat, or raw transcript detail.

## Durable Memory Update Workflow

Route durable facts to the right layer:

| Target | What belongs there | Gate |
|--------|--------------------|------|
| `MEMORY.md` | Durable identity, working style, stable decision frameworks | High confidence, stable over time |
| `memory/active/now.md` | Current status, live priorities, short lived context | Materially useful now |
| `memory/commitments/open-loops.md` | Follow ups, promises, obligations | Still open or recently closed |
| `memory/projects/*.md` | Structural project knowledge, not transient status | Project relevance |
| `memory/people/*.md` | Durable relationship and working style signals | Relationship durability |
| `memory/patterns/*.md` | Repeated heuristics and reusable frameworks | Repeated or strongly generalizable |
| `memory/decisions/*.md` | Decisions that change future behavior | Rationale and revisit trigger known |
| `memory/toolkits/` | Prompts, checklists, playbooks, workshop formats | Used 2+ times or clearly reusable |
| `memory/career/` | Accomplishments, feedback, goals, growth evidence | Career narrative value |
| `DREAMS.md` | Consolidation candidates and promotion record | Weekly or manual consolidation |

## Dreaming / Consolidation Workflow

Dreaming promotes short term daily notes into durable long term memory.

1. Read daily notes since the last consolidation date in `DREAMS.md`.
2. Extract promotion candidates by target: memory, projects, people, patterns, decisions, career, and toolkits.
3. Score candidates by frequency, durability, actionability, relevance, and reuse potential.
4. Write candidates and promotions into `DREAMS.md`.
5. Ask before modifying `MEMORY.md`.
6. Update project, people, pattern, decision, toolkit, and career notes when the signal is strong enough.
7. Never delete daily notes. They are evidence.

## Hooks Position

Hooks are optional orchestration aids, not the memory system.

GitHub Copilot CLI hooks are loaded from `.github/hooks/*.json` in the current repository. That means hooks are repository scoped. Use them only when a repo should actively influence Copilot sessions run from that repo.

For generic memory behavior, prefer global Copilot instructions and MCP configuration. If hooks are used, keep them in this repo as documented templates or as PersoMemory-specific automation, not scattered across unrelated work repos.

## Memory Hygiene Rules

1. Do not store volatile account names, opportunity names, or deal owner names as durable memory unless explicitly requested.
2. Do not let `MEMORY.md` accumulate current status. Move live status to `memory/active/now.md`.
3. Do not bury obligations in daily notes. Mirror them into `memory/commitments/open-loops.md`.
4. Do not retrieve daily notes by default. Retrieve them only when evidence, chronology, or source detail matters.
5. Prefer promotion through `DREAMS.md` when a signal appears across multiple days.
6. Never store credentials, tokens, or secrets.
7. Always preserve source attribution.
