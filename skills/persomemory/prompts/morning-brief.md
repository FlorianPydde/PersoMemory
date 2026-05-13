# PersoMemory Morning Brief

Use the persomemory-agent.

Load the minimum memory context:

1. `MEMORY.md`
2. `memory/active/now.md`
3. `memory/commitments/open-loops.md`

If hook-loaded PersoMemory startup context is already present, use it instead of reloading unless it is stale.

Then run `lifecycle_check(stale_days=14, loop_age_days=14)`.

Return:

1. Top 3 focus areas for today.
2. Open follow ups that matter today.
3. Stale projects or overdue reviews.
4. One risk Florian may be underweighting.
5. One question: "What is the one outcome that makes today successful?"

Do not write to memory unless Florian explicitly approves.
