---
name: persomemory
description: Operates Florian's personal memory system. Use when reading or writing personal memory, sweeping a day with WorkIQ, updating the Obsidian vault, routing daily notes into active memory or commitments, recalling prior project or people context, or running dreaming and consolidation.
---

# PersoMemory

## Purpose

Operate the personal memory system with discipline. MCP servers provide access. This skill provides the workflow, routing rules, promotion gates, and hygiene rules.

## Use This Skill When

Use this skill immediately when the user asks to:

1. Recall prior context from personal memory.
2. Summarize or sweep a day using WorkIQ.
3. Write something to memory.
4. Update `MEMORY.md`, active memory, commitments, project notes, people notes, patterns, decisions, career notes, or toolkits.
5. Consolidate, dream, or promote daily notes.
6. Discuss or modify the memory ontology, retrieval flow, MCP setup, or PersoMemory repo.

## Memory Store

The memory content lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

The PersoMemory repo is the source of truth for setup, skills, docs, templates, and recovery artifacts. It is not the active memory store.

## MCP Tool Roles

1. WorkIQ retrieves Microsoft 365 evidence from Teams, email, meetings, calendar, and transcripts.
2. MCPVault performs deterministic reads and writes in the Obsidian vault.
3. Smart Connections retrieves semantically related notes when exact paths are unknown.

WorkIQ output is evidence, not durable memory. MCPVault writes files, but does not decide what should be remembered. Smart Connections retrieves context, but does not promote memory.

## Session Start Loading

At the start of a meaningful session, load only the minimum useful context:

1. Read `MEMORY.md` for durable self model and stable working style.
2. Read `memory/active/now.md` for current priorities and short lived context.
3. Read `memory/commitments/open-loops.md` for active obligations.
4. Search only when the user mentions a specific project, person, topic, or prior discussion.
5. Do not load daily notes by default. Daily notes are evidence, not primary memory.

## Three Memory Processes

### 1. Live Capture

Trigger: a meaningful live conversation, or the user says "write this to memory".

Purpose: capture high signal facts from the current interaction.

Workflow:

1. Identify the smallest useful memory signal.
2. Write to today's daily note using the daily note schema.
3. Route operational changes immediately:
   1. Current priorities or live project status go to `memory/active/now.md`.
   2. Promises, follow ups, and obligations go to `memory/commitments/open-loops.md`.
   3. Clear durable decisions may get a decision note.
4. Do not update `MEMORY.md` unless the user explicitly asks or the fact is already proven durable.
5. Preserve source attribution as "Conversation with agent".

### 2. Daily WorkIQ Intake

Trigger: the user says "sweep my day", "summarize my day into memory", or asks for a daily memory update.

Purpose: reconstruct the day from Microsoft 365 evidence and merge useful signal into the daily note.

Workflow:

1. Query WorkIQ for the requested date.
2. Extract only high signal content:
   1. State changes.
   2. Decisions made.
   3. Commitments and open loops.
   4. People signals.
   5. Evidence of impact.
   6. Reusable assets.
   7. Emerging patterns.
   8. Promotion candidates.
3. Write or merge `memory/daily/YYYY-MM-DD.md` using `memory/daily/TEMPLATE.md`.
4. Deduplicate against existing live capture notes.
5. Update `memory/commitments/open-loops.md` for open or closed obligations.
6. Update `memory/active/now.md` only for material current context changes.
7. Add promotion candidates, but do not blindly promote into durable memory.
8. Preserve source attribution as "Automated sweep via WorkIQ" or "Manual WorkIQ sweep".

### 3. Dreaming and Consolidation

Trigger: the user says "dream", "consolidate", "consolidate this week", or asks to promote daily notes.

Purpose: promote repeated or durable signals into long term memory.

Workflow:

1. Read `DREAMS.md` to find the last consolidation date.
2. Read daily notes since that date.
3. Use Smart Connections when useful to discover related project, people, pattern, or toolkit notes.
4. Score candidates by frequency, durability, actionability, relevance, and reuse potential.
5. Route durable signals:
   1. Identity and stable operating truths go to `MEMORY.md` only with user approval.
   2. Project knowledge goes to `memory/projects/`.
   3. Relationship signals go to `memory/people/`.
   4. Heuristics go to `memory/patterns/`.
   5. Durable decisions go to `memory/decisions/`.
   6. Reusable assets go to `memory/toolkits/`.
   7. Career evidence goes to `memory/career/`.
6. Record the reasoning and outcome in `DREAMS.md`.
7. Never delete daily notes.

## Routing Rules

Route daily note sections as follows:

| Daily section | Target | Gate |
| --- | --- | --- |
| State Changes | `memory/active/now.md` | Changes current priorities or active context |
| Commitments and Open Loops | `memory/commitments/open-loops.md` | Still open or recently closed |
| Decisions Made | `memory/decisions/{slug}.md` | Changes future behavior and has rationale |
| People Signals | `memory/people/{person}.md` | Durable working style, ownership, preference, or influence |
| Evidence of Impact | `memory/career/accomplishments.md` or `memory/career/feedback.md` | Supports career narrative or recognized outcome |
| Reusable Assets | `memory/toolkits/` | Used 2+ times or clearly saves future effort |
| Emerging Patterns | `memory/patterns/` | Repeated or strongly generalizable |
| Promotion Candidates | `DREAMS.md` | Needs review before durable promotion |
| Stable identity or operating truth | `MEMORY.md` | Repeated evidence or explicit user approval |

Route immediately only when the target is operational. Promote later when the target is durable.

Operational targets are daily notes, active memory, and commitments. Durable targets are `MEMORY.md`, projects, people, patterns, decisions, career, and toolkits.

## Daily Note Schema

Use this schema. Skip empty sections.

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

## Keep Versus Discard

Keep facts that change future action, judgment, or retrieval.

Keep:

1. Decisions and rationale.
2. Open loops and closures.
3. Project direction changes, risks, and status shifts.
4. Durable people signals.
5. Evidence of impact.
6. Reusable prompts, playbooks, checklists, and workshop formats.
7. Repeated patterns and operating heuristics.
8. Structural knowledge about systems and processes.

Discard:

1. Raw email, chat, or transcript text.
2. Scheduling noise.
3. Duplicate facts.
4. One off facts with no future consequence.
5. Volatile account names, opportunity names, and deal owner names unless explicitly requested.
6. Credentials, tokens, secrets, or sensitive raw data.

## Source Attribution

Every memory write needs a source. Use simple labels:

1. Conversation with agent.
2. Automated sweep via WorkIQ.
3. Manual WorkIQ sweep.
4. User supplied note.
5. Repository artifact.

## Safety Rules

1. Ask before modifying `MEMORY.md` unless the user directly requested it.
2. Never store secrets.
3. Never overwrite existing memory without preserving useful existing content.
4. Do not use daily notes as primary retrieval memory unless chronology or evidence matters.
5. Do not promote volatile sales data or deal-specific names into durable memory.
6. Prefer concise, high signal notes over exhaustive records.
