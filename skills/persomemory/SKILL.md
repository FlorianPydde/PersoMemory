---
name: persomemory
description: Core PersoMemory operations for Florian's personal memory system. Use for recalling prior context, writing a memory, updating active context or commitments, routing memory-worthy facts, or deciding what should be remembered or forgotten.
---

# PersoMemory Core

## Purpose

Operate core personal memory tasks with discipline. This skill handles retrieval, live capture, write routing, approval gates, graph-writing rules, and safety.

Workflow-specific tasks have their own skills:

1. Use `persomemory-morning-brief` for morning briefs and morning sweeps.
2. Use `persomemory-daily-sweep` for daily or end-of-day WorkIQ sweeps.
3. Use `persomemory-consolidation` for dreaming, weekly consolidation, and durable promotions.

Do not use this skill for PersoMemory repo changes, MCP setup changes, or ontology refactoring unless the task is also asking to operate memory. Those are ordinary engineering or documentation tasks.

## Use This Skill When

Use this skill immediately when the user asks to:

1. Recall prior context from personal memory.
2. Write something to memory.
3. Update `MEMORY.md`, active memory, commitments, project notes, people notes, patterns, decisions, career notes, or toolkits.
4. Capture memory from the current conversation or pending Copilot conversation queue.
5. Decide whether something should be remembered, discarded, routed, or approval-gated.

## Memory Store

The memory content lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

The PersoMemory repo is the recovery source for setup artifacts. It is not the active memory store.

## MCP Tool Roles

1. WorkIQ retrieves Microsoft 365 evidence from Teams, email, meetings, calendar, and transcripts.
2. Work IQ Teams sends or manages Teams chats and channel messages when Florian explicitly asks for that action.
3. MCPVault performs deterministic reads and writes in the Obsidian vault.
4. Smart Connections retrieves semantically related notes when exact paths are unknown.

WorkIQ output is evidence, not durable memory. Work IQ Teams is an action surface, not memory evidence. MCPVault writes files, but does not decide what should be remembered. Smart Connections retrieves context, but does not promote memory.

## Execution Rule

When PersoMemory work is requested from an interactive Copilot session that already has MCP tools available, run the workflow in the current session. Do not delegate to a nested subagent for WorkIQ, MCPVault, Smart Connections, or persomemory-lifecycle work because nested delegated agents may not inherit those MCP tools. Use `persomemory-agent` only as the top-level selected agent, for example through `copilot --agent persomemory-agent`, or when the session is already running as that agent.

## Retrieval Priority Order

When answering a memory question, use this exact order:

1. Direct file lookup: if the exact path is known, read it via MCPVault. Example: read `memory/projects/otp-bank-agentic.md` when the user asks about OTP.
2. Explicit linked notes: follow frontmatter `projects`, `people`, `patterns`, and `decisions` wikilinks from the anchor note.
3. Property-based search: search for notes matching `type: project`, `status: active`, or a specific `impact-areas` value.
4. Semantic search: use Smart Connections when the topic is conceptual or the exact filename is unknown.
5. Daily notes as evidence: retrieve daily notes only when chronology, source detail, or a specific date matters.

Never load daily notes as the first retrieval step unless the question is specifically about what happened on a date.

## Session Start Loading

At the start of a meaningful memory session, load only the minimum useful context:

1. Read `MEMORY.md` for durable self model and stable working style.
2. Read `memory/active/now.md` for current priorities and short-lived context.
3. Read `memory/commitments/open-loops.md` for active obligations.
4. Search only when the user mentions a specific project, person, topic, or prior discussion.
5. Do not load daily notes by default. Daily notes are evidence, not primary memory.

## Live Capture

Trigger: a meaningful live conversation, or the user says "write this to memory".

Workflow:

1. Identify the smallest useful memory signal.
2. Write volatile evidence to today's daily note using the daily note schema.
3. Include frontmatter with `projects` and `people` links for any project or person clearly mentioned.
4. Route operational changes immediately:
   1. Current priorities or live project status go to `memory/active/now.md`.
   2. Promises, follow ups, and obligations go to `memory/commitments/open-loops.md`.
   3. Clear durable decisions may get a decision note.
5. Do not update `MEMORY.md` unless the user explicitly asks or the fact is already proven durable.
6. Preserve source attribution as `Conversation with agent`.

## Copilot Conversation Capture

Trigger: the user says "sweep this Copilot session", "review pending conversation queue", or asks to capture memory from Copilot conversations.

Workflow:

1. Read pointer-only queue entries from `~/.local/share/persomemory/session-reviews/`.
2. Read referenced transcripts when available.
3. Skip entries whose transcript is missing, empty, or `not captured`.
4. Extract only signals that change future action, judgment, or retrieval.
5. Deduplicate against current vault state before writing.
6. Write concise daily note entries or operational updates only when the signal is still current.
7. Ask before durable promotions, project closures, ambiguous commitment closures, career evidence, or `MEMORY.md` edits.
8. Mark local queue entries as reviewed or superseded after processing when permissions allow.
9. Never write raw transcripts into the vault.

## Graph-Writing Contract

Every durable note write must include frontmatter and inline wikilinks. This is not optional metadata; it builds the traversable graph.

### Frontmatter Rules

Always include `type` matching the note type. Include relationship fields that apply. Leave relationship arrays empty (`[]`) rather than omitting them when a field is relevant.

Project notes include: `type`, `status`, `updated`, `domains`, `technologies`, `people`, `decisions`, `patterns`, `toolkits`, `related`, and `tags`. Add `review-by` when the project is winding down or needs a scheduled check.

Person notes include: `type`, `projects`, `decisions`, `patterns`, and `tags`.

Career evidence notes include: `type`, `date`, `impact-areas`, `so-what`, `source-type`, `observers`, `projects`, `people`, `patterns`, and `decisions`.

Daily notes include: `type`, `date`, and any `projects` or `people` clearly mentioned in the note body.

Decision notes include: `type`, `date`, `status`, `projects`, `people`, `patterns`, `supersedes`, `superseded-by`, and `tags`.

### Inline Wikilink Rules

After writing frontmatter, embed wikilinks in prose where they add context. Use `[[folder/slug]]` syntax. Wikilink paths use lowercase hyphenated slugs matching the filename without `.md`.

Examples:

```markdown
This architecture was shaped by [[people/george-theologou]] during the Stage 3 review.
The pattern generalizes from [[projects/otp-bank-agentic]] and [[projects/premier-league]].
See [[decisions/otp-storage-architecture]] for the full rationale.
This insight belongs to [[patterns/agentic-ai-delivery]].
```

## Routing Rules

Route daily note sections as follows:

| Daily section | Target | Gate |
| --- | --- | --- |
| State Changes | `memory/active/now.md` | Changes current priorities or active context |
| Commitments and Open Loops | `memory/commitments/open-loops.md` | Still open or recently closed |
| Decisions Made | `memory/decisions/{slug}.md` | Changes future behavior and has rationale |
| People Signals | `memory/people/{person}.md` | Durable working style, ownership, preference, or influence |
| Evidence of Impact | `memory/career/accomplishments.md` or `memory/career/evidence/` | Summary goes in accomplishments; atomic proof in evidence if Connect-threshold |
| Career Direction and Feedback | `memory/career/feedback.md` or `memory/career/goals.md` | Manager or mentor guidance that changes role direction, goals, or 1-3 year trajectory; approval-gated unless explicitly requested |
| Reusable Assets | `memory/toolkits/` | Used 2+ times or clearly saves future effort |
| Emerging Patterns | `memory/patterns/` | Repeated or strongly generalizable |
| Promotion Candidates | `DREAMS.md` | Needs review before durable promotion |
| Stable identity or operating truth | `MEMORY.md` | Repeated evidence or explicit user approval |

Route immediately only when the target is operational. Promote later when the target is durable.

## Daily Note Schema

Use this schema. Skip empty sections.

```markdown
---
type: daily
date: YYYY-MM-DD
projects:
  - "[[projects/slug]]"
people:
  - "[[people/slug]]"
decisions: []
impact-areas: []
---

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
9. Direction-setting guidance from managers, mentors, leaders, or customers that changes future goals, positioning, role scope, or behavior.

Discard:

1. Raw email, chat, or transcript text.
2. Scheduling noise.
3. Duplicate facts.
4. One-off facts with no future consequence.
5. Volatile account names, opportunity names, and deal owner names unless explicitly requested.
6. Credentials, tokens, secrets, or sensitive raw data.

## Source Attribution

Every memory write needs a source. Use simple labels:

1. `Conversation with agent`.
2. `Automated sweep via WorkIQ`.
3. `Manual WorkIQ sweep`.
4. `User supplied note`.
5. `Repository artifact`.

## Approval Gates

Ask before:

1. Editing `MEMORY.md` unless the user directly requested it.
2. Creating career evidence.
3. Promoting durable project, people, pattern, decision, or toolkit notes.
4. Closing a project.
5. Closing an ambiguous commitment.
6. Resolving conflicting evidence.
7. Capturing potentially sensitive content.

Approval inbox item statuses are `pending`, `approved`, `rejected`, `deferred`, and `superseded`.

Approval inbox sections are:

1. Project Closures.
2. Commitment Closures.
3. Durable Promotions.
4. Career Evidence Candidates.
5. Career Direction and Feedback Updates.
6. Sensitive or Ambiguous Items.
7. Discard Recommendations.
8. Sweep Failures.

## Safety Rules

1. Never store secrets.
2. Never overwrite existing memory without preserving useful existing content.
3. Do not use daily notes as primary retrieval memory unless chronology or evidence matters.
4. Do not promote volatile sales data or deal-specific names into durable memory.
5. Prefer concise, high-signal notes over exhaustive records.
6. Always write frontmatter when creating or updating a durable note.
7. Always add inline wikilinks in prose when referencing another note.
