# Copilot CLI Hooks for PersoMemory

## Position

Hooks are optional orchestration aids. They should not be the main memory system.

Use global Copilot instructions and MCP configuration for generic behavior. Use hooks only when a repository should actively influence sessions started from that repository.

## Why not put hooks in every work repo?

Copilot CLI loads hook configuration from `.github/hooks/*.json` in the current repository. A hook in an unrelated project makes memory behavior look project-specific and can accidentally become cloud-agent behavior if committed to that repo.

The correct generic setup is:

1. Global Copilot instructions define memory behavior.
2. MCP config exposes WorkIQ, MCPVault, and Smart Connections.
3. PersoMemory documents optional hook templates.
4. Work repos stay free of memory-system hooks unless intentionally opted in.

## Optional Session Start Hook Template

Use this only in PersoMemory or another repo where memory bootstrapping is intentional.

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "type": "prompt",
        "prompt": "Before working on user tasks in this interactive session, load personal memory context from the Obsidian vault. Read MEMORY.md, memory/active/now.md, and memory/commitments/open-loops.md. Use Smart Connections or MCPVault search only for topic-specific context. Treat memory/daily as episodic evidence, not durable memory."
      }
    ]
  }
}
```

## Source

GitHub documentation states that Copilot CLI hook configuration files are loaded from `.github/hooks/*.json` in the current repository, and that prompt hooks are supported only on `sessionStart` for new interactive sessions.

References:

1. https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks
2. https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-hooks-reference
