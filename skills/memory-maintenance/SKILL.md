---
name: memory-maintenance
description: Maintains the memory vault over time. Use for consolidate, dream, promote evidence, review durable memory candidates, stale memory, graph cleanup, archive, merge, supersede, close or reopen outcomes, monthly compression, reduce vault noise, or clean up memory for a named project/outcome/person/topic. This skill combines consolidation and stewardship; use modes rather than separate skills.
---

# Memory Maintenance

## Purpose

Maintain memory quality after evidence has been captured. This skill reviews evidence and durable records, then proposes promotions, updates, archival decisions, merges, supersessions, closures, and cleanup actions.

It is conservative by design: draft recommendations first, apply approval-gated changes only after Florian approves them.

## Modes

| Mode | Use when |
| --- | --- |
| `promote` | User asks to consolidate, dream, review durable candidates, or turn evidence into long-term memory. |
| `steward` | User asks to review stale memory, cleanup graph drift, archive, merge, supersede, close, or reduce noise. |
| `scoped-maintenance` | User asks to clean up or review memory for a named outcome, project, person, topic, or asset. |
| `monthly-compression` | User asks to compress a month or reduce old daily evidence into a maintenance report. |

If the mode is unclear, infer it from the request and state the chosen mode before proceeding.

## Memory Store

Active memory lives in the Obsidian vault:

`/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultMemory`

All `memory/...`, `memory/governance/dreams.md`, and `MEMORY.md` paths are vault-relative.

## Required Multi-Pass Checklist

Run the same checklist for every mode, scoped to the user's request.

### 1. Evidence Pass

Read relevant evidence:

1. Daily notes since the last review or within the requested period.
2. WorkIQ candidate evidence written by `memory-sweep`.
3. Copilot session evidence written by `memory-sweep`.
4. Source details only when chronology, proof, or contradiction requires it.

Daily notes remain evidence. Do not delete them.

### 2. Open-State Pass

Read current operational state:

1. `memory/content/active/now.md`.
2. `memory/content/commitments/open-loops.md`.
3. Pending approvals in `memory/governance/approvals/`.
4. Lifecycle/staleness results from persomemory-lifecycle when available.

### 3. Durable-Memory Pass

Read durable records only as needed:

1. Anchor outcome, execution, or reusable memory records named by the user.
2. Explicit graph links from the anchor.
3. Related records discovered by property search or Smart Connections, confirmed by exact reads.
4. `MEMORY.md` only when durable identity or stable operating truths may change.

### 4. Conflict and Staleness Pass

Identify:

1. Duplicate records.
2. Superseded or contradicted guidance.
3. Closed, waiting, stale, or orphaned outcomes and loops.
4. Reusable memory that should be promoted, merged, archived, or marked low-retrieval.
5. Evidence that should remain evidence and not become durable memory.

### 5. Decision Pass

Classify every candidate:

1. Promote to durable memory.
2. Update existing record.
3. Keep active.
4. Keep as reference.
5. Merge.
6. Archive or mark low-retrieval.
7. Supersede.
8. Close or reopen.
9. Discard/no future consequence.
10. Approval required.

### 6. Approval Pass

Separate safe recommendations from gated changes. Create approval items for changes that affect future retrieval, judgment, career/project history, or policy.

## Durable Promotion Threshold

Promote evidence only when it changes future action, retrieval, judgment, or reuse.

Promote when at least one is true:

1. It changes an active outcome or execution path.
2. It is an open commitment or closure with future accountability.
3. It captures durable rationale or a decision that should prevent re-litigating.
4. It is a repeated or reusable asset, pattern, prompt, deck, workflow, or lesson.
5. It is career-grade evidence or durable career direction.
6. It changes how to work with a durable stakeholder.
7. It should be retrieved in future similar work.

Everything else remains evidence.

## Approval Gates

Ask before:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Promoting durable outcomes, reusable memory, people context, decisions, patterns, or assets.
4. Closing or reopening outcomes.
5. Closing ambiguous commitments.
6. Resolving conflicting evidence.
7. Archiving, merging, disregarding, deleting, or superseding durable records.
8. Changing ontology, retrieval policy, approval routing, or skill behavior.

Approval items live in `memory/governance/approvals/YYYY-MM-DD.md`.

## Output Format

Return a maintenance report:

```markdown
## Maintenance Mode

[promote | steward | scoped-maintenance | monthly-compression]

## Inputs Reviewed

- [Files/evidence sources]

## Recommended Changes

| Candidate | Recommendation | Why | Approval needed? |
| --- | --- | --- | --- |

## Safe Updates

- [Only changes that can be applied without approval, if any]

## Approval-Gated Items

- [Decision required, recommended answer, evidence, default if no answer]

## Left Unchanged

- [Important things intentionally not changed]
```

## Safety

Never store secrets or raw messages. Never delete memory automatically. Never treat semantic search as proof. Prefer fewer, higher-signal durable records over ontology expansion.
