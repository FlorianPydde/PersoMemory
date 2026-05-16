# The Personal Memory Challenge

## Purpose

This document explains the PersoMemory problem from the top down. It is not a setup guide. It is the conceptual architecture for building a useful personal memory system around Copilot CLI, WorkIQ, MCPVault, Smart Connections, Obsidian, and scheduled or interactive agent workflows.

The core challenge is not storing notes. The core challenge is deciding what evidence should become memory, how long it should remain active, when it should be promoted or discarded, and how it should be retrieved at the right moment without flooding the agent context.

## Four Pillars

The memory system has four main categories.

1. Data ingestion
2. Ontology creation and memory management
3. Retrieval and inline session activation
4. Governance, lifecycle, and quality evaluation

The fourth pillar is easy to miss. It is the control layer that decides what is allowed to become memory, what needs approval, what should expire, what should be ignored, and whether retrieval is actually useful. Without it, the other three pillars can still work technically while the overall memory system becomes noisy, stale, or unsafe.

## High Level Process

PersoMemory should behave like an opinionated personal secretary, not like a passive archive.

1. It gathers evidence from multiple sources.
2. It separates raw evidence from interpreted memory.
3. It routes useful signals into the right memory layer.
4. It asks for approval before high impact or ambiguous decisions.
5. It retrieves only the minimum context needed for the current session.
6. It continuously checks whether stored memory is stale, noisy, sensitive, or no longer useful.

The intended loop is:

```text
Evidence sources
  -> daily or session evidence
  -> routing and deduplication
  -> operational memory or durable memory
  -> retrieval during future sessions
  -> lifecycle review and pruning
```

The system should optimize for future judgment, action, and retrieval. It should not optimize for completeness.

## Pillar 1: Data Ingestion

### What Data Ingestion Means

Data ingestion is the process of collecting evidence before deciding whether it deserves to become memory.

Evidence can come from several sources:

1. WorkIQ and Microsoft 365 activity: meetings, calendar, transcripts, Teams chats, email, shared files, and collaboration signals.
2. Copilot CLI sessions: planning discussions, design decisions, implementation work, debugging, and memory related conversations.
3. Manual user input: explicit statements such as "remember this", "this project is done", or "this follow up matters".
4. Repository artifacts: docs, commits, scripts, configuration, and architecture decisions.
5. Future sources: CRM, GitHub issues, PRs, task systems, calendar metadata, or project management tools.

The ingestion layer should collect evidence, not decide memory meaning. WorkIQ should not decide career impact. A Copilot transcript should not automatically become durable memory. A meeting mention should not automatically imply an active project.

### Current PersoMemory Approach

The current system uses:

1. WorkIQ for Microsoft 365 backed daily evidence.
2. Copilot hooks for pointer only session review entries.
3. MCPVault for deterministic vault reads and writes.
4. Smart Connections for semantic discovery when exact filenames are unknown.
5. The memory skill family for policy and operation.
6. `~/.local/share/persomemory` for disposable local queue and hook runtime state.

The most important design choice is that local queues store pointers only. They should not store extracted facts, summaries, commitments, decisions, project status, or career evidence.

### Ingestion Challenges

#### Challenge: Too much raw activity looks important

Microsoft 365 contains a lot of scheduling noise, status chatter, duplicated messages, and low consequence communication.

Possible answers:

1. Ask WorkIQ for evidence only, not memory routing.
2. Require each retained signal to explain the future consequence.
3. Keep an explicit discard list in daily sweeps so the agent learns what not to store.
4. Avoid chronological logs unless chronology is the actual user question.

#### Challenge: Multi source evidence conflicts

WorkIQ, Copilot conversations, and existing vault notes may disagree. A project may look active in meetings but be winding down in conversation. A commitment may appear open in a transcript but already be closed in memory.

Possible answers:

1. Treat existing curated memory as stronger than raw evidence unless new evidence is explicit.
2. Use approval items for conflicts instead of resolving them silently.
3. Preserve source attribution so future review can trace why a change was made.
4. Prefer "needs confirmation" over forced closure.

#### Challenge: Transcript capture may fail

Copilot `sessionEnd` can fire without a transcript path. The queue then risks accumulating review items with no reviewable evidence.

Possible answers:

1. Record missing transcript events as diagnostics only.
2. Create review queue entries only when a transcript path exists.
3. Make sweeps skip entries whose transcript is missing, empty, or `not captured`.
4. Keep diagnostics under `~/.local/share/persomemory`, not in the vault.

#### Challenge: Unattended ingestion cannot safely ask questions

A cron or scheduled sweep may discover something that needs judgment, such as a project closure, career evidence candidate, or sensitive item.

Possible answers:

1. Allow low risk daily and operational writes.
2. Route gated decisions to `memory/governance/approvals/YYYY-MM-DD.md`.
3. Review pending approval items during the morning brief.
4. Avoid `--yolo` and `--allow-all-tools` for unattended memory work by default.

#### Challenge: Privacy and sensitivity

Raw email, chat text, transcripts, names, opportunity details, and sensitive customer context can leak into durable notes if ingestion is too aggressive.

Possible answers:

1. Never write raw transcripts, raw email, or raw chat text to the vault.
2. Prefer summarized signals with source labels.
3. Do not promote volatile account names, opportunity names, or deal owner names unless explicitly requested.
4. Use approval gates for potentially sensitive content.

## Pillar 2: Ontology Creation and Memory Management

### What Ontology and Memory Management Mean

Ontology is the schema of memory. It defines what kinds of things exist and where they belong.

Memory management is the lifecycle discipline around those things. It decides when evidence becomes operational memory, when operational memory becomes durable memory, when durable memory should be revisited, and when stale context should be removed or downgraded.

### Current Memory Layers

PersoMemory separates four layers.

1. Evidence: daily notes and source attributed observations.
2. Operational memory: active context and open loops.
3. Durable memory: stable self model, project notes, people notes, patterns, decisions, toolkits, and career evidence.
4. Consolidation reasoning: DREAMS and promotion logs.

This separation matters because each layer has a different freshness and approval requirement.

### Current Note Types

The main note types are:

1. `MEMORY.md`: durable self model, stable working style, decision frameworks, and stable people context.
2. `memory/content/active/now.md`: current priorities and short lived active context.
3. `memory/content/commitments/open-loops.md`: obligations, follow ups, and recently closed loops.
4. `memory/content/daily/YYYY-MM-DD.md`: episodic evidence and daily intake.
5. `memory/content/projects/*.md`: structural project knowledge.
6. `memory/content/people/*.md`: durable relationship context.
7. `memory/content/patterns/*.md`: repeated heuristics and reusable patterns.
8. `memory/content/decisions/*.md`: durable decisions and revisit triggers.
9. `memory/content/toolkits/*.md`: reusable prompts, checklists, playbooks, and assets.
10. `memory/content/career/*.md`: accomplishments, feedback, goals, and growth evidence.
11. `memory/content/career/evidence/*.md`: atomic career evidence strong enough for Connect or promotion.
12. `memory/governance/approvals/*.md`: pending human decisions from unattended sweeps.

### Memory Management Challenges

#### Challenge: Daily notes become a dumping ground

Daily notes are useful as evidence, but they become harmful if every retrieval starts there.

Possible answers:

1. Treat daily notes as episodic evidence, not primary retrieval memory.
2. Promote repeated or durable signals into project, people, pattern, decision, toolkit, or career notes.
3. Keep operational state in `active/now.md` and `open-loops.md`, not buried in daily notes.
4. Use daily notes mainly when chronology, source detail, or a specific date matters.

#### Challenge: Current status becomes stale

Projects can end without anyone saying "this project is closed". Commitments can become irrelevant without explicit closure.

Possible answers:

1. Use lifecycle checks for stale projects and aged open loops.
2. Add `review-by` to winding down or uncertain project notes.
3. Use morning brief and weekly consolidation to surface stale state.
4. Require approval before closing ambiguous projects or commitments.

#### Challenge: Over promotion

Fresh thoughts can look durable in the moment. If promoted too early, `MEMORY.md` and durable notes become noisy.

Possible answers:

1. Route new facts first into daily notes or active context.
2. Promote durable memory only when repeated, identity shaping, strategy changing, relationship shaping, career relevant, or reusable.
3. Require approval for `MEMORY.md` changes and career evidence.
4. Use DREAMS for consolidation rather than promoting every raw signal.

#### Challenge: Commitments are easy to miss

If commitments stay only in meeting notes or daily notes, they stop being actionable.

Possible answers:

1. Mirror open obligations into `memory/content/commitments/open-loops.md`.
2. Mark closed loops explicitly, then remove them after consolidation.
3. Distinguish explicit promises from vague discussion.
4. Use lifecycle tooling to surface aged loops.
5. Run a zero-miss obligations/request pass during `memory-sweep`. Inspect meeting tasks, transcript action items, Teams asks, email asks, and shared-file comments for concrete deliverables, including lower-profile actions that are not top daily signals.

#### Challenge: Direction-setting conversations can be undercaptured

Manager, mentor, leadership, and career conversations often contain two different signals: recognition of past impact and guidance about future direction. If these are merged, the system may preserve evidence while losing the 1-3 year trajectory or behavior change.

Possible answers:

1. Split career conversations into recognition, evidence, and future direction.
2. Route recognition to daily notes and, when strong enough, career evidence approval items.
3. Route future guidance to `memory/content/career/feedback.md` or `memory/content/career/goals.md` through an approval-gated career direction update.
4. Capture role direction, exposure, skills, behaviors to start/stop/continue, and expected positioning.

#### Challenge: The graph can become inconsistent

If notes lack frontmatter or inline wikilinks, the graph becomes harder for Obsidian and agents to traverse.

Possible answers:

1. Require `type` frontmatter for every durable note.
2. Include relationship fields such as projects, people, decisions, patterns, and toolkits where relevant.
3. Add inline wikilinks in prose when referencing related notes.
4. Prefer updating existing notes over creating parallel duplicates.

#### Challenge: Career evidence threshold is subjective

Ordinary delivery can be mistaken for Connect or promotion level evidence.

Possible answers:

1. Keep ordinary delivery in daily notes or project notes.
2. Create atomic career evidence only when it is strong enough for Connect, promotion, or leadership narrative.
3. Use the controlled impact taxonomy.
4. Preserve observer and source type fields.

## Pillar 3: Retrieval and Inline Session Activation

### What Retrieval Means

Retrieval is the process of bringing the right memory into the current agent session.

The goal is not to load everything. The goal is to provide the smallest context that improves the next decision or action.

### Retrieval Modes

PersoMemory uses several retrieval modes.

1. Startup context: `MEMORY.md`, `memory/content/active/now.md`, and `memory/content/commitments/open-loops.md`.
2. Direct file lookup: read exact notes when the path is known.
3. Linked note traversal: follow frontmatter and inline wikilinks.
4. Property search: find notes by type, status, domain, or impact area.
5. Semantic retrieval: use Smart Connections when the exact note is unknown.
6. Daily note retrieval: use only for chronology, evidence, or a specific date range.

### Inline Session Challenges

#### Challenge: Context flooding

Too much memory makes the agent less useful. It can bury current work under stale or irrelevant facts.

Possible answers:

1. Load only a pointer to skill-triggered memory retrieval by default.
2. Search deeper only when the user mentions a project, person, topic, or prior discussion.
3. Prefer direct and linked notes before semantic search.
4. Avoid loading daily notes unless evidence or chronology matters.

#### Challenge: Retrieval can be semantically plausible but wrong

Semantic search can return related but non authoritative notes.

Possible answers:

1. Treat Smart Connections as discovery, not proof.
2. Prefer exact file reads and explicit wikilinks when available.
3. Cross check semantic hits against frontmatter and note bodies.
4. Cite the retrieved note path in reasoning when making memory based claims.

#### Challenge: Recency and durability can conflict

Recent daily evidence may contradict durable memory, but not every contradiction means durable memory should change.

Possible answers:

1. Treat durable notes as stable until new evidence is explicit.
2. Use active memory for temporary status changes.
3. Use approval items for conflicts.
4. Promote changes during consolidation when patterns repeat.

#### Challenge: Subagent execution boundaries are confusing

A delegated subagent may not have access to the parent session's live MCP connections or permissions.

Possible answers:

1. Run PersoMemory workflows in the current MCP-enabled session.
2. Invoke the relevant memory skill directly.
3. Avoid delegating manual sweeps to nested subagents.
4. Keep scheduled sweeps as direct skill invocations with explicit tool permissions.

#### Challenge: Hooks are not memory

Hooks can load context or queue pointers, but they should not make durable memory decisions.

Possible answers:

1. Use `sessionStart` for pointer-only startup context.
2. Use `agentStop` and `sessionEnd` only for pointer and diagnostic capture.
3. Keep hook state in `~/.local/share/persomemory`.
4. Let the memory skill workflow decide what gets written to the vault.

## Pillar 4: Governance, Lifecycle, and Quality Evaluation

### Why This Is a Separate Pillar

Governance is the difference between a memory system and a pile of notes.

It answers:

1. What is allowed to become memory?
2. What requires Florian approval?
3. What is too sensitive to store?
4. What should expire or be revisited?
5. How do we know retrieval is helping?
6. How do we detect and correct memory drift?

### Governance Mechanisms

Current mechanisms include:

1. Approval gates for high impact memory writes.
2. Approval files for unattended sweeps.
3. Lifecycle checks for stale projects and aged loops.
4. Controlled schemas and frontmatter.
5. Source attribution for every memory write.
6. Separation between raw evidence, operational memory, and durable memory.
7. Local disposable queues for transient runtime state.
8. Runtime regression checks for hooks and sweep behavior.

### Approval Gates

The system should ask before:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Promoting durable project, people, pattern, decision, or toolkit notes.
4. Closing a project.
5. Closing an ambiguous commitment.
6. Resolving conflicting evidence.
7. Capturing potentially sensitive content.

In unattended mode, the system should write pending items to approvals rather than applying the decision.

### Governance Challenges

#### Challenge: Automation creates false authority

An unattended sweep may sound confident even when evidence is weak.

Possible answers:

1. Store high impact decisions as pending approval items.
2. Preserve confidence and source type.
3. Separate "what evidence suggests" from "what memory should change".
4. Review approval items during the morning brief.

#### Challenge: Stale memory silently degrades retrieval

Outdated project status and old commitments can mislead future sessions.

Possible answers:

1. Run lifecycle checks during morning brief, evening sweep, and weekly consolidation.
2. Add review dates for winding down projects.
3. Surface stale items as decisions: confirm active, pause, close, extend review date, or disregard.
4. Avoid using `MEMORY.md` for current project status.

#### Challenge: Privacy failures are hard to undo

Once raw sensitive content is written into durable memory, it is easy to propagate through sync and backups.

Possible answers:

1. Do not store secrets, raw transcripts, raw emails, or raw chats.
2. Store source labels and summarized implications instead.
3. Use approval gates for sensitive or ambiguous items.
4. Keep local runtime queues disposable.

#### Challenge: There is no simple accuracy metric

The system is useful when it improves action and judgment, not when it stores the most notes.

Possible answers:

1. Evaluate retrieval by usefulness in real sessions.
2. Track failure modes: missed commitments, stale projects, noisy retrieval, wrong recall, over promotion.
3. Prefer qualitative review during weekly consolidation over raw note counts.
4. Add regression checks for known workflow failures.

#### Challenge: Memory can become self reinforcing

If an old framing is repeatedly retrieved, the agent may keep reinforcing it even after reality changes.

Possible answers:

1. Attach dates, status, and source attribution to memory.
2. Use lifecycle checks and review dates.
3. Treat contradictions as approval items.
4. Keep daily evidence available for audit without making it primary retrieval memory.

## End to End Routines

### Morning Brief

Purpose: decide what to focus on today.

Inputs:

1. Startup context.
2. Active memory.
3. Open loops.
4. Pending approval items.
5. Lifecycle check output.

Outputs:

1. Top focus areas.
2. Important follow ups.
3. Stale projects or overdue reviews.
4. Pending decisions needing approval.
5. One underweighted risk.

### Evening Sweep

Purpose: route the day's evidence into memory.

Inputs:

1. WorkIQ evidence from the six `memory-sweep` candidate passes: obligations/requests, project or outcome changes, career/feedback/guidance, decisions/risks/dependencies, reusable artifacts/ideas, and direct mentions/questions.
2. Copilot conversation pointers with captured transcripts.
3. Current active memory and open loops.
4. Project registry.

Outputs:

1. Daily note.
2. Updated open loops when clear.
3. Updated active context when explicit.
4. Approval items for gated decisions.
5. Lifecycle check follow ups.
6. Explicit candidate evidence for obligations, career guidance, decisions, risks, reusable artifacts, and direct mentions, even when no durable write is made.

### Weekly Consolidation

Purpose: promote repeated or durable signals.

Inputs:

1. DREAMS since last consolidation.
2. Daily notes since last consolidation.
3. Related durable notes.
4. Pending Copilot conversation entries not processed by evening sweeps.

Outputs:

1. Durable promotion recommendations.
2. Closure recommendations.
3. Stale or noisy memory to disregard.
4. Reusable patterns.
5. Career evidence candidates.
6. Career direction and feedback update candidates.

## Design Principles

1. Evidence is not memory.
2. More memory is not better memory.
3. Daily notes are evidence, not primary retrieval.
4. Operational state belongs in active memory and open loops.
5. Durable memory requires repeated signal, explicit approval, or clear future value.
6. Raw sensitive data should not enter the vault.
7. Approval is a product feature, not friction.
8. Retrieval should be minimal, linked, and source aware.
9. Lifecycle management is as important as capture.
10. The system should optimize for better future decisions, not perfect historical recall.

## Open Design Questions

1. How should the system score memory usefulness after retrieval?
2. Should approval items have a maximum age before automatic deferral or discard recommendation?
3. What is the right threshold for creating new project or people notes from repeated daily evidence?
4. How should contradictions between WorkIQ, Copilot conversations, and user statements be displayed?
5. Should scheduled sweeps produce a short audit summary in addition to vault writes?
6. Which retrieval failures should become automated regression tests?

## Summary

The memory challenge is best understood as four coupled systems.

1. Ingestion gathers evidence from multiple sources.
2. Ontology and memory management turn evidence into structured, layered memory.
3. Retrieval activates the right context at the right time.
4. Governance and evaluation keep the system safe, current, and useful.

The fourth pillar is the one that prevents PersoMemory from becoming a write only archive. It makes the system behave like a careful assistant: selective, source aware, approval seeking, and willing to forget or defer when memory no longer serves future action.
