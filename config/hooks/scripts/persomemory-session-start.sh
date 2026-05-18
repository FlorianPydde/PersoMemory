#!/usr/bin/env bash
set -euo pipefail

HOOK_INPUT="$(cat)"
export HOOK_INPUT

node <<'NODE'
const fs = require('fs');
const os = require('os');
const path = require('path');

const vaultPath = process.env.PERSOMEMORY_VAULT_PATH || '';
const EVENT_LOG_RETENTION_DAYS = 30;
const skills = ['memory', 'memory-brief', 'memory-sweep', 'memory-maintenance'];

function resolveDataHome() {
  const configured = process.env.PERSOMEMORY_DATA_HOME || path.join(os.homedir(), '.local', 'share', 'persomemory');
  const resolved = path.resolve(configured);
  const root = path.parse(resolved).root;
  const home = path.resolve(os.homedir());
  if (resolved === root || resolved === home) {
    throw new Error(`Refusing unsafe PERSOMEMORY_DATA_HOME: ${resolved}`);
  }
  return resolved;
}

function pruneJsonl(filePath, retentionDays) {
  if (!fs.existsSync(filePath)) return;
  const cutoff = Date.now() - retentionDays * 24 * 60 * 60 * 1000;
  const retained = [];
  for (const line of fs.readFileSync(filePath, 'utf8').split('\n')) {
    if (!line.trim()) continue;
    try {
      const event = JSON.parse(line);
      const recordedAt = Date.parse(event.recordedAt || event.timestamp || '');
      if (!Number.isNaN(recordedAt) && recordedAt < cutoff) continue;
    } catch {
      retained.push(line);
      continue;
    }
    retained.push(line);
  }
  fs.writeFileSync(filePath, retained.length > 0 ? `${retained.join('\n')}\n` : '', 'utf8');
}

function writeDiagnosticEvent(input) {
  try {
    const baseDir = resolveDataHome();
    fs.mkdirSync(baseDir, { recursive: true });
    const eventLogPath = path.join(baseDir, 'session-start-events.jsonl');
    const event = {
      recordedAt: new Date().toISOString(),
      sessionId: input.sessionId || input.session_id || '',
      source: input.source || '',
      cwd: input.cwd || '',
      vaultPath,
      filesLoaded: [],
      memoryContentLoaded: false,
      availableSkills: skills,
      additionalContext: false,
      sourceHook: 'copilot-sessionStart-hook',
    };
    fs.appendFileSync(eventLogPath, `${JSON.stringify(event)}\n`, 'utf8');
    pruneJsonl(eventLogPath, EVENT_LOG_RETENTION_DAYS);
  } catch (error) {
    process.stderr.write(`PersoMemory sessionStart diagnostics failed: ${error.message}\n`);
  }
}

let input = {};
try {
  input = JSON.parse(process.env.HOOK_INPUT || '{}');
} catch {
  input = {};
}

writeDiagnosticEvent(input);

// No additionalContext injected. Skills self-advertise via their description
// frontmatter, and copilot-instructions.md already carries the routing rules.
// Injecting routing text here caused skill(memory) failures when the skill
// was not yet installed, and duplicated guidance the model already has.
process.stdout.write(JSON.stringify({}));
NODE
