---
name: persomemory-daily-sweep
description: Runs Florian's PersoMemory daily or end-of-day sweep. Use when the user asks to sweep today, summarize the day into memory, run a WorkIQ daily intake, audit action items, capture direction-setting conversations, or update daily notes and open loops from Microsoft 365 evidence.
---

# PersoMemory Daily Sweep

## Purpose

Extract strategic signals from Microsoft 365 evidence and Copilot conversation evidence, then route them into the memory graph. WorkIQ retrieves evidence. PersoMemory decides meaning.

## Execution Rule

Run this workflow in the current session when MCP tools are available. Do not delegate to a nested subagent from an interactive Copilot session because nested agents may not inherit WorkIQ, MCPVault, Smart Connections, or persomemory-lifecycle access. Use `persomemory-agent` only when it is the top-level selected agent, for example through `copilot --agent persomemory-agent`.

Do not use scheduled prompt tools during a sweep. Scheduling is configured separately.

## Phase 1: Memory Priming

Before querying WorkIQ, load the active context needed to construct informed queries:

1. Read `memory/active/now.md` and extract active projects, key people, and current priorities.
2. Read `memory/commitments/open-loops.md` and extract open commitments and pending follow ups.
3. Skim `memory/PROJECTS.md` and note active project slugs and names for wikilink matching.

## Phase 2: WorkIQ Evidence Bundle

Do not rely on one broad WorkIQ query. Run three separate WorkIQ evidence calls, then merge the outputs before routing memory:

1. Broad Evidence Scan: daily context, project movement, people signals, risks, reusable assets, and surprise items.
2. Action Item Audit: every concrete ask, owner, expected artifact, due date or timing, format, source, confidence, explicit vs inferred.
3. Direction Setting Audit: manager, mentor, leadership, and career guidance that changes future goals, role direction, exposure, skills, positioning, or behavior.

WorkIQ remains evidence only. Do not let WorkIQ judge career impact, Connect grade, or memory routing.

### WorkIQ Call 1: Broad Evidence Scan

Inject the memory context from Phase 1 into the placeholders before sending.

```text
Analyze the Microsoft 365 activity around Florian for [DATE].

Look across calendar, meetings, transcripts, Teams chats, emails, shared files, and any visible collaboration signals.

Do not produce a chronological activity log. Do not judge career impact or recommend memory routing. Return evidence and context only.

Known context for today's sweep:
- Active projects: [active project names from now.md]
- Key people: [key people from now.md]
- Open commitments: [open loops from open-loops.md]
- Current priorities: [priorities from now.md]

Identify the most important work signals under these lenses:

1. Top signals: what were the 3 to 5 most consequential things that happened today? For each, include what happened, why it matters, source, and people involved.
2. Important interactions: which conversations, meetings, chats, or emails changed context, created alignment, exposed risk, or required follow up?
3. High-level asks and commitments: which asks or commitments were visible enough to affect the daily narrative? Do not perform the detailed action audit here.
4. Leadership, manager, customer, and partner signals: did any influential stakeholder signal priority, concern, recognition, escalation, or direction? Do not perform the detailed direction-setting audit here.
5. Project and workstream movement: which projects moved forward, changed direction, got blocked, or gained new evidence of progress or risk?
6. Risks and weak signals: what could become a problem later?
7. Reusable knowledge: were any assets, prompts, decks, architectures, demos, workflows, patterns, or lessons created or discussed that could be reused?
8. Surprise detection: what happened today that was important but not covered by the known projects, people, or commitments listed above?

For each retained signal, return title, what happened, consequence, source type, people involved, projects or topics, and confidence.

At the end, list items discarded as low value and why.
```

### WorkIQ Call 2: Action Item Audit

```text
Audit Microsoft 365 activity around Florian for [DATE] for concrete action items only.

Look across meeting tasks, transcript action items, Teams asks, email asks, shared-file comments, and calendar context.

Do not summarize the day. Do not judge importance by seniority or visibility. Return every concrete ask or obligation that could matter later, including lower-profile meeting tasks.

Known context:
- Active projects: [active project names from now.md]
- Open commitments: [open loops from open-loops.md]

For each action item, return:
- Title
- Owner
- Expected output or artifact
- Due date or timing
- Source type and source detail
- People involved
- Project or topic
- Explicit or inferred
- Confidence
- Reason it should be kept or discarded

At the end, include:
- All still-open actions that should be mirrored into open loops.
- Ambiguous actions that need approval or clarification.
- Discarded items and why.
```

### WorkIQ Call 3: Direction Setting Audit

```text
Audit Microsoft 365 activity around Florian for [DATE] for direction-setting conversations only.

Focus on manager, mentor, leadership, customer, and partner conversations that change future goals, role direction, positioning, exposure, skills to build, behaviors to start or stop, or 1-3 year trajectory.

Do not summarize ordinary project status. Do not merge recognition of past impact with future guidance.

Known context:
- Key people: [key people from now.md]
- Current priorities: [priorities from now.md]

For each direction-setting signal, return:
- Title
- Who gave the signal
- Past-impact recognition, if any
- Future direction or guidance
- Implication for goals, feedback, career evidence, active context, or open loops
- Source type and source detail
- People involved
- Projects or topics
- Confidence
- Whether it is approval-gated

At the end, include:
- Career direction or feedback candidates.
- Career evidence candidates, separately from direction.
- Ambiguous items that need approval or clarification.
- Discarded items and why.
```

## Phase 3: Merge Contract

After all three WorkIQ calls complete:

1. Keep WorkIQ evidence and Copilot conversation evidence as independent streams until both have been audited.
2. Deduplicate across the three WorkIQ outputs, Copilot conversation evidence, and existing vault state.
3. Preserve source attribution from the originating evidence stream.
4. Mirror still-open concrete actions into `memory/commitments/open-loops.md`.
5. Keep direction-setting guidance separate from career evidence.
6. Write approval-gated items to `memory/inbox/approvals/YYYY-MM-DD.md`.
7. If one WorkIQ call fails, continue with the other evidence streams and add a `Sweep Failures` approval item.
8. If WorkIQ and Copilot evidence conflict, do not resolve it silently. Write a `Sensitive or Ambiguous Items` or `Sweep Failures` approval item with both sources.
9. If a Copilot session closes a loop raised in Teams or email, mirror the closure into open loops and cite both evidence streams when available.

## Phase 4: Copilot Conversation Evidence Bundle

Read pending conversation review pointers from:

```text
~/.local/share/persomemory/session-reviews/
```

Hooks queue pointer-only evidence. The daily sweep performs the actual conversation audit. Do not treat a pointer as memory, and do not copy raw transcript text into the vault.

### Session Inventory and Coverage Check

For each queued session pointer:

1. Classify it as `reviewable` when the referenced transcript exists and can be read.
2. Classify it as `not captured` when the transcript path is missing, empty, unreadable, or explicitly says `not captured`.
3. Classify it as `duplicate or superseded` when the session was already processed or clearly covered by a later memory write.
4. For queued `not captured` items, add a `Sweep Failures` approval item instead of silently skipping the session.
5. For duplicate or superseded items, record the discard reason in the sweep notes when useful.

The current hook may log some sessions with missing transcript breadcrumbs only in diagnostics rather than the review queue. Do not infer unseen sessions. Only audit queued pointers and report missing queued transcripts as sweep failures.

### Structured Conversation Audit

For each `reviewable` Copilot session, extract evidence under these lenses before routing:

1. **Session Context**: cwd, repo or folder, apparent project, branch if visible, source pointer, and session end reason.
2. **Outcome and Loop Closure Audit**: what loop, Teams ask, repo task, bug, feature, plan, or decision moved; whether anything was closed; what evidence shows closure.
3. **Action Item Audit**: concrete follow ups, owner, expected output, due date or timing, source, explicit vs inferred status, confidence, and keep or discard reason.
4. **Decision and Rationale Audit**: decisions made, tradeoffs considered, options rejected, constraints discovered, and why the choice matters later.
5. **Direction-Setting and Feedback Audit**: career, role, leadership, manager, customer, or strategy guidance surfaced in the conversation. Keep future guidance separate from recognition and evidence of impact.
6. **Reusable Asset and Pattern Audit**: prompts, scripts, checklists, workflow changes, tests, docs, playbooks, or reusable reasoning patterns created or improved.
7. **Risk and Weak Signal Audit**: unresolved uncertainty, shallow-capture risk, missing data, conflicting evidence, fragile assumptions, or follow ups that could be lost.
8. **Routing and Approval Audit**: classify each retained signal as daily evidence, open loop update, active context update, durable promotion candidate, approval inbox item, or discard.

Keep only signals that change future action, judgment, or retrieval. Discard implementation noise, tool logs, duplicate status narration, stale claims, and transient discussion.

### Conversation Routing Rules

Route conversation-derived signals as follows:

1. Daily evidence goes to `memory/daily/YYYY-MM-DD.md`.
2. New or closed operational loops go to `memory/commitments/open-loops.md`.
3. Material current status changes go to `memory/active/now.md`.
4. Decisions, durable patterns, durable people signals, project note updates, toolkits, and career evidence become approval items unless Florian explicitly approved the durable update in the conversation.
5. Career direction and feedback become `Career Direction and Feedback Updates` approval items unless explicitly approved.
6. Career evidence strong enough for Connect or promotion becomes a separate `Career Evidence Candidates` approval item.
7. Raw transcript, raw email, raw chat, credentials, secrets, and sensitive data are never copied into the vault.
8. Mark processed queue entries as reviewed or superseded when permissions allow. If not, rely on deduplication and local retention cleanup.

## Phase 5: Memory Routing

1. Write or merge `memory/daily/YYYY-MM-DD.md` using the daily note schema.
2. Populate frontmatter `projects` and `people` with wikilinks to existing notes based on what was mentioned.
3. Deduplicate against existing live capture content already in the daily note.
4. Update `memory/commitments/open-loops.md` for open or closed obligations.
5. Update `memory/active/now.md` only for material current context changes.
6. Flag promotion candidates in the daily note. Do not blindly promote into durable memory.
7. Preserve source attribution as `Automated sweep via WorkIQ`, `Manual WorkIQ sweep`, or `Copilot conversation sweep`.
8. Mark processed local conversation queue entries as reviewed or superseded when permissions allow.

Do not bury operational actions in the daily note. Mirror every still-open concrete action into `memory/commitments/open-loops.md`, including small artifacts such as one-slide summaries, review tasks, follow ups, and next-meeting deliverables.

Do not collapse career conversations into recognition only. Future role guidance belongs in a `Career Direction and Feedback Updates` approval item unless Florian explicitly approves the durable update. If the same conversation is also Connect or promotion proof, create a separate `Career Evidence Candidates` approval item.

## Approval Gates

Ask before:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Updating durable career goals or feedback from manager or mentor direction.
4. Promoting durable project, people, pattern, decision, or toolkit notes.
5. Closing projects.
6. Closing ambiguous commitments.
7. Resolving conflicting evidence.
8. Capturing potentially sensitive content.

When running unattended through `copilot -p`, do not ask. Write approval-gated decisions to `memory/inbox/approvals/YYYY-MM-DD.md` and leave them with status `pending`.

Approval inbox sections are Project Closures, Commitment Closures, Durable Promotions, Career Evidence Candidates, Career Direction and Feedback Updates, Sensitive or Ambiguous Items, Discard Recommendations, and Sweep Failures.

## Phase 6: Lifecycle Check

After routing, call:

```text
lifecycle_check(stale_days=14, loop_age_days=14)
```

Review overdue projects, stale active projects, and aged open loops. Do not skip this step.
