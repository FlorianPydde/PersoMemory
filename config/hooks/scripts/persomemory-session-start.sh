#!/usr/bin/env bash
set -euo pipefail

HOOK_INPUT="$(cat)"
export HOOK_INPUT

node <<'NODE'
const fs = require('fs');
const path = require('path');

const vaultPath = process.env.PERSOMEMORY_VAULT_PATH || '';
const maxCharsPerFile = Number(process.env.PERSOMEMORY_HOOK_MAX_CHARS || 6000);

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
