---
name: persomemory-morning-brief
description: Runs Florian's PersoMemory morning brief. Use when the user asks for a morning sweep, morning memory brief, today's focus, open loops that matter today, stale memory state, or pending approval decisions.
---

# PersoMemory Morning Brief

## Purpose

Produce a concise morning operating brief from active memory, open commitments, pending approvals, and lifecycle state. This skill should orient the day; it should not perform a daily WorkIQ sweep.

## Execution Rule

Run this workflow in the current session when MCP tools are available. Do not delegate to a nested subagent from an interactive Copilot session because nested agents may not inherit MCPVault, Smart Connections, or persomemory-lifecycle access. Use `persomemory-agent` only when it is the top-level selected agent.

## Inputs

Load the minimum memory context:

1. `MEMORY.md`.
2. `memory/active/now.md`.
3. `memory/commitments/open-loops.md`.
4. `memory/inbox/approvals/*.md` with `status: pending`, if the approval inbox exists.

If hook-loaded PersoMemory startup context is already present, use it instead of reloading unless it is stale.

Do not load daily notes by default. Use daily notes only when the user asks for chronology, evidence, or a specific date.

## Workflow

1. Load the inputs above.
2. Run `lifecycle_check(stale_days=14, loop_age_days=14)`.
3. Return:
   1. Top 3 focus areas for today.
   2. Open follow ups that matter today.
   3. Stale projects or overdue reviews.
   4. Pending approval items grouped by decision type.
   5. One risk Florian may be underweighting.
   6. One question: "What is the one outcome that makes today successful?"
4. Ask Florian to approve, reject, defer, or edit pending approval items that still matter.
5. Apply approved items through normal PersoMemory write rules and update their status.

Do not otherwise write to memory unless Florian explicitly approves.

## Approval and Safety

Ask before:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Promoting durable project, people, pattern, decision, or toolkit notes.
4. Closing a project.
5. Closing an ambiguous commitment.
6. Resolving conflicting evidence.
7. Capturing potentially sensitive content.

Never store credentials, tokens, secrets, raw email, raw chat, or raw transcript content.
