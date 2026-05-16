---
name: memory-brief
description: Produces a broad day-level executive memory brief. Use only for whole-day or whole-work prompts such as morning brief, start my day, what matters today, today's focus across all work, open loops that matter today, stale items, or pending approvals. Do not use for named project/person/topic-scoped focus like "I am working on Phoenix"; route scoped or mixed prompts through the memory router.
---

# Memory Brief

## Purpose

Produce a concise attention view for the day across active work. This skill orients focus; it does not ingest new WorkIQ evidence and does not perform memory maintenance.

## Boundary

Use this skill for broad day-level attention only.

If the user names a project, person, customer, topic, or artifact and asks what to focus on, stop and route through `memory` so the attention view can be scoped.

Examples that belong here:

1. "Morning brief."
2. "What should I focus on today?"
3. "Start my day."
4. "What open loops matter today?"

Examples that do not belong here:

1. "I am working on Phoenix. What should I focus on today?"
2. "What should I focus on for OTP?"
3. "Bring me up to speed on PL."

## Inputs

Load only the context needed for a broad attention view:

1. `views/active-now.md`.
2. `execution/open-loops.md`.
3. Pending approval files in `governance/approvals/`, if any.
4. Recent unresolved maintenance reports in `governance/maintenance/`, if any.
5. `governance/preferences/approval-routing.md`, if it exists.
6. `governance/ontology/contract.md` only if approval routing or memory category decisions are needed.

Run persomemory-lifecycle checks when available to surface stale outcomes and aged open loops.

Do not load daily notes by default. Use daily/evidence notes only when the user asks for chronology, proof, or a specific date.

## Workflow

1. Build the attention view from active outcomes, open execution, pending approvals, and stale/waiting items.
2. Prefer items that are urgent, important, blocked, waiting on someone, or at risk of being forgotten.
3. Separate focus from background context.
4. Do not write to memory unless Florian explicitly asks or approves an approval item.

## Output Format

Return a concise brief:

```markdown
## Today's Focus

1. [Outcome or execution item] - why it matters today.
2. ...

## Open Loops That Matter

- [Commitment] - owner, timing, source if known.

## Waiting / Stale / Blocked

- [Item] - what is waiting or stale.

## Pending Approvals

- [Approval] - recommended action.

## Watchpoint

- One risk or blind spot Florian may be underweighting.
```

Keep it short. The goal is executive attention, not exhaustive recall.

## Safety

Never store secrets or raw messages. Do not apply maintenance recommendations, close loops, or create career evidence without approval.
