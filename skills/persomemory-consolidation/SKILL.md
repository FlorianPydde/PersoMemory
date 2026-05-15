---
name: persomemory-consolidation
description: Runs PersoMemory dreaming and consolidation. Use when the user asks to dream, consolidate this week, promote daily notes, review durable memory candidates, close stale memory, or turn repeated daily evidence into long-term memory.
---

# PersoMemory Consolidation

## Purpose

Promote repeated or durable daily evidence into long-term memory while pruning noise and preserving source attribution. Consolidation may draft recommendations without approval. It must not mutate durable memory without approval.

## Execution Rule

Run this workflow in the current session when MCP tools are available. Do not delegate to a nested subagent from an interactive Copilot session because nested agents may not inherit MCPVault, Smart Connections, or persomemory-lifecycle access. Use `persomemory-agent` only when it is the top-level selected agent.

## Memory Store

The active memory store is the Obsidian vault configured for MCPVault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

All `memory/...`, `DREAMS.md`, and `MEMORY.md` paths in this workflow are vault-relative paths. Read and write them through MCPVault or the configured Obsidian vault path. Do not resolve them relative to the current working directory or the PersoMemory setup repo.

## Inputs

Read:

1. `DREAMS.md` to find the last consolidation point.
2. Daily notes since the last consolidation point.
3. Pending Copilot conversation queue entries that were not processed by evening sweeps. Skip entries whose transcript is missing, empty, or `not captured`.
4. `memory/preferences/approval-routing.md`, if it exists.
5. Related project, people, pattern, decision, toolkit, and career notes only when needed.

Use Smart Connections only to discover related durable notes. Do not rely on semantic search alone when explicit wikilinks or frontmatter fields exist.

## Candidate Scoring

Score candidate memory by:

1. Frequency.
2. Durability.
3. Actionability.
4. Relevance.
5. Reuse potential.

Keep facts that change future action, judgment, or retrieval. Discard scheduling noise, duplicate facts, raw messages, transient implementation detail, and one-off facts with no future consequence.

## Draft Report

Return a draft consolidation report with:

1. Durable promotions recommended.
2. Project or commitment closures recommended.
3. Stale or noisy memory to disregard.
4. Reusable patterns.
5. Career evidence candidates.
6. Decisions that need Florian approval.
7. Approval routing preference candidates when explicit or repeated approval decisions suggest a durable routing preference.

## Approved Routing

After Florian approves specific changes, route durable signals:

1. Identity and stable operating truths go to `MEMORY.md`.
2. Project knowledge goes to `memory/projects/`.
3. Relationship signals go to `memory/people/`.
4. Heuristics go to `memory/patterns/`.
5. Durable decisions go to `memory/decisions/`.
6. Reusable assets go to `memory/toolkits/`.
7. Career evidence goes to `memory/career/`.
8. Proof strong enough for Connect or promotion becomes an atomic note in `memory/career/evidence/`.
9. Approved approval-routing preferences update `memory/preferences/approval-routing.md`.

When writing or updating durable notes, always include frontmatter and inline wikilinks. Record the reasoning and outcome in `DREAMS.md`.

Never delete daily notes. They are evidence.

## Approval Gates

Ask before:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Promoting durable project, people, pattern, decision, or toolkit notes.
4. Closing a project.
5. Closing an ambiguous commitment.
6. Resolving conflicting evidence.
7. Capturing potentially sensitive content.

Never store credentials, tokens, secrets, raw email, raw chat, or raw transcript content.
