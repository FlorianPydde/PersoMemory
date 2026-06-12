<#
.SYNOPSIS
  PersoMemory session-start hook for Copilot CLI (Windows).
  Logs a diagnostic event when a Copilot session begins.
#>
param()

$ErrorActionPreference = 'Stop'

$hookInput = [Console]::In.ReadToEnd()
try { $parsed = $hookInput | ConvertFrom-Json } catch { $parsed = @{} }

$vaultPath = if ($env:PERSOMEMORY_VAULT_PATH) { $env:PERSOMEMORY_VAULT_PATH } else { '' }
$skills = @('memory', 'memory-brief', 'memory-sweep', 'memory-maintenance')
$retentionDays = 30

function Get-DataHome {
    $configured = if ($env:PERSOMEMORY_DATA_HOME) { $env:PERSOMEMORY_DATA_HOME } else {
        Join-Path $env:LOCALAPPDATA 'persomemory'
    }
    $resolved = [System.IO.Path]::GetFullPath($configured)
    $root = [System.IO.Path]::GetPathRoot($resolved)
    $homeDir = [System.IO.Path]::GetFullPath($env:USERPROFILE)
    if ($resolved -eq $root -or $resolved -eq $homeDir) {
        throw "Refusing unsafe PERSOMEMORY_DATA_HOME: $resolved"
    }
    return $resolved
}

function Invoke-PruneJsonl([string]$FilePath, [int]$RetentionDays) {
    if (-not (Test-Path $FilePath)) { return }
    $cutoff = (Get-Date).AddDays(-$RetentionDays)
    $retained = @()
    foreach ($line in Get-Content $FilePath) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $evt = $line | ConvertFrom-Json
            $ts = $evt.recordedAt
            if (-not $ts) { $ts = $evt.timestamp }
            if ($ts) {
                $recordedAt = [datetime]::Parse($ts)
                if ($recordedAt -lt $cutoff) { continue }
            }
        } catch {
            # Keep malformed lines
        }
        $retained += $line
    }
    if ($retained.Count -gt 0) {
        $retained | Set-Content $FilePath -Encoding UTF8
    } else {
        Set-Content $FilePath '' -Encoding UTF8
    }
}

try {
    $baseDir = Get-DataHome
    New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
    $eventLogPath = Join-Path $baseDir 'session-start-events.jsonl'

    $sessionId = if ($parsed.sessionId) { $parsed.sessionId } elseif ($parsed.session_id) { $parsed.session_id } else { '' }
    $source = if ($parsed.source) { $parsed.source } else { '' }
    $cwd = if ($parsed.cwd) { $parsed.cwd } else { '' }

    $event = @{
        recordedAt          = (Get-Date).ToUniversalTime().ToString('o')
        sessionId           = $sessionId
        source              = $source
        cwd                 = $cwd
        vaultPath           = $vaultPath
        filesLoaded         = @()
        memoryContentLoaded = $false
        availableSkills     = $skills
        additionalContext   = $false
        sourceHook          = 'copilot-sessionStart-hook'
    } | ConvertTo-Json -Compress

    Add-Content -Path $eventLogPath -Value $event -Encoding UTF8
    Invoke-PruneJsonl -FilePath $eventLogPath -RetentionDays $retentionDays
} catch {
    [Console]::Error.WriteLine("PersoMemory sessionStart diagnostics failed: $_")
}

Write-Output '{}'
