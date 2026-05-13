---
name: persomemory
description: Operates Florian's personal memory system. Use when reading or writing personal memory, sweeping a day with WorkIQ, updating the Obsidian vault, routing daily notes into active memory or commitments, recalling prior project or people context, or running dreaming and consolidation.
---

# PersoMemory

## Purpose

Operate the personal memory system with discipline. MCP servers provide access. This skill provides the workflow, routing rules, promotion gates, hygiene rules, and graph-writing contract.

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

## Retrieval Priority Order

When answering a memory question, use this exact order:

1. **Direct file lookup**: if the exact path is known, read it via MCPVault. Example: read `memory/projects/otp-bank-agentic.md` when user asks about OTP.
2. **Explicit linked notes**: follow frontmatter `projects`, `people`, `patterns`, `decisions` wikilinks from the anchor note.
3. **Property-based search**: search for notes matching `type: project`, `status: active`, or a specific `impact-areas` value.
4. **Semantic search**: use Smart Connections when the topic is conceptual or the exact filename is unknown.
5. **Daily notes as evidence**: retrieve daily notes only when you need chronological evidence, source detail, or a specific date.

Never load daily notes as the first retrieval step unless the question is specifically about what happened on a date.

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
2. Write to today's daily note using the daily note schema. Include frontmatter with `projects` and `people` links for any project or person clearly mentioned.
3. Route operational changes immediately:
   1. Current priorities or live project status go to `memory/active/now.md`.
   2. Promises, follow ups, and obligations go to `memory/commitments/open-loops.md`.
   3. Clear durable decisions may get a decision note.
4. Do not update `MEMORY.md` unless the user explicitly asks or the fact is already proven durable.
5. Preserve source attribution as "Conversation with agent".

### 2. Daily Evening Intake

Trigger: the user says "sweep my day", "summarize my day into memory", or asks for a daily memory update.

Purpose: extract strategic signals from Microsoft 365 evidence and Copilot conversation evidence, then route them into the memory graph.

WorkIQ retrieves evidence. PersoMemory decides meaning. Do not let WorkIQ judge career impact, Connect grade, or memory routing.

Copilot conversations are a second evidence stream. The hook queue stores only pointers to Copilot transcripts under `~/.local/share/persomemory`; it is not memory and must not be treated as truth.

Workflow:

**Phase 1: Memory priming**

Before querying WorkIQ, load the active context needed to construct an informed query:

1. Read `memory/active/now.md` — extract active projects, key people, current priorities.
2. Read `memory/commitments/open-loops.md` — extract open commitments and pending follow ups.
3. Skim `memory/PROJECTS.md` — note active project slugs and names for wikilink matching.

**Phase 2: Construct and run the WorkIQ query**

Use the template below. Inject the memory context from Phase 1 into the [INJECT] placeholders before sending.

```
Analyze the Microsoft 365 activity around Florian for [DATE].

Look across calendar, meetings, transcripts, Teams chats, emails, shared files, and any visible collaboration signals.

Do not produce a chronological activity log. Do not judge career impact or recommend memory routing. Return evidence and context only.

Known context for today's sweep:
- Active projects: [INJECT active project names from now.md]
- Key people: [INJECT key people from now.md]
- Open commitments: [INJECT open loops from open-loops.md]
- Current priorities: [INJECT priorities from now.md]

Identify the most important work signals under these lenses:

1. Top signals
What were the 3 to 5 most consequential things that happened today? For each: what happened, why it matters, source, people involved.

2. Important interactions
Which conversations, meetings, chats, or emails changed context, created alignment, exposed risk, or required follow up?

3. Asks and commitments
What was asked of Florian, what did Florian commit to, what dependencies or follow ups were created or closed?

4. Leadership, manager, customer, and partner signals
Did any manager, senior stakeholder, customer, partner, or influential colleague signal priority, concern, recognition, escalation, or direction?

5. Project and workstream movement
Which projects or workstreams moved forward, changed direction, got blocked, or gained new evidence of progress or risk?

6. Risks and weak signals
What could become a problem later: unclear ownership, scope creep, technical debt, delivery risk, stakeholder misalignment, regulatory or compliance risk?

7. Reusable knowledge
Were any assets, prompts, decks, architectures, demos, workflows, patterns, or lessons created or discussed that could be reused across projects or engagements?

8. Surprise detection
What happened today that was important but NOT covered by the known projects, people, or commitments listed above?

For each retained signal, return:
- Title (short)
- What happened
- So what (consequence or implication)
- Source type (meeting, email, teams chat, transcript, file shared)
- People involved
- Projects or topics
- Confidence (high, medium, low)

At the end, list items discarded as low value and why (scheduling noise, admin, duplicates, no future consequence).
```

**Phase 3: Evidence extraction**

WorkIQ returns structured signal candidates. Accept them as evidence, not decisions. Do not use WorkIQ's framing to classify career impact or memory priority — that judgment belongs to PersoMemory.

**Phase 4: Copilot conversation evidence**

Read pending conversation review pointers from:

```text
~/.local/share/persomemory/session-reviews/
```

For each relevant pointer:

1. Read the referenced transcript if available.
2. Extract only signals that change future action, judgment, or retrieval.
3. Deduplicate against the current daily note, active memory, open loops, project notes, and durable notes.
4. Discard implementation noise, tool logs, duplicates, stale claims, and transient discussion.
5. Never write raw transcripts to the vault.

**Phase 5: Memory routing**

1. Write or merge `memory/daily/YYYY-MM-DD.md` using `memory/daily/TEMPLATE.md`.
2. Populate frontmatter `projects` and `people` with wikilinks to existing notes based on what was mentioned.
3. Deduplicate against existing live capture content already in the daily note.
4. Update `memory/commitments/open-loops.md` for open or closed obligations.
5. Update `memory/active/now.md` only for material current context changes.
6. Flag promotion candidates in the daily note. Do not blindly promote into durable memory.
7. Preserve source attribution as "Automated sweep via WorkIQ" or "Manual WorkIQ sweep".
8. Mark processed local conversation queue entries as reviewed or superseded when permissions allow. If not, rely on deduplication and local retention cleanup.

The evening sweep should ask for input only at approval gates, not during routine capture.

When running unattended through `copilot -p`, do not ask. Write approval-gated decisions to `memory/inbox/approvals/YYYY-MM-DD.md` and leave them with status `pending`.

Ask before:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Promoting durable project, people, pattern, decision, or toolkit notes.
4. Closing a project.
5. Closing an ambiguous commitment.
6. Resolving conflicting evidence between WorkIQ, Copilot conversations, and existing vault state.
7. Capturing potentially sensitive content.

Approval inbox item statuses are `pending`, `approved`, `rejected`, `deferred`, and `superseded`.

Approval inbox sections:

1. Project Closures.
2. Commitment Closures.
3. Durable Promotions.
4. Career Evidence Candidates.
5. Sensitive or Ambiguous Items.
6. Discard Recommendations.
7. Sweep Failures.

**Phase 6: Lifecycle check**

After routing, call the `lifecycle_check` MCP tool (server: `persomemory-lifecycle`) to surface stale notes and lapsed commitments:

```
lifecycle_check(stale_days=14, loop_age_days=14)
```

Review the output and take action on any flagged items:
- `overdue`: a project note has passed its `review-by` date. Update status, extend review-by, or close the note.
- `stale`: an active or winding-down project has not been updated in 14+ days. Confirm still active or change status.
- `agedLoops`: an open commitment has an explicit date older than 14 days. Confirm still open, close it, or escalate.

Do not skip this step. A sweep that captures new evidence without clearing stale state leaves the vault gradually noisier.

### 3. Copilot Conversation Sweep

Trigger: the user says "sweep this Copilot session", "review pending conversation queue", or asks to capture memory from Copilot conversations.

Purpose: extract useful memory signals from Copilot CLI conversation transcripts.

Workflow:

1. Read pointer-only queue entries from `~/.local/share/persomemory/session-reviews/`.
2. Read referenced transcripts when available.
3. Apply the same keep-versus-discard gates used for WorkIQ.
4. Deduplicate against current vault state before writing.
5. Write concise daily note entries or operational updates only when the signal is still current.
6. Ask before durable promotions, project closures, ambiguous commitment closures, career evidence, or `MEMORY.md` edits.
7. Mark local queue entries as reviewed or superseded after processing when permissions allow.
8. Never write raw transcripts into the vault.

### 4. Dreaming and Consolidation

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
   8. Proof strong enough for Connect/promotion becomes an atomic note in `memory/career/evidence/`.
6. When writing or updating durable notes, always include frontmatter per the schema and add wikilinks in prose.
7. Record the reasoning and outcome in `DREAMS.md`.
8. Never delete daily notes.

## Graph-Writing Contract

Every durable note write must include frontmatter and inline wikilinks. This is not optional metadata — it builds the traversable graph.

### Frontmatter rules

Always include `type` matching the note type. Always include the relationship fields that apply. Leave relationship arrays empty (`[]`) rather than omitting them when a field is relevant to the note type.

**When creating a project note**, include: `type`, `status`, `updated`, `domains`, `technologies`, `people`, `decisions`, `patterns`, `toolkits`, `related`, `tags`. Add `review-by` when the project is winding down or needs a scheduled check.

Example:
```yaml
---
type: project
status: active
updated: 2026-05-13
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

**When creating a person note**, include: `type`, `projects`, `decisions`, `patterns`, `tags`.

Example:
```yaml
---
type: person
projects:
  - "[[projects/otp-bank-agentic]]"
decisions:
  - "[[decisions/otp-storage-architecture]]"
patterns:
  - "[[patterns/agentic-ai-delivery]]"
tags:
  - stakeholder
---
```

**When creating a career evidence note**, include: `type`, `date`, `impact-areas`, `so-what`, `source-type`, `observers`, `projects`, `people`, `patterns`, `decisions`.

Example:
```yaml
---
type: career-evidence
date: 2026-05-04
impact-areas:
  - "AI Design Wins / Pre-sales"
  - "High Quality Delivery"
so-what: "OTP Bank SRM Stage 3 ECIF passed, unlocking €X commercial deal and validating the regulated FSI agentic delivery model."
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

**When creating a daily note**, include `type`, `date`, and any `projects` or `people` clearly mentioned in the note body:

Example:
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

**When creating a decision note**, include: `type`, `date`, `status`, `projects`, `people`, `patterns`, `supersedes`, `superseded-by`:

Example:
```yaml
---
type: decision
date: 2026-03-16
status: active
projects:
  - "[[projects/otp-bank-agentic]]"
people:
  - "[[people/george-theologou]]"
patterns:
  - "[[patterns/agentic-ai-delivery]]"
supersedes: []
superseded-by: ""
tags: []
---
```

### Inline wikilink rules

After writing frontmatter, also embed wikilinks inside prose where they add context. Use `[[folder/slug]]` syntax.

Examples:
```markdown
This architecture was shaped by [[people/george-theologou]] during the Stage 3 review.
The pattern generalizes from [[projects/otp-bank-agentic]] and [[projects/premier-league]].
See [[decisions/otp-storage-architecture]] for the full rationale.
This insight belongs to [[patterns/agentic-ai-delivery]].
```

Wikilink folder/file paths use lower-case-hyphenated slugs matching the filename without `.md`.

### Career evidence capture threshold

Only create a standalone note in `memory/career/evidence/` when the evidence is strong enough for:
- A Connect impact statement
- A promotion case
- A leadership or thought leadership narrative

Ordinary delivery goes in project notes or daily notes, not in dedicated evidence files.

**`impact-areas` controlled vocabulary (use exact labels):**
- `High Quality Delivery`
- `Customer Orientation`
- `AI Design Wins / Pre-sales`
- `Thought & Technical Leadership`
- `Microsoft Business Understanding and Management`
- `Growth Mindset & Problem Solving`
- `Diversity & Inclusion`
- `Security`

**`source-type` controlled vocabulary:**
- `shipped-outcome` — working system, shipped feature, live demo
- `customer-testimonial` — direct positive signal from customer or partner
- `stakeholder-reaction` — notable reaction from internal stakeholder
- `manager-feedback` — explicit feedback from manager
- `peer-feedback` — explicit feedback from peer
- `meeting-outcome` — decision or agreement made in a meeting
- `email-recognition` — recognition in email or Teams

## Routing Rules

Route daily note sections as follows:

| Daily section | Target | Gate |
| --- | --- | --- |
| State Changes | `memory/active/now.md` | Changes current priorities or active context |
| Commitments and Open Loops | `memory/commitments/open-loops.md` | Still open or recently closed |
| Decisions Made | `memory/decisions/{slug}.md` | Changes future behavior and has rationale |
| People Signals | `memory/people/{person}.md` | Durable working style, ownership, preference, or influence |
| Evidence of Impact | `memory/career/accomplishments.md` or `memory/career/evidence/` | Summary goes in accomplishments; atomic proof in evidence if Connect-threshold |
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
7. Always write frontmatter when creating or updating a durable note.
8. Always add inline wikilinks in prose when referencing another note.

## Retrieval Scenarios

The following scenarios show how to use the retrieval priority order in practice.

### Scenario 1: Recall a person

Question: "What do I know about Harish Chandran?"

1. Direct file: read `memory/people/harish-chandran.md`.
2. Follow explicit links in frontmatter: `projects` → read `memory/projects/premier-league.md`.
3. Follow `decisions` in frontmatter: read `memory/decisions/pl-agent-flow-simplification.md`.
4. Optionally: use Smart Connections to find daily notes or evidence notes that reference him.
5. Do NOT load all daily notes first.

### Scenario 2: Find related projects by pattern or technology

Question: "What other projects use the human-in-the-loop pattern?"

1. Read `memory/patterns/agentic-ai-delivery.md`.
2. Follow `projects` frontmatter: OTP, Premier League, PAFN, CaixaBank.
3. Alternatively: use Smart Connections with query "human-in-the-loop regulated agentic".
4. Do NOT rely on semantic search alone when the pattern note explicitly lists source projects.

### Scenario 3: Trace impact to career evidence

Question: "What impact evidence do I have for Connect?"

1. Read `memory/career/accomplishments.md` for the roll-up table.
2. Follow links to `memory/career/evidence/` notes.
3. Each evidence note has `so-what`, `impact-areas`, `observers`, and `source-type`.
4. If looking for a specific rubric area, filter by `impact-areas` field across evidence notes.
5. Do NOT reconstruct impact from daily notes unless a specific date or source detail is needed.

### Scenario 4: Find evidence for a durable pattern

Question: "What projects validated the 'examples over abstract rules' prompt design principle?"

1. Direct file: read `memory/patterns/decision-frameworks.md`.
2. The note body contains the evidence reference: "PL Responses / UX session March 31".
3. Follow `projects` frontmatter if deeper project context is needed.
4. Use Smart Connections with "prompt design examples abstract rules" for additional signal.
5. If career-level proof is needed: check `memory/career/evidence/pl-drop31-shipped.md` which references this pattern.
