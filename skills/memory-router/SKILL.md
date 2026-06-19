---
name: memory-router
description: "Router and policy skill for the user's executive memory system. Use this for any ambiguous, mixed, scoped, or general memory request: recall, what should I focus on for X, project/person/topic context, commitments, capture this, should this be remembered, what do I owe, what do we know, or memory write/routing decisions. For explicit whole-day brief use memory-brief; explicit daily/end-of-day evidence intake use memory-sweep; explicit consolidation, stale-memory review, archive, merge, supersede, or cleanup use memory-maintenance."
---

# Memory Router

## Purpose

Classify memory intent, choose the smallest useful retrieval path, enforce safety and approval gates, and route to specialized memory skills when the user asks for a full workflow.

This skill is the executive control layer. It should not become the daily sweep, morning brief, or maintenance manual.

## Core Principle

Use cue-driven retrieval, not session-driven loading.

At session start, no memory content should be loaded by default. Agent Skills already provide progressive disclosure: skill metadata is enough for discovery, and this skill loads only when the user asks for memory work.

## Memory Store

Active memory lives in the Obsidian vault:

`<VAULT_PATH>`

## Tool Roles

1. WorkIQ retrieves Microsoft 365 evidence from Teams, email, meetings, calendar, documents, people, and transcripts.
2. Work IQ Teams sends or manages Teams messages only when the user explicitly asks.
3. MCPVault performs deterministic reads and writes in the Obsidian vault.
4. Smart Connections finds semantically related notes when exact paths are unknown.
5. persomemory-lifecycle surfaces stale outcomes, aged open loops, and overdue reviews.

WorkIQ output is evidence, not memory truth. MCPVault writes files, but this skill decides routing. Smart Connections suggests candidates, but exact reads confirm relevance.

## Skill Selection

| User intent | Use |
| --- | --- |
| Ambiguous or mixed memory request | `memory-router` |
| Project-scoped attention: "I am working on Phoenix, what should I focus on today?" | `memory-router` |
| Named project/person/topic recall | `memory-router` |
| "What do I owe?", "capture this", "should this be remembered?" | `memory-router` |
| Whole-day or whole-work focus: "morning brief", "what matters today?" | `memory-brief` |
| End-of-day or daily intake from WorkIQ/Copilot | `memory-sweep` |
| Consolidate, dream, archive, stale review, merge, supersede, cleanup | `memory-maintenance` |

When a request contains both a scope and an attention phrase, this router wins. Scope the attention retrieval instead of invoking the broad day brief.

## Retrieval Modes

Classify the user request before loading memory.

| Mode | Triggers | First context to load |
| --- | --- | --- |
| Attention scoped to outcome/topic | "working on X", "focus on X today", "what's next for X" | Named outcome or topic, linked execution, blockers/waiting items |
| Broad attention | "morning brief", "what should I focus on today" with no scope | Route to `memory-brief` |
| Outcome recall | "bring me up to speed on X", "what do we know about X" | `outcomes/`, explicit links, active execution |
| Execution recall | "what do I owe", "open loops", "follow ups" | `execution/open-loops.md` filtered by scope/person/date |
| Evidence recall | "what did X say", "what happened in meeting Y" | WorkIQ, `evidence/`, then linked records |
| Reusable memory | "have I done this before", "use prior artifacts", "brainstorm with memory" | `reusable/`, similar outcomes, principles, assets |
| Capture/write | "remember this", "capture this", "write this to memory" | Current conversation signal plus relevant target note if obvious |
| Lifecycle/maintenance | "clean up", "archive", "consolidate", "stale" | Route to `memory-maintenance` |

## Retrieval Order

Retrieval is two-stage: deterministic expansion first, semantic widening second.

1. Direct file lookup when the exact path is known.
2. Explicit graph links from the anchor record (the `links:` wikilinks).
3. Property search by `type`, `subtype`, `tags`, `status`, date, or relationship fields.
4. Smart Connections for conceptual similarity — discovery only; confirm candidates with exact reads.
5. Daily/evidence notes only when chronology, proof, or contradiction matters.

Steps 1–3 are the deterministic stage; step 4 is the semantic stage and never the first
move. `type` is one of six flat folder-values (`evidence`, `outcome`, `execution`,
`reusable`, `view`, `governance`); `subtype` narrows within a folder; `tags` are
cross-cutting facets. When Smart Connections repeatedly surfaces the same strong neighbor
across sessions, propose promoting it to a curated `links:` wikilink during maintenance.

Do not start by loading daily notes unless the user asks about a date, source evidence, or "what happened".

## Live Capture and Writes

For live capture:

1. Extract the smallest useful signal.
2. Keep only facts that change future action, retrieval, judgment, or reuse.
3. Prefer evidence first unless the update is operationally obvious.
4. Obvious open obligations may update `execution/open-loops.md`.
5. Obvious current status changes may update `views/active-now.md`.
6. Durable promotions, career evidence, closure, people judgments, ontology/routing changes, and ambiguous commitment closures require approval.

Never store raw transcripts, raw email, raw chat, credentials, tokens, secrets, or sensitive raw data.

## Approval Gates

Ask before:

1. Creating or changing durable self-model, career-impact, or operating-principle records.
2. Creating career-impact evidence.
3. Promoting durable outcomes or reusable memory.
4. Closing or reopening outcomes.
5. Closing ambiguous commitments.
6. Resolving conflicting evidence.
7. Capturing sensitive content.
8. Changing ontology, retrieval policy, or approval-routing preferences.

Approval items live in `governance/approvals/YYYY-MM-DD.md`.

## Output Rule

Answer from the smallest context that satisfies the request. If more retrieval would materially improve the answer, say what you need and retrieve it. Do not provide a full memory dump unless the user explicitly asks for one.
