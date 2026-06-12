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

const baseDir = path.resolve(
  process.env.PERSOMEMORY_DATA_HOME
    || (process.env.XDG_DATA_HOME
      ? path.join(process.env.XDG_DATA_HOME, 'persomemory')
      : path.join(os.homedir(), '.local', 'share', 'persomemory'))
);
const sessionId = input.sessionId || input.session_id;
const transcriptPath =
  input.transcriptPath ||
  input.transcript_path ||
  input.transcript?.path ||
  input.transcript?.filePath ||
  input.transcript?.file_path ||
  input.conversation?.transcriptPath ||
  input.conversation?.transcript_path ||
  '';
const stopReason = input.stopReason || input.stop_reason || '';

fs.mkdirSync(baseDir, { recursive: true });
fs.appendFileSync(
  path.join(baseDir, 'agent-stop-events.jsonl'),
  `${JSON.stringify({
    recordedAt: new Date().toISOString(),
    sessionId: sessionId || '',
    cwd: input.cwd || '',
    stopReason,
    hasTranscriptPath: Boolean(transcriptPath),
    inputKeys: Object.keys(input).sort(),
  })}\n`,
  'utf8'
);

if (!sessionId || !transcriptPath) {
  process.stdout.write('{}');
  process.exit(0);
}

const transcriptDir = path.join(baseDir, 'session-transcripts');
fs.mkdirSync(transcriptDir, { recursive: true });

const event = {
  recordedAt: new Date().toISOString(),
  sessionId,
  cwd: input.cwd || '',
  transcriptPath,
  stopReason,
};

fs.writeFileSync(
  path.join(transcriptDir, `${sessionId}.json`),
  JSON.stringify(event, null, 2),
  'utf8'
);

process.stdout.write('{}');
NODE
