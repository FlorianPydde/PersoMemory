# Copilot CLI Hooks for PersoMemory

## Position

Hooks are optional orchestration aids. They should not be the main memory system.

Use global Copilot instructions, the PersoMemory skill, the PersoMemory agent, and MCP configuration for generic behavior. Use hooks only for lightweight session orchestration.

## User-level hooks

Copilot CLI supports user-level hooks in `~/.copilot/hooks/*.json`. PersoMemory installs a user-level hook file:

```text
~/.copilot/hooks/persomemory-session.json
```

The hook does three things:

1. `sessionStart`: injects `MEMORY.md`, `memory/active/now.md`, and `memory/commitments/open-loops.md` as background context.
2. `agentStop`: records the latest transcript path for the session.
3. `sessionEnd`: records a lightweight pending session review entry under `~/.local/share/persomemory/session-reviews/`.

The session end hook deliberately does not write memory. Closing a session with Ctrl+C can fire `sessionEnd`, but the session is ending, so the hook cannot naturally continue the same conversation. It can run a command, log state, or queue a review for the next PersoMemory run. The preceding `agentStop` hook captures the transcript path so a later review has evidence to inspect.

## Local queue storage

Hook generated runtime state lives outside `~/.copilot/plugin-data` because PersoMemory is not a Copilot plugin.

Default location:

```text
~/.local/share/persomemory/
```

Directory layout:

```text
session-reviews/              Pointer-only review queue by date
session-transcripts/          Session id to transcript path breadcrumbs
session-start-events.jsonl    Diagnostics for startup context injection
agent-stop-events.jsonl       Lightweight diagnostics for transcript capture
session-end-events.jsonl      Lightweight diagnostics
cleanup-errors.log            Cleanup diagnostics, if needed
```

This directory is disposable local working state. It should not be copied to a new laptop. Durable memory belongs in the Obsidian vault.

The queue must be pointer-only. It should not contain extracted facts, conversation summaries, commitments, decisions, project status, or career evidence. If a session ends before a transcript breadcrumb is captured, the session end event is logged for diagnostics but no pending review item is created.

To verify startup context injection without reading Copilot internal logs:

```bash
tail ~/.local/share/persomemory/session-start-events.jsonl
```

An event with `additionalContext: true` and `filesLoaded` containing `MEMORY.md`, `memory/active/now.md`, and `memory/commitments/open-loops.md` means the hook ran and returned context. The context may be injected silently and not shown as a visible timeline message.

Directly invoking `~/.copilot/hooks/scripts/persomemory-session-start.sh` is only a script smoke test. The real Copilot hook gets `PERSOMEMORY_VAULT_PATH` from `~/.copilot/hooks/persomemory-session.json`; pass that environment variable yourself when testing the script outside Copilot.

## Conversation sweep

Copilot conversations are a second evidence source alongside WorkIQ:

| Evidence source | Intake process | Output |
| --- | --- | --- |
| Microsoft 365 activity | WorkIQ sweep | Daily note, active context, open loops, promotion candidates |
| Copilot conversations | Conversation sweep | Daily note, active context, open loops, promotion candidates |

The evening sweep should process both streams. WorkIQ covers external work activity. Copilot conversation sweep covers what happened in agent sessions.

Hooks only queue transcript pointers. The PersoMemory agent performs the actual conversation sweep, deduplicates against current vault state, and asks before durable or ambiguous changes.

The daily sweep skill must treat Copilot conversation evidence as a structured evidence bundle, not a shallow summary. For each queued session, it should classify coverage, then audit session context, outcome and loop closure, action items, decisions and rationale, direction-setting feedback, reusable assets and patterns, risks, and routing. This is what connects a Teams-raised loop to work completed later in a Copilot session without burying the closure in a transcript.

Queued missing, empty, unreadable, or `not captured` transcripts should become `Sweep Failures` approval items rather than silent skips. The hook itself remains pointer-only and does not decide memory meaning.

## Cleanup

The session end hook runs conservative cleanup under `~/.local/share/persomemory`:

1. Transcript breadcrumbs expire after 14 days.
2. Pending review files expire after 30 days.
3. Event log entries expire after 30 days.
4. Cleanup never touches the Obsidian vault.
5. Cleanup skips symlinks and only deletes regular files under the PersoMemory data directory.

## Why not put hooks in every work repo?

Copilot CLI also loads hook configuration from `.github/hooks/*.json` in the current repository. A hook in an unrelated project makes memory behavior look project-specific and can accidentally become cloud-agent behavior if committed to that repo.

The correct generic setup is:

1. Global Copilot instructions define memory behavior.
2. MCP config exposes WorkIQ, MCPVault, Smart Connections, and persomemory-lifecycle.
3. The persomemory-agent operates the routine.
4. User-level hooks load lightweight context and queue Copilot conversation review pointers.
5. Work repos stay free of memory-system hooks unless intentionally opted in.

## Session start context hook

The installed session start hook uses `additionalContext`, not an auto-submitted prompt. This keeps startup quiet while still making memory context available.

Source files:

1. `config/hooks/persomemory-session.json`
2. `config/hooks/scripts/persomemory-session-start.sh`
3. `config/hooks/scripts/persomemory-agent-stop.sh`
4. `config/hooks/scripts/persomemory-session-end.sh`

## Source

GitHub documentation states that Copilot CLI hook configuration files are loaded from user-level `~/.copilot/hooks/*.json`, repository `.github/hooks/*.json`, inline settings, and plugin hooks. `sessionStart` can inject `additionalContext` or use a prompt hook. `sessionEnd` can run a command and receives the reason, including `user_exit`. `agentStop` includes the transcript path, which is why PersoMemory uses it to create the transcript breadcrumb.

References:

1. https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks
2. https://docs.github.com/en/copilot/reference/hooks-reference
