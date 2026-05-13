#!/usr/bin/env bash
set -euo pipefail

HOOK_INPUT="$(cat)"
export HOOK_INPUT

node <<'NODE'
const fs = require('fs');
const os = require('os');
const path = require('path');

const vaultPath = process.env.PERSOMEMORY_VAULT_PATH || '';
const maxCharsPerFile = Number(process.env.PERSOMEMORY_HOOK_MAX_CHARS || 6000);
const EVENT_LOG_RETENTION_DAYS = 30;

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

function readIfExists(relativePath) {
  if (!vaultPath) return null;
  const absolutePath = path.join(vaultPath, relativePath);
  if (!fs.existsSync(absolutePath)) return null;
  const content = fs.readFileSync(absolutePath, 'utf8');
  return {
    path: relativePath,
    content: content.length > maxCharsPerFile
      ? `${content.slice(0, maxCharsPerFile)}\n\n[Truncated by PersoMemory sessionStart hook]`
      : content,
  };
}

function writeDiagnosticEvent(input, files) {
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
      filesLoaded: files.map(file => file.path),
      additionalContext: files.length > 0,
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

const files = [
  readIfExists('MEMORY.md'),
  readIfExists('memory/active/now.md'),
  readIfExists('memory/commitments/open-loops.md'),
].filter(Boolean);

writeDiagnosticEvent(input, files);

if (files.length === 0) {
  process.stdout.write('{}');
  process.exit(0);
}

const context = [
  'PersoMemory startup context loaded by sessionStart hook.',
  '',
  'Use this as background context only. Do not write to memory because this hook ran.',
  'For PersoMemory work, prefer the persomemory-agent and the persomemory skill.',
  `Session source: ${input.source || 'unknown'}`,
  `Session cwd: ${input.cwd || 'unknown'}`,
  '',
  ...files.flatMap(file => [
    `## ${file.path}`,
    '',
    file.content,
    '',
  ]),
].join('\n');

process.stdout.write(JSON.stringify({ additionalContext: context }));
NODE
