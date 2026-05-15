# Session Naming

At the start of every new session, suggest a session name based on context:

1. If inside a git repository, use `proj:<repo-name>`.
2. If in a specific directory but not a git repository, use `dir:<directory-name>`.
3. If the task is general or not tied to a directory, use `misc`.

Offer to run `/rename <name>`.

# General Conventions

1. Never use dashes (-) unless required in code files, commands, paths, or Markdown syntax.
2. Never use emojis.

# PersoMemory Router

PersoMemory is Florian's personal memory system.

Use PersoMemory only when the user asks about personal memory, WorkIQ daily sweeps, memory writes, Obsidian vault recall, active context, commitments, dreaming, consolidation, or PersoMemory setup.

When PersoMemory is in scope, invoke the `persomemory` skill before acting. Treat `~/.copilot/skills/persomemory/SKILL.md` as the source of truth for retrieval, writes, routing, approval gates, graph rules, WorkIQ evidence bundles, and career evidence.

Use the skill prompt files for specific workflows:

1. Morning brief: `~/.copilot/skills/persomemory/prompts/morning-brief.md`.
2. Daily or end of day sweep: `~/.copilot/skills/persomemory/prompts/evening-sweep.md`.
3. Weekly consolidation or dreaming: `~/.copilot/skills/persomemory/prompts/weekly-consolidation.md`.

Do not duplicate or infer detailed PersoMemory behavior from this file. Load the skill instead.

# PersoMemory Locations

1. Active vault: `/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/ObsidianVaultPersoMemory`.
2. Recovery repo: `/mnt/c/Users/flpydde/OneDrive - Microsoft/ProjectArchive/PersoMemory`.
3. Local runtime skill: `/home/flpydde/.copilot/skills/persomemory/SKILL.md`.

The recovery repo is the replication source for reinstalling the local setup on another machine. When changing runtime assets, update source files in the repo first, then run `bash ./scripts/test-runtime.sh` and `bash ./scripts/install.sh`.

# Memory Safety

1. Do not write to memory just because startup context was loaded.
2. WorkIQ output is evidence only until routed by the PersoMemory skill.
3. Never store credentials, tokens, or secrets.
