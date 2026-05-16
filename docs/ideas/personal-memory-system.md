# Personal Memory System

## Problem Statement

How might we build a personal, evolving memory layer that automatically captures signal from daily work interactions (Teams, calls, emails, organic CLI conversations) and makes it available to an AI agent so it compounds into a strategic advisor that knows your projects, your org, your thinking patterns, and helps you make better decisions over time?

## Recommended Direction

**Architecture: Obsidian Vault as Memory + LLM Extraction Pipeline + CLI Agent Integration**

The system has three layers:

1. **Ingestion Layer**: A scheduled pipeline (nightly or on-demand) pulls data from Microsoft Graph API (Teams messages, email threads, call transcripts, calendar events). An LLM pass filters and extracts only signal: facts, decisions, action items, commitments, goals, organizational context, and technical insights. The vast majority of raw data is discarded. Output: structured Markdown notes written to an Obsidian vault.

2. **Conversational Memory Layer**: When you talk to your CLI agent (Copilot CLI, Claude Code, etc.) about technical problems, projects, or strategy, the agent writes relevant context to the same Obsidian vault. This is organic, not a "debrief" ritual. The agent decides what's worth keeping based on the conversation.

3. **Retrieval and Agent Layer**: The CLI agent loads relevant memory on each interaction. It uses semantic search (embeddings) over the vault to pull context. Over time, a "dreaming" process (inspired by OpenClaw) consolidates daily notes into durable knowledge: project histories, decision patterns, relationship context, career trajectory.

**Why Obsidian?** It's Markdown-native, human-readable, versionable, has a plugin ecosystem, and you can always read and edit your own memory. It's also not locked into any vendor.

**Why filter-first?** The #1 failure mode of memory systems is noise. If you store everything, retrieval quality degrades fast. The extraction LLM's primary job is to say "no" to 90%+ of incoming data.

**The compounding asset:** Over months, the vault accumulates:
- Project playbooks: what worked, what didn't, how you approached similar problems
- Org knowledge: who owns what, how decisions get made, political dynamics
- Decision frameworks: your own heuristics, extracted from patterns in your behavior
- Career context: goals, accomplishments, feedback, trajectory

When a new project lands, the agent already knows: "This looks like the PoC you did in Q2. That one had budget issues. Here's what you'd do differently."

## Key Assumptions to Validate

- [ ] **Graph API access is sufficient**: Can you reliably pull Teams chat messages, email threads, and call transcripts with your current permissions? Test with a simple script that pulls one day of data.
- [ ] **LLM filtering is accurate enough**: Can an LLM (GPT-4/Claude) reliably distinguish signal from noise in your work communications? Test by feeding it a day of raw Teams messages and rating the extraction quality.
- [ ] **Retrieval quality at scale**: When the vault has 6+ months of notes, can semantic search still surface the right context? Test with a vector search solution (e.g., local embeddings + similarity search, or an Obsidian plugin like Smart Connections).
- [ ] **The habit loop works**: Will you naturally talk to your CLI agent in a way that generates useful memory, or does it feel forced? Test by using it for 2 weeks without any Graph API ingestion.
- [ ] **Memory actually changes your decisions**: Does having this context available actually improve your work, or is it just interesting? Track 5 instances where memory influenced a decision.

## MVP Scope

**Phase 1: Conversational Memory (Week 1-2)**
- Configure your CLI agent (Copilot CLI or Claude Code) to read from and write to an Obsidian vault
- Define the memory file structure:
  - `memory/content/daily/YYYY-MM-DD.md` for daily notes from conversations
  - `memory/content/projects/{project-name}.md` for project-specific knowledge
  - `memory/content/people/{person}.md` for relationship context
  - `memory/content/decisions/` for decision logs
  - `MEMORY.md` as the top-level durable memory (loaded every session)
- Build the agent's "memory write" behavior: after meaningful conversations, it extracts and saves relevant facts
- Build the agent's "memory read" behavior: at session start, it loads MEMORY.md + recent daily notes + relevant project files

**Phase 2: Graph API Ingestion (Week 3-4)**
- Build a Python script that pulls from Microsoft Graph API:
  - Teams chat messages (filtered to your active channels/DMs)
  - Email threads (sent/received, not newsletters)
  - Call transcripts (if available via Graph)
  - Calendar events (for context)
- LLM extraction pass: feed raw data through a prompt that extracts facts, decisions, action items, goals
- Write extracted knowledge to the Obsidian vault in the same structure
- Run as a nightly cron job or on-demand script

**Phase 3: Consolidation / Dreaming (Week 5+)**
- Build a periodic consolidation pass (weekly) that:
  - Reviews daily notes from the past week
  - Promotes durable knowledge to project files, people files, MEMORY.md
  - Identifies patterns and decision frameworks
  - Aggressively prunes noise
- This is the "dreaming" concept from OpenClaw

## Not Doing (and Why)

- **Real-time ingestion from Teams/email** -- Batch processing (nightly) is dramatically simpler and avoids webhook complexity. You don't need real-time memory; overnight is fine.
- **Building a custom UI** -- Obsidian IS the UI. Don't build another one. You view and edit memory in Obsidian, you interact with the agent in the terminal.
- **Multi-user or team features** -- This is for you. No auth, no sharing, no collaboration features. Keep it solo.
- **Custom embedding infrastructure** -- Start with an Obsidian plugin (Smart Connections) or a simple local embedding solution. Don't build a vector database from scratch.
- **Mobile access** -- Terminal-first. If you need mobile later, Obsidian has mobile apps that sync the vault.
- **Productizing this** -- Build for yourself. If it works, you can generalize later. Building for others now will slow you down.
- **Calendar/meeting integration (proactive briefings)** -- Nice-to-have but not MVP. The memory should be queryable first, proactive second.

## Open Questions

- What Obsidian vault structure works best for agent consumption? Flat files vs. nested folders vs. tagged notes?
- How do you handle sensitive data (HR conversations, confidential projects) in the memory? Per-note access controls? Separate vault sections?
- Which embedding solution for retrieval: Obsidian plugin, local model (e.g., nomic-embed), or Azure OpenAI embeddings?
- How does the CLI agent discover what memory files to load? Load everything? Semantic search at query time? Pre-compiled "context pack"?
- What's the right granularity for the extraction filter? Too aggressive = you miss things. Too loose = noise.
- How do you version/backup the vault? Git? Obsidian Sync? OneDrive?
