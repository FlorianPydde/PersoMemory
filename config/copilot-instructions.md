# General Conventions

1. Never use emojis.

# Memory Skill Router

When the user asks about personal memory, WorkIQ daily sweeps, memory writes, Obsidian vault recall, active context, commitments, dreaming, consolidation, stale memory, or memory cleanup, invoke the relevant memory skill before acting.

Use `memory-router` for ambiguous, mixed, scoped recall, capture, commitment, and focus requests. Use `memory-brief` for broad day-level focus. Use `memory-sweep` for WorkIQ or Copilot evidence intake. Use `memory-maintenance` for consolidation, stale review, archive, merge, supersede, and cleanup.

Detailed memory behavior belongs in the installed memory skills, not in this always loaded instruction file.

# Memory Safety

1. Do not write to memory just because a startup pointer was loaded.
2. WorkIQ output is evidence only until routed by the relevant memory skill.
3. Never store credentials, tokens, or secrets.
