#!/usr/bin/env bash
set -euo pipefail

HOOK_INPUT="$(cat)"
export HOOK_INPUT

node <<'NODE'
const fs = require('fs');
const os = require('os');
const path = require('path');

const TRANSCRIPT_RETENTION_DAYS = 14;
const REVIEW_RETENTION_DAYS = 30;
const EVENT_LOG_RETENTION_DAYS = 30;

let input = {};
try {
  input = JSON.parse(process.env.HOOK_INPUT || '{}');
} catch {
  input = {};
}

function resolveDataHome() {
  const configured = process.env.PERSOMEMORY_DATA_HOME
    || (process.env.XDG_DATA_HOME
      ? path.join(process.env.XDG_DATA_HOME, 'persomemory')
      : path.join(os.homedir(), '.local', 'share', 'persomemory'));
  const resolved = path.resolve(configured);
  const root = path.parse(resolved).root;
  const home = path.resolve(os.homedir());
  if (resolved === root || resolved === home) {
    throw new Error(`Refusing unsafe PERSOMEMORY_DATA_HOME: ${resolved}`);
  }
  return resolved;
}

function daysAgo(days) {
  return Date.now() - days * 24 * 60 * 60 * 1000;
}

function pruneDirectory(dir, retentionDays) {
  if (!fs.existsSync(dir)) return;
  const cutoff = daysAgo(retentionDays);
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    const stat = fs.lstatSync(fullPath);
    if (!stat.isFile() || stat.isSymbolicLink()) continue;
    if (stat.mtimeMs < cutoff) fs.unlinkSync(fullPath);
  }
}

function pruneJsonl(filePath, retentionDays) {
  if (!fs.existsSync(filePath)) return;
  const cutoff = daysAgo(retentionDays);
  const retained = [];
  for (const line of fs.readFileSync(filePath, 'utf8').split('\n')) {
    if (!line.trim()) continue;
    try {
      const event = JSON.parse(line);
      const recordedAt = Date.parse(event.recordedAt || event.timestamp || '');
      if (!Number.isNaN(recordedAt) && recordedAt < cutoff) continue;
    } catch {
      // Keep malformed lines rather than risking data loss during cleanup.
    }
    retained.push(line);
  }
  fs.writeFileSync(filePath, retained.length > 0 ? `${retained.join('\n')}\n` : '', 'utf8');
}

function runCleanup(baseDir) {
  try {
    pruneDirectory(path.join(baseDir, 'session-transcripts'), TRANSCRIPT_RETENTION_DAYS);
    pruneDirectory(path.join(baseDir, 'session-reviews'), REVIEW_RETENTION_DAYS);
    pruneJsonl(path.join(baseDir, 'session-start-events.jsonl'), EVENT_LOG_RETENTION_DAYS);
    pruneJsonl(path.join(baseDir, 'agent-stop-events.jsonl'), EVENT_LOG_RETENTION_DAYS);
    pruneJsonl(path.join(baseDir, 'session-end-events.jsonl'), EVENT_LOG_RETENTION_DAYS);
  } catch (error) {
    fs.mkdirSync(baseDir, { recursive: true });
    fs.appendFileSync(
      path.join(baseDir, 'cleanup-errors.log'),
      `${new Date().toISOString()} ${error.message}\n`,
      'utf8'
    );
  }
}

const baseDir = resolveDataHome();
const queueDir = path.join(baseDir, 'session-reviews');
fs.mkdirSync(queueDir, { recursive: true });

const date = new Date(input.timestamp || Date.now()).toISOString().slice(0, 10);
const sessionId = input.sessionId || input.session_id || 'unknown-session';
const transcriptInfoPath = path.join(baseDir, 'session-transcripts', `${sessionId}.json`);
let transcriptInfo = {};
if (fs.existsSync(transcriptInfoPath)) {
  try {
    transcriptInfo = JSON.parse(fs.readFileSync(transcriptInfoPath, 'utf8'));
  } catch {
    transcriptInfo = {};
  }
}

const event = {
  recordedAt: new Date().toISOString(),
  sessionId,
  cwd: input.cwd || '',
  reason: input.reason || '',
  transcriptPath: transcriptInfo.transcriptPath || '',
  source: 'copilot-sessionEnd-hook',
};

fs.appendFileSync(
  path.join(baseDir, 'session-end-events.jsonl'),
  `${JSON.stringify(event)}\n`,
  'utf8'
);

if (event.transcriptPath) {
  const reviewPath = path.join(queueDir, `${date}.md`);
  const needsHeader = !fs.existsSync(reviewPath) || fs.statSync(reviewPath).size === 0;
  const prompt = [
    ...(needsHeader ? [`# Pending PersoMemory session reviews for ${date}`, ''] : []),
    `- Session ${sessionId} ended with reason: ${event.reason || 'unknown'}`,
    '  - status: pending',
    `  - cwd: ${event.cwd || 'unknown'}`,
    `  - transcript: ${event.transcriptPath}`,
    '  - source: copilot-sessionEnd-hook',
    '  - This is a pointer-only review item, not memory.',
    '',
  ].join('\n');

  fs.appendFileSync(reviewPath, prompt, 'utf8');
}
runCleanup(baseDir);
process.stdout.write('{}');
NODE
