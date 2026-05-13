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

const baseDir = path.join(os.homedir(), '.copilot', 'plugin-data', 'persomemory');
const queueDir = path.join(baseDir, 'pending-session-reviews');
fs.mkdirSync(queueDir, { recursive: true });

const date = new Date(input.timestamp || Date.now()).toISOString().slice(0, 10);
const sessionId = input.sessionId || input.session_id || 'unknown-session';
const event = {
  recordedAt: new Date().toISOString(),
  sessionId,
  cwd: input.cwd || '',
  reason: input.reason || '',
  source: 'copilot-sessionEnd-hook',
};

fs.appendFileSync(
  path.join(baseDir, 'session-end-events.jsonl'),
  `${JSON.stringify(event)}\n`,
  'utf8'
);

const reviewPath = path.join(queueDir, `${date}.md`);
const prompt = [
  `# Pending PersoMemory session reviews for ${date}`,
  '',
  `- Session ${sessionId} ended with reason: ${event.reason || 'unknown'}`,
  `  - cwd: ${event.cwd || 'unknown'}`,
  '  - Review only if Florian asks for session-end memory capture.',
  '  - Do not write memory automatically.',
  '',
].join('\n');

fs.appendFileSync(reviewPath, prompt, 'utf8');
process.stdout.write('{}');
NODE
