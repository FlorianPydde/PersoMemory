# PersoMemory Evening Sweep

Use the persomemory-agent.

Sweep today using both evidence streams and update memory.

Before querying evidence, load:

1. `memory/active/now.md`
2. `memory/commitments/open-loops.md`
3. `memory/PROJECTS.md`

Ask WorkIQ for evidence only. Do not let WorkIQ decide career impact or memory routing.

Then read pending Copilot conversation pointers from:

```text
~/.local/share/persomemory/session-reviews/
```

Read referenced Copilot transcripts when available. Treat them as evidence only.

Capture only:

1. State changes.
2. Commitments and closures.
3. Decisions and rationale.
4. Durable people signals.
5. Evidence of impact.
6. Reusable assets.
7. Emerging patterns.
8. Promotion candidates.

Deduplicate WorkIQ evidence and Copilot conversation evidence against current vault state before writing.

Write or merge `memory/daily/YYYY-MM-DD.md`.

Route operational changes to:

1. `memory/active/now.md`
2. `memory/commitments/open-loops.md`

Mark processed local conversation queue entries as reviewed or superseded when permissions allow. If not, rely on deduplication and local retention cleanup.

Then run `lifecycle_check(stale_days=14, loop_age_days=14)`.

If running interactively, ask only at approval gates:

1. Closing projects.
2. Closing ambiguous commitments.
3. Promoting durable memory.
4. Creating career evidence.
5. Editing `MEMORY.md`.
6. Resolving conflicting evidence.
7. Capturing potentially sensitive content.

If running unattended via `copilot -p`, do not ask. Write approval-gated decisions to:

```text
memory/inbox/approvals/YYYY-MM-DD.md
```

Use sections for project closures, commitment closures, durable promotions, career evidence candidates, sensitive or ambiguous items, discard recommendations, and sweep failures.
