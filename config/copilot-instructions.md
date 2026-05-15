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

## Retrieval Order

When answering a question about personal memory, use this exact order:

1. **Direct file lookup**: if the exact path is known, read it. Example: `memory/projects/otp-bank-agentic.md` for a question about OTP.
2. **Explicit linked notes**: follow frontmatter `projects`, `people`, `patterns`, `decisions` wikilinks from the anchor note to discover related context.
3. **Property search**: search for notes with matching `type`, `status`, `domains`, or `impact-areas` values.
4. **Semantic search via Smart Connections**: for conceptual questions where the exact filename is unknown.
5. **Daily notes as evidence**: only when you need chronological evidence, source detail, or a specific date range.

Do NOT load daily notes as the first retrieval step.

## Session Start Memory Loading

At the start of a meaningful session, load memory in this order:

1. Read `MEMORY.md` for durable self model, working style, decision frameworks, and stable people context.
2. Read `memory/active/now.md` for current priorities, active project status, and short lived context.
3. Read `memory/commitments/open-loops.md` for active follow ups and obligations.
4. Use `smart-connections` or `mcpvault` search only if the user asks about a specific topic that needs deeper context.
5. Use daily notes only as episodic evidence, not as primary memory.

## Graph-Writing Contract

Every durable note you create or update must include:

1. **Frontmatter** with `type` and all applicable relationship fields.
2. **Inline wikilinks** in the prose body where referencing other notes.

Both are required. Frontmatter makes the note machine-readable. Inline wikilinks make relationships traversable in Obsidian.

### Frontmatter examples

**Daily note** (include projects and people that are clearly mentioned in the body):
```yaml
---
type: daily
date: 2026-05-04
projects:
  - "[[projects/otp-bank-agentic]]"
people:
  - "[[people/george-theologou]]"
decisions: []
impact-areas: []
---
```

**Project note** (include all relationship types relevant to the project):
```yaml
---
type: project
status: active
domains:
  - banking
  - agentic-ai
technologies:
  - Azure OpenAI
  - Cosmos DB
people:
  - "[[people/george-theologou]]"
  - "[[people/harish-chandran]]"
decisions:
  - "[[decisions/otp-storage-architecture]]"
patterns:
  - "[[patterns/agentic-ai-delivery]]"
toolkits: []
related:
  - "[[projects/premier-league]]"
tags:
  - regulated-fsi
---
```

**Career evidence note** (highest signal, Connect/promotion-threshold only):
```yaml
---
type: career-evidence
date: 2026-05-04
impact-areas:
  - "AI Design Wins / Pre-sales"
  - "High Quality Delivery"
so-what: "OTP Bank SRM Stage 3 ECIF passed, unlocking commercial deal and validating the regulated FSI agentic model."
source-type: meeting-outcome
observers:
  - "[[people/george-theologou]]"
projects:
  - "[[projects/otp-bank-agentic]]"
people:
  - "[[people/harish-chandran]]"
patterns:
  - "[[patterns/agentic-ai-delivery]]"
decisions:
  - "[[decisions/otp-storage-architecture]]"
tags: []
---
```

### Inline wikilink rule

After writing frontmatter, also embed wikilinks in prose:
```markdown
This decision was shaped by [[people/george-theologou]] during Stage 3.
The approach generalizes as [[patterns/agentic-ai-delivery]].
See [[decisions/otp-storage-architecture]] for full rationale.
Related work: [[projects/premier-league]].
```

### Wikilink path convention

`[[folder/slug]]` using lowercase hyphenated slugs matching the filename without `.md`.

| Note type | Wikilink prefix |
|---|---|
| project | `[[projects/slug]]` |
| person | `[[people/slug]]` |
| pattern | `[[patterns/slug]]` |
| decision | `[[decisions/slug]]` |
| toolkit | `[[toolkits/slug]]` |
| career evidence | `[[career/evidence/slug]]` |

## Daily Intake Workflow

When the user asks for a daily summary, daily memory update, or WorkIQ sweep:

1. Query WorkIQ for the relevant day.
2. Write or update `memory/daily/YYYY-MM-DD.md` using `memory/daily/TEMPLATE.md`.
3. Populate `projects` and `people` frontmatter with wikilinks to notes that exist in the vault.
4. Capture only state changes, decisions, commitments, people signals, evidence of impact, reusable assets, emerging patterns, promotion candidates, and source.
5. Update `memory/commitments/open-loops.md` for new or closed obligations.
6. Update `memory/active/now.md` only when current priorities or active project status materially change.
7. Do not promote daily facts into `MEMORY.md`, `projects`, `people`, `patterns`, `decisions`, `toolkits`, or `career` unless they are repeated, identity shaping, relationship shaping, strategy changing, career relevant, or reusable.

During any WorkIQ sweep, run three separate WorkIQ evidence calls before summarizing or writing:

1. **Broad Evidence Scan**: reconstruct daily context, project movement, risks, people signals, reusable assets, and surprise items.
2. **Action Item Audit**: inspect meeting tasks, transcript action items, Teams asks, email asks, and shared-file comments for every concrete deliverable. Mirror still-open obligations into `memory/commitments/open-loops.md`.
3. **Direction Setting Audit**: inspect manager, mentor, leadership, and career conversations for future role direction, goals, exposure, skills, or behavior changes. Separate this from recognition or career evidence.

Merge and deduplicate the three evidence outputs before routing memory. If one WorkIQ evidence call fails, continue with the other streams and write a Sweep Failures approval item.

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
9. Store atomic proof (Connect/promotion threshold) in `memory/career/evidence/`.
10. Update `DREAMS.md` during consolidation, not for every raw daily fact.

Manager or mentor guidance that changes the next 1-3 year direction belongs in `memory/career/feedback.md` or `memory/career/goals.md` through an approval-gated career direction update, not only in daily notes or career evidence candidates.

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
13. `memory/career/evidence/`: atomic career evidence notes (Connect/promotion threshold).
14. `memory/INDEX.md`: vault entry point.
15. `memory/PROJECTS.md`: project registry.

## Memory Hygiene Rules

1. Do not store volatile account names, opportunity names, or deal owner names as durable memory unless the user explicitly asks. Store process and schema knowledge instead.
2. Do not let `MEMORY.md` accumulate current status. Move live status to `memory/active/now.md`.
3. Do not bury obligations in daily notes. Mirror them into `memory/commitments/open-loops.md`.
4. Do not retrieve daily notes by default. Retrieve daily notes only when evidence, chronology, or source detail matters.
5. Prefer promotion through `DREAMS.md` when a signal has appeared across multiple days.
6. Always write frontmatter when creating or updating a durable note.
7. Always add inline wikilinks in prose when referencing another note by name.
8. Only create career evidence notes that meet the Connect/promotion/leadership threshold.

## Career Evidence Impact Taxonomy

When creating career evidence notes, use exactly these `impact-areas` labels from the manager evaluation rubric:

- `High Quality Delivery`
- `Customer Orientation`
- `AI Design Wins / Pre-sales`
- `Thought & Technical Leadership`
- `Microsoft Business Understanding and Management`
- `Growth Mindset & Problem Solving`
- `Diversity & Inclusion`
- `Security`

Each evidence note maps to one or more of these areas. The `so-what` field should be a sentence that could appear verbatim in Connect.
