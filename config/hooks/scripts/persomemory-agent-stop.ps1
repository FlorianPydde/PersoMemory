<#
.SYNOPSIS
  PersoMemory agent-stop hook for Copilot CLI (Windows).
  Records transcript path when an agent stops.
#>
param()

$ErrorActionPreference = 'Stop'

$hookInput = [Console]::In.ReadToEnd()
try { $parsed = $hookInput | ConvertFrom-Json } catch { $parsed = @{} }

function Get-DataHome {
    $configured = if ($env:PERSOMEMORY_DATA_HOME) { $env:PERSOMEMORY_DATA_HOME } else {
        Join-Path $env:USERPROFILE '.local\share\persomemory'
    }
    $resolved = [System.IO.Path]::GetFullPath($configured)
    $root = [System.IO.Path]::GetPathRoot($resolved)
    $homeDir = [System.IO.Path]::GetFullPath($env:USERPROFILE)
    if ($resolved -eq $root -or $resolved -eq $homeDir) {
        throw "Refusing unsafe PERSOMEMORY_DATA_HOME: $resolved"
    }
    return $resolved
}

$baseDir = Get-DataHome
New-Item -ItemType Directory -Path $baseDir -Force | Out-Null

$sessionId = if ($parsed.sessionId) { $parsed.sessionId }
             elseif ($parsed.session_id) { $parsed.session_id }
             else { '' }

$transcriptPath = if ($parsed.transcriptPath) { $parsed.transcriptPath }
                  elseif ($parsed.transcript_path) { $parsed.transcript_path }
                  elseif ($parsed.transcript -and $parsed.transcript.path) { $parsed.transcript.path }
                  elseif ($parsed.transcript -and $parsed.transcript.filePath) { $parsed.transcript.filePath }
                  elseif ($parsed.transcript -and $parsed.transcript.file_path) { $parsed.transcript.file_path }
                  elseif ($parsed.conversation -and $parsed.conversation.transcriptPath) { $parsed.conversation.transcriptPath }
                  elseif ($parsed.conversation -and $parsed.conversation.transcript_path) { $parsed.conversation.transcript_path }
                  else { '' }

$stopReason = if ($parsed.stopReason) { $parsed.stopReason }
              elseif ($parsed.stop_reason) { $parsed.stop_reason }
              else { '' }

$inputKeys = @($parsed.PSObject.Properties.Name | Sort-Object)

$agentEvent = @{
    recordedAt       = (Get-Date).ToUniversalTime().ToString('o')
    sessionId        = $sessionId
    cwd              = if ($parsed.cwd) { $parsed.cwd } else { '' }
    stopReason       = $stopReason
    hasTranscriptPath = [bool]$transcriptPath
    inputKeys        = $inputKeys
} | ConvertTo-Json -Compress

Add-Content -Path (Join-Path $baseDir 'agent-stop-events.jsonl') -Value $agentEvent -Encoding UTF8

if (-not $sessionId -or -not $transcriptPath) {
    Write-Output '{}'
    exit 0
}

$transcriptDir = Join-Path $baseDir 'session-transcripts'
New-Item -ItemType Directory -Path $transcriptDir -Force | Out-Null

$event = @{
    recordedAt     = (Get-Date).ToUniversalTime().ToString('o')
    sessionId      = $sessionId
    cwd            = if ($parsed.cwd) { $parsed.cwd } else { '' }
    transcriptPath = $transcriptPath
    stopReason     = $stopReason
}

$event | ConvertTo-Json | Set-Content (Join-Path $transcriptDir "$sessionId.json") -Encoding UTF8

Write-Output '{}'
