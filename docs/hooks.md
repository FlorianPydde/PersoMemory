# Copilot CLI Hooks for PersoMemory

## Position

Hooks are optional orchestration aids. They should not be the main memory system.

Use global Copilot instructions, the PersoMemory skill, the PersoMemory agent, and MCP configuration for generic behavior. Use hooks only for lightweight session orchestration.

## User-level hooks

Copilot CLI supports user-level hooks in `~/.copilot/hooks/*.json`. PersoMemory installs a user-level hook file:

```text
~/.copilot/hooks/persomemory-session.json
```

The hook does two things:

1. `sessionStart`: injects `MEMORY.md`, `memory/active/now.md`, and `memory/commitments/open-loops.md` as background context.
2. `agentStop`: records the latest transcript path for the session.
3. `sessionEnd`: records a lightweight pending session review entry under `~/.copilot/plugin-data/persomemory/`.

The session end hook deliberately does not write memory. Closing a session with Ctrl+C can fire `sessionEnd`, but the session is ending, so the hook cannot naturally continue the same conversation. It can run a command, log state, or queue a review for the next PersoMemory run. The preceding `agentStop` hook captures the transcript path so a later review has evidence to inspect.

## Why not put hooks in every work repo?

Copilot CLI also loads hook configuration from `.github/hooks/*.json` in the current repository. A hook in an unrelated project makes memory behavior look project-specific and can accidentally become cloud-agent behavior if committed to that repo.

The correct generic setup is:

1. Global Copilot instructions define memory behavior.
2. MCP config exposes WorkIQ, MCPVault, Smart Connections, and persomemory-lifecycle.
3. The persomemory-agent operates the routine.
4. User-level hooks load lightweight context and queue session reviews.
5. Work repos stay free of memory-system hooks unless intentionally opted in.

## Session start context hook

The installed session start hook uses `additionalContext`, not an auto-submitted prompt. This keeps startup quiet while still making memory context available.

Source files:

1. `config/hooks/persomemory-session.json`
2. `config/hooks/scripts/persomemory-session-start.sh`
3. `config/hooks/scripts/persomemory-agent-stop.sh`
4. `config/hooks/scripts/persomemory-session-end.sh`

## Source

GitHub documentation states that Copilot CLI hook configuration files are loaded from user-level `~/.copilot/hooks/*.json`, repository `.github/hooks/*.json`, inline settings, and plugin hooks. `sessionStart` can inject `additionalContext` or use a prompt hook. `sessionEnd` can run a command and receives the reason, including `user_exit`.

References:

1. https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks
2. https://docs.github.com/en/copilot/reference/hooks-reference
