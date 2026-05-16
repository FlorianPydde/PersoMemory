---
name: memory-sweep
description: Runs evidence intake for the memory system. Use for end-of-day sweep, daily memory sweep, WorkIQ intake, Microsoft 365 evidence review, Teams/email/meeting action audit, career or feedback scan, Copilot CLI session sweep, conversation evidence capture, or updating daily evidence and obvious open loops from workplace or agent-session evidence.
---

# Memory Sweep

## Purpose

Retrieve candidate evidence from WorkIQ and Copilot CLI sessions, preserve source-localizing details, then route only clear operational updates into memory. WorkIQ retrieves evidence; the memory system decides meaning.

## Boundary

This skill ingests evidence. It does not perform durable consolidation or graph cleanup. Use `memory-maintenance` for promotion, archive, merge, supersede, stale-memory review, or monthly compression.

## Memory Store

Active memory lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory`

All vault paths are relative to this vault. V2 does not use top-level `MEMORY.md` or `dreams.md`.

## Priming

Before WorkIQ calls, load only what improves candidate retrieval and deduplication:

1. `views/active-now.md` for active outcomes and current priorities.
2. `execution/open-loops.md` for open execution items.
3. `outcomes/` for outcome names and slugs when needed.
4. `governance/ontology/contract.md` for ambiguous routing.
5. `governance/preferences/approval-routing.md`, if it exists.

## WorkIQ Contract

WorkIQ accepts natural-language questions. Do not ask it to decide what is "important" or "memory-worthy".

Ask for candidate lists with observable evidence. Every pass should request:

1. Source type and source detail.
2. Sender, speaker, or organizer when visible.
3. Date/time or meeting/thread reference.
4. Exact wording or close paraphrase.
5. Candidate output/action/decision/artifact when applicable.
6. Confidence and ambiguity.
7. The literal phrase `No candidates found` if empty.

Store candidate outputs and source-localizing details, not raw email, raw chat, or raw transcript text.

## WorkIQ Question Battery

Run these six passes for the target date or date range.

### 1. Obligations and Requests

```text
Search Microsoft 365 activity around Florian for [DATE/RANGE].

Return a candidate list, not a summary.

Find every message, email, meeting note, transcript passage, task, or shared-file comment where:
- Florian says he will do something.
- Someone asks Florian to do, review, send, prepare, decide, follow up, validate, schedule, or share something.
- A concrete output, owner, due date, next step, or blocker is mentioned.

For each candidate include source type, source detail, sender/speaker, date/time, exact wording or close paraphrase, requested output, owner, due date or timing, project/topic, whether explicit or inferred, confidence, and ambiguity.

If none are found, return `No candidates found`.
```

### 2. Project or Outcome Changes

```text
Search Microsoft 365 activity around Florian for [DATE/RANGE].

Return a candidate list, not a summary.

Find every project, workstream, customer pursuit, PoC, handover, delivery, or initiative where status, scope, owner, date, blocker, dependency, next step, risk, success criterion, or priority changed.

For each candidate include source type, source detail, sender/speaker, date/time, exact wording or close paraphrase, project/outcome name, what changed, before/after if visible, people involved, confidence, and ambiguity.

If none are found, return `No candidates found`.
```

### 3. Career, Feedback, and Guidance

```text
Search Microsoft 365 activity around Florian for [DATE/RANGE].

Return a candidate list, not a summary.

Find discussions involving manager, skip-level, mentor, leadership, customer, or senior stakeholder feedback about Florian's role, scope, visibility, strengths, growth areas, mentoring, leadership, promotion, Connect evidence, career direction, future opportunities, or 1-3 year trajectory.

Keep recognition of past impact separate from future guidance.

For each candidate include source type, source detail, sender/speaker, date/time, exact wording or close paraphrase, who gave the signal, past-impact recognition, future guidance if any, potential implication, confidence, and ambiguity.

If none are found, return `No candidates found`.
```

### 4. Decisions, Risks, and Dependencies

```text
Search Microsoft 365 activity around Florian for [DATE/RANGE].

Return a candidate list, not a summary.

Find explicit decisions, reversals, tradeoffs, approvals, unresolved questions, risks, blockers, dependencies, assumptions, constraints, or "waiting on" statements.

Look for language such as decided, agreed, approved, confirmed, blocked, waiting on, dependency, risk, concern, assumption, constraint, unresolved, open question, or decision needed.

For each candidate include source type, source detail, sender/speaker, date/time, exact wording or close paraphrase, decision/risk/dependency, affected outcome, owner if visible, due date or review trigger if visible, confidence, and ambiguity.

If none are found, return `No candidates found`.
```

### 5. Reusable Artifacts and Ideas

```text
Search Microsoft 365 activity around Florian for [DATE/RANGE].

Return a candidate list, not a summary.

Find reusable artifacts or ideas mentioned, created, shared, or requested: decks, one-slides, code artifacts, prompts, demos, blogs, templates, workshops, playbooks, checklists, frameworks, architecture patterns, evaluation methods, reusable narratives, or lessons.

For each candidate include source type, source detail, sender/speaker, date/time, exact wording or close paraphrase, artifact/idea name, format, where it may be located, why it might be reusable, future retrieval cues, confidence, and ambiguity.

If none are found, return `No candidates found`.
```

### 6. Direct Mentions and Questions to Florian

```text
Search Microsoft 365 activity around Florian for [DATE/RANGE].

Return a candidate list, not a summary.

Find Teams messages, emails, meeting chats, comments, or threads where Florian is mentioned by name, @mentioned, directly asked a question, assigned as owner, asked for input, or expected to respond.

For each candidate include source type, source detail, sender/speaker, date/time, exact wording or close paraphrase, requested response or input, deadline if visible, project/topic, confidence, and ambiguity.

If none are found, return `No candidates found`.
```

## Copilot CLI Session Sweep

Read pointer-only review entries from:

`~/.local/share/persomemory/session-reviews/`

For each reviewable transcript pointer, extract candidates using the six lenses above plus:

1. Design decisions and reasoning state.
2. Options considered and rejected.
3. Instructions, skill changes, scripts, docs, or reusable workflows created.
4. Loop closures where Copilot work completed a WorkIQ-raised commitment.

Do not copy raw transcript text into the vault.

## Routing

After collecting candidates:

1. Deduplicate against existing daily evidence, active context, open loops, and pending approvals.
2. Write or merge concise daily evidence to `evidence/daily/YYYY-MM-DD.md`.
3. Mirror still-open concrete obligations into `execution/open-loops.md`.
4. Update `views/active-now.md` only for material current-state changes.
5. Queue durable promotions, career-impact evidence, people judgments, closure, conflicting evidence, ontology changes, or ambiguous routing in `governance/approvals/YYYY-MM-DD.md`.
6. Keep WorkIQ evidence and Copilot evidence separate until merged with source attribution.

## Safety

Never store credentials, tokens, secrets, raw emails, raw chats, or raw transcripts. If evidence is sensitive or conflicting, create an approval item instead of deciding silently.
