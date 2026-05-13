# PersoMemory Evening Sweep

Run this workflow in the current session when MCP tools are available.

Do not delegate this workflow to a nested subagent from an interactive Copilot session. Nested delegated agents may not inherit WorkIQ, MCPVault, Smart Connections, or persomemory-lifecycle access. Use `persomemory-agent` only when it is the top-level selected agent, for example through `copilot --agent persomemory-agent`.

Do not use scheduled prompt tools during a sweep. Scheduling is configured separately.

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

Read referenced Copilot transcripts when available. Treat them as evidence only. Skip any queue item whose transcript is missing, empty, or `not captured`; that is a diagnostic artifact, not reviewable evidence.

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

If `memory/daily/YYYY-MM-DD.md` does not exist yet, create it from the daily note schema. Treat that as normal empty-state behavior, not a failure.

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

If `memory/inbox/approvals/` does not exist and there are no approval-gated items, treat it as an empty inbox. If approval-gated items exist, create the directory and write them to:

```text
memory/inbox/approvals/YYYY-MM-DD.md
```

If running unattended via `copilot -p`, do not ask. Write approval-gated decisions to the same approval inbox path.

Use sections for project closures, commitment closures, durable promotions, career evidence candidates, sensitive or ambiguous items, discard recommendations, and sweep failures.
