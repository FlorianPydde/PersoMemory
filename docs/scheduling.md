# Scheduling PersoMemory

## Position

Scheduled PersoMemory jobs should be semi-autonomous. They may apply low-risk daily routing, but they must not make high-impact memory decisions without Florian approval.

## Evening sweep

Use the helper script:

```bash
scripts/run-evening-sweep.sh
```

The script runs:

1. WorkIQ daily evidence intake.
2. Copilot conversation evidence intake from `~/.local/share/persomemory/session-reviews/`.
3. Low-risk daily and operational memory routing.
4. Approval creation for gated decisions.

The helper starts `persomemory-agent` as the top-level selected Copilot agent. That is different from asking a normal interactive session to delegate to a nested subagent. Nested delegated agents may not inherit the parent session's MCP tools, even if those tools are listed in the agent markdown file.

Approval-gated decisions go to:

```text
memory/approvals/YYYY-MM-DD.md
```

## Tool permissions

Do not use `--yolo` or `--allow-all-tools` for unattended memory work by default.

The helper gives Copilot read access to the local queue directory and uses narrow tool permissions:

```bash
--add-dir ~/.local/share/persomemory
--allow-tool='read'
--allow-tool='workiq'
--allow-tool='mcpvault'
--allow-tool='smart-connections'
--allow-tool='persomemory-lifecycle'
--no-ask-user
```

This allows the agent to read pointer-only queue files and referenced local transcripts without granting shell, broad file write, or all-tools access. If this is not enough in practice, widen permissions deliberately and document why.

## Cron example

Edit crontab:

```bash
crontab -e
```

Run every weekday evening:

```cron
30 18 * * 1-5 /mnt/c/Users/flpydde/OneDrive\ -\ Microsoft/ProjectArchive/PersoMemory/scripts/run-evening-sweep.sh
```

If cron has trouble with spaces in the path, create a small wrapper in `~/.local/bin` that calls the script.

## Installed helper

`scripts/install.sh` installs a convenience wrapper here:

```text
~/.local/bin/persomemory-evening-sweep
```

Cron can call the installed helper with an absolute path:

```cron
30 18 * * 1-5 /home/flpydde/.local/bin/persomemory-evening-sweep
```

## Morning brief

The morning brief should read `memory/preferences/approval-routing.md`, then read pending approval notes from `memory/approvals/` and ask Florian to approve, reject, defer, or edit them.

This makes the overnight run useful without pretending that unattended approval happened.
