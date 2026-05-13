# PersoMemory Evening Sweep

Use the persomemory-agent.

Sweep today with WorkIQ and update memory.

Before querying WorkIQ, load:

1. `memory/active/now.md`
2. `memory/commitments/open-loops.md`
3. `memory/PROJECTS.md`

Ask WorkIQ for evidence only. Do not let WorkIQ decide career impact or memory routing.

Capture only:

1. State changes.
2. Commitments and closures.
3. Decisions and rationale.
4. Durable people signals.
5. Evidence of impact.
6. Reusable assets.
7. Emerging patterns.
8. Promotion candidates.

Write or merge `memory/daily/YYYY-MM-DD.md`.

Route operational changes to:

1. `memory/active/now.md`
2. `memory/commitments/open-loops.md`

Then run `lifecycle_check(stale_days=14, loop_age_days=14)`.

Ask before closing projects, closing commitments, promoting durable memory, or editing `MEMORY.md`.
