---
name: persomemory-graph-steward
description: Reviews PersoMemory graph cascades, entity disposition, monthly compression, and ontology maintenance. Use when a project/person/pattern/decision changes state, when the vault feels too large, or when linked memory notes may need coordinated updates.
---

# PersoMemory Graph Steward

## Purpose

Maintain the PersoMemory ontology as a useful graph. This workflow handles cascade review, entity disposition, monthly compression, and maintenance reports. It is conservative by design: version 1 is dry-run over linked memory notes.

## Memory Store

The active memory store is the Obsidian vault configured for MCPVault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`

All `memory/...`, `DREAMS.md`, and `MEMORY.md` paths in this workflow are vault-relative paths. Read and write them through MCPVault or the configured Obsidian vault path. Do not resolve them relative to the current working directory or the PersoMemory setup repo.

## Execution Rule

Run this workflow in the current MCP-enabled session or as the top-level `persomemory-graph-steward` agent. Do not delegate to a nested subagent because nested agents may not inherit MCPVault, Smart Connections, or persomemory-lifecycle access.

## Triggers

Use this workflow when:

1. A project, person, pattern, decision, career note, or commitment changes lifecycle state.
2. Florian says a project is done, paused, reactivated, no longer relevant, or only historical.
3. Linked notes may need coordinated updates.
4. The vault feels too large or entity usefulness is unclear.
5. Monthly compression is requested.
6. A daily/consolidation/morning workflow discovers graph drift or retrieval noise.

## Version 1 Write Boundary

Version 1 is dry-run over linked memory notes.

Allowed writes:

1. `memory/maintenance/YYYY-MM-DD-{slug}.md` impact reports.
2. `memory/approvals/YYYY-MM-DD.md` approval items.

Forbidden automatic writes:

1. Project notes.
2. Person notes.
3. Pattern notes.
4. Decision notes.
5. Career notes.
6. Active context.
7. Open loops.
8. `MEMORY.md`.
9. `DREAMS.md`.

Recommend linked-note changes in the maintenance report instead of applying them. Route hard decisions to approvals.

## Cascade Review Inputs

For a cascade review, start from the anchor note and read:

1. `MEMORY.md` only when the change may affect durable identity or operating truths.
2. `memory/active/now.md`.
3. `memory/commitments/open-loops.md`.
4. `memory/preferences/approval-routing.md`, if it exists.
5. The anchor note.
6. Explicit frontmatter links from the anchor note.
7. Direct backlinks and text references to the anchor note.
8. Pending `memory/approvals/*.md` items related to the anchor.
9. Recent daily notes only when chronology, evidence, or contradiction requires them.
10. Second-hop notes only when a first-hop note proposes a concrete change.

Use Smart Connections only to discover candidate notes. Confirm relevance through exact file reads.

## Cascade Review Output

Write one maintenance report under:

`memory/maintenance/YYYY-MM-DD-{topic}.md`

The report must include:

1. Triggering statement or evidence.
2. Anchor note.
3. Notes inspected.
4. Proposed changes by category.
5. Low-risk update recommendations.
6. Approval-gated changes proposed.
7. Conflicts or stale evidence found.
8. Notes intentionally left unchanged.
9. Entity disposition table.
10. Source paths.

## Entity Disposition

Classify every inspected durable entity:

1. **Keep active**: still affects current work, open loops, or near-term decisions.
2. **Keep as reference**: no longer active, but useful for precedent, people context, architecture rationale, or career narrative.
3. **Promote/abstract**: project-specific content should become a pattern, decision, toolkit, or career evidence.
4. **Merge**: content duplicates another note and should be consolidated.
5. **Archive/disregard**: content should be kept for audit but excluded from normal retrieval.
6. **Delete candidate**: only clearly accidental, duplicate, or valueless notes.

Archive, merge, disregard, and delete candidates require approval. Do not move inactive but useful notes into archive folders by default. Keep them in place and propose selective `retrieval-status` markers instead.

## Durable Entity Creation Threshold

Create or recommend a durable note only when the signal meets at least one criterion:

1. Active operational state that affects current prioritization or execution.
2. An open commitment or obligation.
3. A durable decision with rationale that changes future behavior.
4. A repeated or reusable pattern.
5. Career-grade evidence or durable career direction.
6. A person or relationship signal that will affect future interactions.
7. A project likely to be referenced again.

Everything else stays in daily evidence, `DREAMS.md`, a monthly compression report, or an approval item.

## Closed Project Reactivation

Never silently reopen a closed project.

Classify later evidence as:

1. Historical reference.
2. Post-project relationship or contact.
3. Residual handover or support.
4. New project/reactivation candidate.
5. Conflict requiring approval.

If evidence suggests renewed work, create a reactivation approval item. The approved outcome can either reopen the existing project note or create a new linked project note.

## Monthly Compression

Monthly compression means evidence distillation, not deletion.

Read:

1. The month's daily notes.
2. `memory/active/now.md`.
3. `memory/commitments/open-loops.md`.
4. `memory/preferences/approval-routing.md`, if it exists.
5. Pending approvals.
6. Project registry and relevant durable notes.

Partition evidence by entity: project, person, decision, pattern, toolkit, career, commitment, and preference.

For each entity, classify signals as:

1. Status change.
2. Open-loop update.
3. Durable promotion candidate.
4. Career evidence candidate.
5. Reusable pattern or toolkit candidate.
6. Contradiction or conflict.
7. Discard/no future consequence.

Write one global monthly report:

`memory/maintenance/YYYY-MM-monthly-compression.md`

The report must include:

1. Month and daily-note range reviewed.
2. Inputs loaded.
3. Entity summaries by project, person, pattern, decision, career, and commitment.
4. Proposed durable updates.
5. Approval items created.
6. Entity disposition changes proposed.
7. Daily notes marked as cold evidence.
8. Discarded or no-future-consequence signals.

Daily notes remain append-only evidence. Do not delete or merge them.

## Approval Gates

Write approval items to `memory/approvals/YYYY-MM-DD.md` for:

1. Project closure or reactivation.
2. Ambiguous commitment closure.
3. Durable project, person, pattern, decision, toolkit, or career promotion.
4. Career evidence creation.
5. Archive, merge, disregard, or delete candidates.
6. Conflicting evidence resolution.
7. `MEMORY.md` edits.
8. Preference or retrieval policy changes.

Every approval item should include Decision required, Recommended answer, Why this is gated, Evidence, If approved, If rejected, Default if no answer, and Preference signal to watch.

## Maintenance Report Template

Use `templates/maintenance-report.md` as the source shape for maintenance reports.

## Safety Rules

1. Never store secrets.
2. Never write raw transcripts, raw email, or raw chat text.
3. Never delete memory automatically.
4. Never treat semantic search as proof.
5. Preserve source attribution through vault-relative paths.
6. Prefer fewer, higher-signal durable entities over exhaustive ontology expansion.
