---
name: memory
description: Router and policy skill for Florian's executive memory system. Use this for any ambiguous, mixed, scoped, or general memory request: recall, "what should I focus on for X", project/person/topic context, commitments, capture this, should this be remembered, what do I owe, what do we know, or memory write/routing decisions. For explicit whole-day brief use memory-brief; explicit daily/end-of-day evidence intake use memory-sweep; explicit consolidation, stale-memory review, archive, merge, supersede, or cleanup use memory-maintenance.
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

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

All `memory/...`, `memory/governance/dreams.md`, and `MEMORY.md` paths are vault-relative.

## Tool Roles

1. WorkIQ retrieves Microsoft 365 evidence from Teams, email, meetings, calendar, documents, people, and transcripts.
2. Work IQ Teams sends or manages Teams messages only when Florian explicitly asks.
3. MCPVault performs deterministic reads and writes in the Obsidian vault.
4. Smart Connections finds semantically related notes when exact paths are unknown.
5. persomemory-lifecycle surfaces stale outcomes, aged open loops, and overdue reviews.

WorkIQ output is evidence, not memory truth. MCPVault writes files, but this skill decides routing. Smart Connections suggests candidates, but exact reads confirm relevance.

## Skill Selection

| User intent | Use |
| --- | --- |
| Ambiguous or mixed memory request | `memory` |
| Project-scoped attention: "I am working on Phoenix, what should I focus on today?" | `memory` |
| Named project/person/topic recall | `memory` |
| "What do I owe?", "capture this", "should this be remembered?" | `memory` |
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
| Outcome recall | "bring me up to speed on X", "what do we know about X" | Named outcome, explicit links, active execution |
| Execution recall | "what do I owe", "open loops", "follow ups" | Open execution items filtered by scope/person/date |
| Evidence recall | "what did X say", "what happened in meeting Y" | WorkIQ or daily evidence first, then linked records |
| Reusable memory | "have I done this before", "use prior artifacts", "brainstorm with memory" | Reusable memory, similar outcomes, principles, assets |
| Capture/write | "remember this", "capture this", "write this to memory" | Current conversation signal plus relevant target note if obvious |
| Lifecycle/maintenance | "clean up", "archive", "consolidate", "stale" | Route to `memory-maintenance` |

## Retrieval Order

1. Direct file lookup when the exact path is known.
2. Explicit graph links from the anchor record.
3. Property search by type, status, domain, date, or relationship fields.
4. Smart Connections for conceptual similarity.
5. Daily/evidence notes only when chronology, proof, or contradiction matters.

Do not start by loading daily notes unless the user asks about a date, source evidence, or "what happened".

## Live Capture and Writes

For live capture:

1. Extract the smallest useful signal.
2. Keep only facts that change future action, retrieval, judgment, or reuse.
3. Prefer evidence first unless the update is operationally obvious.
4. Obvious open obligations may update Execution/open loops.
5. Obvious current status changes may update active context.
6. Durable promotions, career evidence, closure, people judgments, ontology/routing changes, and ambiguous commitment closures require approval.

Never store raw transcripts, raw email, raw chat, credentials, tokens, secrets, or sensitive raw data.

## Approval Gates

Ask before:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Promoting durable outcomes, reusable memory, people context, decisions, patterns, or assets.
4. Closing or reopening outcomes.
5. Closing ambiguous commitments.
6. Resolving conflicting evidence.
7. Capturing sensitive content.
8. Changing ontology, retrieval policy, or approval-routing preferences.

Approval items live in `memory/governance/approvals/YYYY-MM-DD.md`.

## Output Rule

Answer from the smallest context that satisfies the request. If more retrieval would materially improve the answer, say what you need and retrieve it. Do not provide a full memory dump unless the user explicitly asks for one.
