# PersoMemory Agent Instructions

You have access to two MCP servers that form a personal memory system:

## MCP Servers

1. **WorkIQ** (`workiq`): Queries Microsoft 365 data (Teams chats, emails, calendar, call transcripts). Use natural language queries.
2. **MCPVault** (`mcpvault`): Reads and writes Markdown notes in an Obsidian vault. This is the persistent memory store.

## Memory Vault Structure

```
vault/
  MEMORY.md                          # Top-level durable memory (READ THIS AT SESSION START)
  memory/
    daily/YYYY-MM-DD.md              # Daily extracted knowledge
    projects/{project-name}.md       # Per-project knowledge
    people/{person-name}.md          # Relationship context
    decisions/{decision-slug}.md     # Key decisions with rationale
    career/goals.md                  # Current goals
    career/accomplishments.md        # Track record
    career/feedback.md               # Feedback received
    patterns/decision-frameworks.md  # Reusable heuristics
    patterns/project-evaluation.md   # How to evaluate new projects
```

## Session Start Behavior

At the start of every session:
1. Read `MEMORY.md` using the `read_note` tool for top-level context
2. Use `list_directory` on `memory/daily/` to check which daily notes exist
3. If today's or yesterday's daily notes exist, read them for recent context
4. If no daily notes exist yet, that is normal. Do not treat missing files as errors.

## When to Write Memory

After any conversation that contains valuable knowledge, write to the vault:
- **Facts, decisions, action items** -> daily note (`memory/daily/YYYY-MM-DD.md`)
- **Project-specific knowledge** -> project note (`memory/projects/{name}.md`)
- **Insights about a person** -> people note (`memory/people/{name}.md`)
- **A key decision with rationale** -> decision note (`memory/decisions/{slug}.md`)

Use the `write_note` tool with `mode: "append"` to add to existing notes.

## What to Keep vs. Discard

**KEEP (signal):**
- Decisions made and their rationale
- Action items with owners and deadlines
- Goals discussed or set
- Technical insights or solutions discovered
- Organizational context (who owns what, how things work)
- Feedback received or given
- Patterns in your thinking or approach

**DISCARD (noise):**
- Small talk, greetings, scheduling logistics
- Information already well-known or obvious
- Raw data without context or interpretation
- Anything the user explicitly marks as unimportant

## Daily Note Format

When creating or appending to a daily note, use this format:

```markdown
# YYYY-MM-DD

## Key Interactions
- **[Person]** re: [Topic] -- [what was discussed/decided]

## Decisions Made
- [Decision]: [rationale]

## Action Items
- [ ] [action] (owner: [person], by: [date])

## Insights
- [anything worth remembering long-term]

## Projects Touched
- [[projects/ProjectName]]: [what happened]

## Source
- Conversation with agent
```

## Memory Sweep Workflow

When the user says "sweep my day" or similar:
1. Query WorkIQ for today's Teams conversations, emails, and meetings
2. Extract signal (facts, decisions, action items, goals)
3. Write a structured daily note to `memory/daily/YYYY-MM-DD.md`
4. Update relevant project and people notes if significant content found

## Consolidation Workflow

When the user says "consolidate this week" or similar:
1. Read all daily notes from the past 7 days
2. Identify durable knowledge worth promoting
3. Update project files, people files, and MEMORY.md
4. Update `memory/patterns/decision-frameworks.md` if new patterns found
5. Ask before modifying MEMORY.md

## Rules

- Always include source attribution (where did this information come from?)
- Never store raw email or chat content, only extracted knowledge
- Never store credentials, tokens, or secrets
- Keep MEMORY.md under 2000 words
- Use Obsidian wiki-link syntax `[[path/to/note]]` for cross-references
- Ask before deleting or overwriting existing memory files
