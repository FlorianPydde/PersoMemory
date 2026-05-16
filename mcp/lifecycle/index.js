#!/usr/bin/env node

/**
 * PersoMemory Lifecycle MCP Server
 *
 * Exposes vault lifecycle management as MCP tools callable from any Copilot CLI session.
 *
 * Tools:
 *   lifecycle_check  — surface overdue review-by notes, stale active projects,
 *                      and aged open-loop commitments
 *
 * Config:
 *   VAULT_PATH env var — absolute path to the Obsidian vault
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { readFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const VAULT_PATH = process.env.VAULT_PATH;
if (!VAULT_PATH) {
  console.error('Error: VAULT_PATH environment variable is required');
  process.exit(1);
}

const PROJECTS_DIR = join(VAULT_PATH, 'memory', 'content', 'projects');
const OPEN_LOOPS_PATH = join(VAULT_PATH, 'memory', 'content', 'commitments', 'open-loops.md');

const STALE_DAYS_DEFAULT = 14;
const LOOP_AGE_DAYS_DEFAULT = 14;
const ACTIVE_STATUSES = new Set(['active', 'winding-down']);

function parseFrontmatter(content) {
  if (!content.startsWith('---')) return {};
  const end = content.indexOf('\n---', 3);
  if (end === -1) return {};
  const result = {};
  for (const line of content.slice(3, end).trim().split('\n')) {
    const m = line.match(/^(\S+?):\s*(.*)$/);
    if (m) result[m[1]] = m[2].trim().replace(/^['"]|['"]$/g, '');
  }
  return result;
}

function parseDate(val) {
  if (!val) return null;
  const m = String(val).match(/(\d{4}-\d{2}-\d{2})/);
  if (!m) return null;
  const d = new Date(m[1] + 'T00:00:00Z');
  return isNaN(d.getTime()) ? null : d;
}

function todayUTC() {
  const now = new Date();
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
}

function daysDiff(from, to) {
  return Math.floor((to - from) / 86400000);
}

function checkProjects(staleDays) {
  const overdue = [];
  const stale = [];
  const now = todayUTC();

  let files;
  try {
    files = readdirSync(PROJECTS_DIR).filter(f => f.endsWith('.md')).sort();
  } catch {
    return { overdue, stale };
  }

  for (const file of files) {
    const path = join(PROJECTS_DIR, file);
    let content;
    try { content = readFileSync(path, 'utf8'); } catch { continue; }

    const fm = parseFrontmatter(content);
    const name = file.replace('.md', '');
    const status = (fm.status || '').toLowerCase();

    const reviewBy = parseDate(fm['review-by']);
    if (reviewBy && reviewBy <= now) {
      overdue.push({
        note: `content/projects/${name}`,
        status,
        reviewBy: reviewBy.toISOString().slice(0, 10),
        daysOverdue: daysDiff(reviewBy, now),
      });
    }

    if (ACTIVE_STATUSES.has(status)) {
      let lastUpdated = parseDate(fm.updated);
      let source = 'frontmatter';
      if (!lastUpdated) {
        lastUpdated = new Date(statSync(path).mtime);
        source = 'file-mtime';
      }
      const age = daysDiff(lastUpdated, now);
      if (age >= staleDays) {
        stale.push({
          note: `content/projects/${name}`,
          status,
          lastUpdated: lastUpdated.toISOString().slice(0, 10),
          daysSinceUpdate: age,
          source,
        });
      }
    }
  }

  return { overdue, stale };
}

function checkOpenLoops(loopAgeDays) {
  const aged = [];
  const now = todayUTC();
  let content;
  try { content = readFileSync(OPEN_LOOPS_PATH, 'utf8'); } catch { return aged; }

  for (const line of content.split('\n')) {
    if (!/^[-*\d]/.test(line.trim())) continue;
    const datePattern = /added\s+(\d{4}-\d{2}-\d{2})/gi;
    let m;
    while ((m = datePattern.exec(line)) !== null) {
      const d = parseDate(m[1]);
      if (d && daysDiff(d, now) >= loopAgeDays) {
        aged.push({
          commitment: line.trim().replace(/^[-*\d.\s]+/, '').slice(0, 120),
          added: d.toISOString().slice(0, 10),
          daysOpen: daysDiff(d, now),
        });
      }
    }
  }

  return aged;
}

const server = new Server(
  { name: 'persomemory-lifecycle', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: 'lifecycle_check',
      description: [
        'Check the PersoMemory vault for lifecycle issues.',
        'Returns three categories:',
        '  overdue      — project notes whose review-by date has passed',
        '  stale        — active/winding-down projects not updated in stale_days (default 14)',
        '  agedLoops    — open commitments with an explicit date older than loop_age_days (default 14)',
        'Use the results to triage: confirm still active, extend review-by, or close.',
      ].join('\n'),
      inputSchema: {
        type: 'object',
        properties: {
          stale_days: {
            type: 'number',
            description: 'Days without update before a project is stale (default 14)',
          },
          loop_age_days: {
            type: 'number',
            description: 'Days after which a dated open commitment is aged (default 14)',
          },
        },
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name !== 'lifecycle_check') {
    throw new Error(`Unknown tool: ${request.params.name}`);
  }

  const args = request.params.arguments ?? {};
  const staleDays = typeof args.stale_days === 'number' ? args.stale_days : STALE_DAYS_DEFAULT;
  const loopAgeDays = typeof args.loop_age_days === 'number' ? args.loop_age_days : LOOP_AGE_DAYS_DEFAULT;

  const { overdue, stale } = checkProjects(staleDays);
  const agedLoops = checkOpenLoops(loopAgeDays);
  const totalIssues = overdue.length + stale.length + agedLoops.length;

  const result = {
    checkedAt: new Date().toISOString().slice(0, 10),
    vaultPath: VAULT_PATH,
    config: { staleDays, loopAgeDays },
    overdue,
    stale,
    agedLoops,
    summary: {
      overdueCount: overdue.length,
      staleCount: stale.length,
      agedLoopsCount: agedLoops.length,
      totalIssues,
      status: totalIssues === 0 ? 'clean' : 'action-required',
    },
  };

  return {
    content: [{ type: 'text', text: JSON.stringify(result, null, 2) }],
  };
});

const transport = new StdioServerTransport();
await server.connect(transport);
console.error(`persomemory-lifecycle MCP running. Vault: ${VAULT_PATH}`);
