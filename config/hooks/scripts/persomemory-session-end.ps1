<#
.SYNOPSIS
  PersoMemory session-end hook for Copilot CLI (Windows).
  Logs session end event, queues review items, and runs cleanup.
#>
param()

$ErrorActionPreference = 'Stop'

$hookInput = [Console]::In.ReadToEnd()
try { $parsed = $hookInput | ConvertFrom-Json } catch { $parsed = @{} }

$transcriptRetentionDays = 14
$reviewRetentionDays = 30
$eventLogRetentionDays = 30

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

function Invoke-PruneDirectory([string]$Dir, [int]$RetentionDays) {
    if (-not (Test-Path $Dir)) { return }
    $cutoff = (Get-Date).AddDays(-$RetentionDays)
    Get-ChildItem $Dir -File | Where-Object { $_.LastWriteTime -lt $cutoff } | Remove-Item -Force
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

function Invoke-Cleanup([string]$BaseDir) {
    try {
        Invoke-PruneDirectory -Dir (Join-Path $BaseDir 'session-transcripts') -RetentionDays $transcriptRetentionDays
        Invoke-PruneDirectory -Dir (Join-Path $BaseDir 'session-reviews') -RetentionDays $reviewRetentionDays
        Invoke-PruneJsonl -FilePath (Join-Path $BaseDir 'session-start-events.jsonl') -RetentionDays $eventLogRetentionDays
        Invoke-PruneJsonl -FilePath (Join-Path $BaseDir 'agent-stop-events.jsonl') -RetentionDays $eventLogRetentionDays
        Invoke-PruneJsonl -FilePath (Join-Path $BaseDir 'session-end-events.jsonl') -RetentionDays $eventLogRetentionDays
    } catch {
        New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
        Add-Content -Path (Join-Path $BaseDir 'cleanup-errors.log') `
            -Value "$((Get-Date).ToUniversalTime().ToString('o')) $_" -Encoding UTF8
    }
}

$baseDir = Get-DataHome
$queueDir = Join-Path $baseDir 'session-reviews'
New-Item -ItemType Directory -Path $queueDir -Force | Out-Null

$sessionId = if ($parsed.sessionId) { $parsed.sessionId }
             elseif ($parsed.session_id) { $parsed.session_id }
             else { 'unknown-session' }

$transcriptInfoPath = Join-Path (Join-Path $baseDir 'session-transcripts') "$sessionId.json"
$transcriptInfo = @{}
if (Test-Path $transcriptInfoPath) {
    try { $transcriptInfo = Get-Content $transcriptInfoPath -Raw | ConvertFrom-Json } catch { $transcriptInfo = @{} }
}

$transcriptPath = if ($transcriptInfo.transcriptPath) { $transcriptInfo.transcriptPath } else { '' }
$reason = if ($parsed.reason) { $parsed.reason } else { '' }
$cwd = if ($parsed.cwd) { $parsed.cwd } else { '' }

$ts = if ($parsed.timestamp) { $parsed.timestamp } else { (Get-Date).ToUniversalTime().ToString('o') }
$date = ([datetime]::Parse($ts)).ToString('yyyy-MM-dd')

$event = @{
    recordedAt     = (Get-Date).ToUniversalTime().ToString('o')
    sessionId      = $sessionId
    cwd            = $cwd
    reason         = $reason
    transcriptPath = $transcriptPath
    source         = 'copilot-sessionEnd-hook'
} | ConvertTo-Json -Compress

Add-Content -Path (Join-Path $baseDir 'session-end-events.jsonl') -Value $event -Encoding UTF8

if ($transcriptPath) {
    $reviewPath = Join-Path $queueDir "$date.md"
    $needsHeader = -not (Test-Path $reviewPath) -or (Get-Item $reviewPath).Length -eq 0

    $lines = @()
    if ($needsHeader) {
        $lines += "# Pending PersoMemory session reviews for $date"
        $lines += ''
    }
    $lines += "- Session $sessionId ended with reason: $(if ($reason) { $reason } else { 'unknown' })"
    $lines += '  - status: pending'
    $lines += "  - cwd: $(if ($cwd) { $cwd } else { 'unknown' })"
    $lines += "  - transcript: $transcriptPath"
    $lines += '  - source: copilot-sessionEnd-hook'
    $lines += '  - This is a pointer-only review item, not memory.'
    $lines += ''

    Add-Content -Path $reviewPath -Value ($lines -join "`n") -Encoding UTF8
}

Invoke-Cleanup -BaseDir $baseDir
Write-Output '{}'
