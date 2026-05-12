# Session Naming

At the start of every new session, suggest renaming the session based on the context:

- If inside a **git repository**, use: `proj:<repo-name>` (e.g., `proj:my-api`)
- If in a **specific directory** but not a git repo, use: `dir:<directory-name>` (e.g., `dir:ProjectArchive`)
- If the task is **general, random, or not tied to a specific project/directory**, use: `misc`

Propose the name early in the conversation and offer to run `/rename <name>`.

# Conventions
- Never use dashes (-) unless required in code files. 
- Never use emojis

# Personal Memory Skill

When the user asks about personal memory, WorkIQ daily sweeps, memory writes, recall from the Obsidian vault, active context, commitments, dreaming, consolidation, or the PersoMemory setup, invoke the `persomemory` skill before acting.

# Personal Memory System

You have access to a personal memory system via the `mcpvault` MCP server and semantic retrieval via the `smart-connections` MCP server. This is an Obsidian vault containing accumulated knowledge from past work.

## Vault Location

The vault is at: `/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

## MCP Tool Roles

1. Use `mcpvault` for deterministic file operations: list directories, read exact notes, create notes, and update notes.
2. Use `smart-connections` for semantic retrieval when the user asks about a topic, pattern, project, person, or prior discussion and exact filenames are unknown.
3. Use `workiq` only for M365 backed daily intake, meeting, email, and calendar reconstruction. Do not treat WorkIQ output as durable memory until it is written into the vault.

## Session Start Memory Loading

At the start of a meaningful session, load memory in this order:

1. Read `MEMORY.md` for durable self model, working style, decision frameworks, and stable people context.
2. Read `memory/active/now.md` for current priorities, active project status, and short lived context.
3. Read `memory/commitments/open-loops.md` for active follow ups and obligations.
4. Use `smart-connections` or `mcpvault` search only if the user asks about a specific topic that needs deeper context.
5. Use daily notes only as episodic evidence, not as primary memory.

## Daily Intake Workflow

When the user asks for a daily summary, daily memory update, or WorkIQ sweep:

1. Query WorkIQ for the relevant day.
2. Write or update `memory/daily/YYYY-MM-DD.md` using `memory/daily/TEMPLATE.md`.
3. Capture only state changes, decisions, commitments, people signals, evidence of impact, reusable assets, emerging patterns, promotion candidates, and source.
4. Update `memory/commitments/open-loops.md` for new or closed obligations.
5. Update `memory/active/now.md` only when current priorities or active project status materially change.
6. Do not promote daily facts into `MEMORY.md`, `projects`, `people`, `patterns`, `decisions`, `toolkits`, or `career` unless they are repeated, identity shaping, relationship shaping, strategy changing, career relevant, or reusable.

## Durable Memory Update Workflow

When a conversation creates durable memory:

1. Store volatile facts in daily notes or active memory.
2. Store open loops in `memory/commitments/open-loops.md`.
3. Store structural project knowledge in `memory/projects/{name}.md`.
4. Store durable relationship signals in `memory/people/{name}.md`.
5. Store recurring heuristics in `memory/patterns/*.md`.
6. Store durable decisions in `memory/decisions/*.md`.
7. Store reusable prompts, checklists, playbooks, and workshop formats in `memory/toolkits/`.
8. Store feedback, accomplishments, and growth evidence in `memory/career/`.
9. Update `DREAMS.md` during consolidation, not for every raw daily fact.

## Key Files

1. `MEMORY.md`: top level durable memory.
2. `memory/active/now.md`: active context and current priorities.
3. `memory/commitments/open-loops.md`: open commitments and closed recent loops.
4. `memory/daily/YYYY-MM-DD.md`: daily episodic intake.
5. `memory/daily/TEMPLATE.md`: daily note schema.
6. `DREAMS.md`: consolidation diary and promotion log.
7. `memory/projects/{name}.md`: project knowledge.
8. `memory/people/{name}.md`: relationship context.
9. `memory/patterns/*.md`: reusable heuristics and frameworks.
10. `memory/decisions/*.md`: durable decisions and revisit triggers.
11. `memory/toolkits/`: reusable working assets.
12. `memory/career/`: feedback, accomplishments, and goals.

## Memory Hygiene Rules

1. Do not store volatile account names, opportunity names, or deal owner names as durable memory unless the user explicitly asks. Store process and schema knowledge instead.
2. Do not let `MEMORY.md` accumulate current status. Move live status to `memory/active/now.md`.
3. Do not bury obligations in daily notes. Mirror them into `memory/commitments/open-loops.md`.
4. Do not retrieve daily notes by default. Retrieve daily notes only when evidence, chronology, or source detail matters.
5. Prefer promotion through `DREAMS.md` when a signal has appeared across multiple days.
