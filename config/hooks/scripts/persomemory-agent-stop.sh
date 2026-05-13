#!/usr/bin/env bash
set -euo pipefail

HOOK_INPUT="$(cat)"
export HOOK_INPUT

node <<'NODE'
const fs = require('fs');
const os = require('os');
const path = require('path');

let input = {};
try {
  input = JSON.parse(process.env.HOOK_INPUT || '{}');
} catch {
  input = {};
}

const sessionId = input.sessionId || input.session_id;
const transcriptPath = input.transcriptPath || input.transcript_path;

if (!sessionId || !transcriptPath) {
  process.stdout.write('{}');
  process.exit(0);
}

const baseDir = path.join(os.homedir(), '.copilot', 'plugin-data', 'persomemory');
const transcriptDir = path.join(baseDir, 'session-transcripts');
fs.mkdirSync(transcriptDir, { recursive: true });

const event = {
  recordedAt: new Date().toISOString(),
  sessionId,
  cwd: input.cwd || '',
  transcriptPath,
  stopReason: input.stopReason || input.stop_reason || '',
};

fs.writeFileSync(
  path.join(transcriptDir, `${sessionId}.json`),
  JSON.stringify(event, null, 2),
  'utf8'
);

process.stdout.write('{}');
NODE
