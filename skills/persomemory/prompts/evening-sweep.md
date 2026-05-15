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

Run three separate WorkIQ evidence calls before merging or writing memory:

1. **Broad Evidence Scan**: reconstruct daily context, project movement, risks, people signals, reusable assets, and surprise items. This is not the action audit and not the direction-setting audit.
2. **Action Item Audit**: inspect meeting tasks, transcript action items, Teams asks, email asks, and shared-file comments for every concrete deliverable. Capture owner, expected output, due date or timing, format, source, confidence, and whether the action is explicit or inferred. Do not limit this pass to the top 3 to 5 signals.
3. **Direction Setting Audit**: inspect manager, mentor, leadership, and career conversations for guidance that changes future goals, role direction, positioning, exposure, skills, or behavior. Separate past-impact recognition from future direction.

Required WorkIQ call schemas:

1. **Broad Evidence Scan** must ask WorkIQ to look across calendar, meetings, transcripts, Teams chats, emails, shared files, and collaboration signals. It must return top signals, important interactions, high-level asks and commitments, leadership/manager/customer/partner signals, project movement, risks and weak signals, reusable knowledge, surprise items, and discarded low-value items. For each retained signal, include title, what happened, consequence, source type, people, projects or topics, and confidence.
2. **Action Item Audit** must ask WorkIQ for concrete action items only. It must return every visible ask or obligation with title, owner, expected output or artifact, due date or timing, source type and detail, people involved, project or topic, explicit or inferred status, confidence, and keep/discard reason. It must separately list still-open actions to mirror into open loops and ambiguous actions needing approval or clarification.
3. **Direction Setting Audit** must ask WorkIQ for direction-setting conversations only. It must return manager, mentor, leadership, customer, or partner guidance that changes future goals, role direction, positioning, exposure, skills, behaviors, or 1-3 year trajectory. For each signal, include who gave the signal, past-impact recognition if any, future direction or guidance, implication for goals/feedback/career evidence/active context/open loops, source type and detail, people, projects or topics, confidence, and whether it is approval-gated. It must separately list career direction or feedback candidates, career evidence candidates, ambiguous items, and discarded items.

Merge contract:

1. Run all three WorkIQ calls before routing memory.
2. Deduplicate across the three outputs and current vault state.
3. Preserve source attribution from the originating evidence call.
4. If one WorkIQ call fails, continue with the other evidence streams and write a Sweep Failures approval item.

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
9. Direction-setting career, role, or leadership guidance.

Deduplicate all three WorkIQ evidence outputs and Copilot conversation evidence against current vault state before writing.

If `memory/daily/YYYY-MM-DD.md` does not exist yet, create it from the daily note schema. Treat that as normal empty-state behavior, not a failure.

Route operational changes to:

1. `memory/active/now.md`
2. `memory/commitments/open-loops.md`

Do not bury actions in the daily note. Mirror every still-open concrete action into `memory/commitments/open-loops.md`, including one-slide summaries, review tasks, next-meeting deliverables, follow-ups, and delegated asks. If ownership, due timing, or obligation status is ambiguous, keep the daily evidence and write an approval inbox item instead of dropping it.

Do not collapse career conversations into a generic recognition signal. If a conversation includes future role guidance, capture it as a career direction or feedback candidate. If it is also strong proof for Connect or promotion, capture a separate career evidence candidate.

Mark processed local conversation queue entries as reviewed or superseded when permissions allow. If not, rely on deduplication and local retention cleanup.

Then run `lifecycle_check(stale_days=14, loop_age_days=14)`.

If running interactively, ask only at approval gates:

1. Editing `MEMORY.md`.
2. Creating career evidence.
3. Updating durable career goals or feedback from manager/mentor direction.
4. Promoting durable project, people, pattern, decision, or toolkit notes.
5. Closing projects.
6. Closing ambiguous commitments.
7. Resolving conflicting evidence.
8. Capturing potentially sensitive content.

If `memory/inbox/approvals/` does not exist and there are no approval-gated items, treat it as an empty inbox. If approval-gated items exist, create the directory and write them to:

```text
memory/inbox/approvals/YYYY-MM-DD.md
```

If running unattended via `copilot -p`, do not ask. Write approval-gated decisions to the same approval inbox path.

Use sections for project closures, commitment closures, durable promotions, career evidence candidates, Career Direction and Feedback Updates, sensitive or ambiguous items, discard recommendations, and sweep failures.
