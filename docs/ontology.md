# PersoMemory Ontology

## Core Model

PersoMemory separates evidence, operational memory, and durable memory.

1. Evidence lives in `memory/content/daily/`.
2. Operational memory lives in `memory/content/active/now.md` and `memory/content/commitments/open-loops.md`.
3. Durable memory lives in `MEMORY.md`, projects, people, patterns, decisions, career, and toolkits.
4. Consolidation reasoning lives in `memory/governance/dreams.md`.
5. Atomic career evidence lives in `memory/content/career/evidence/`.

## Main Rule

Daily notes do not move into memory. They are routed into curated projections when the signal is strong enough.

## Operational Contract

The canonical live routing and maintenance policy is the vault note `memory/governance/ontology/contract.md`.

This repository document remains the recovery and schema reference. The vault contract is what agents should read before ambiguous routing, durable promotion recommendations, graph stewardship, monthly compression, retrieval-policy changes, and ontology-maintenance decisions.

Changes to the contract affect future agent behavior and are approval-gated unless Florian explicitly asks for the exact change in the current conversation.

## Process Boundaries

### Live Capture

Fast and local. Capture what changed in the conversation and route only operational updates immediately.

### Daily WorkIQ Intake

Unbundled and evidential. Reconstruct the day from M365 using the `memory-sweep` six-pass candidate battery: obligations/requests, project or outcome changes, career/feedback/guidance, decisions/risks/dependencies, reusable artifacts/ideas, and direct mentions/questions. Merge and deduplicate the outputs before writing a daily note. Update active memory and commitments only for obvious current changes.

### Dreaming

Slow and durable. Review multiple daily notes and promote repeated signals.

## Promotion Gates

1. `MEMORY.md`: repeated evidence or explicit user approval.
2. `memory/content/active/now.md`: useful current context.
3. `memory/content/commitments/open-loops.md`: open or recently closed obligation.
4. `memory/content/projects/`: structural project knowledge.
5. `memory/content/people/`: durable relationship signal.
6. `memory/content/patterns/`: repeated or generalizable heuristic.
7. `memory/content/decisions/`: future behavior changes with rationale.
8. `memory/content/toolkits/`: reused or clearly reusable asset.
9. `memory/content/career/`: accomplishment, feedback, goal, or growth evidence.
10. `memory/content/career/evidence/`: atomic proof notes, Connect/promotion threshold only.

Career direction and career evidence are different routes. Manager or mentor guidance that changes goals, role scope, exposure, or 1-3 year trajectory belongs in `memory/content/career/feedback.md` or `memory/content/career/goals.md` through an approval-gated update. Proof strong enough for Connect or promotion belongs in `memory/content/career/evidence/`.

## Failure Modes

1. Over promoting fresh thoughts into durable memory.
2. Treating WorkIQ output as truth instead of evidence.
3. Burying obligations in daily notes.
4. Letting `MEMORY.md` become stale project status.
5. Retrieving daily notes by default and flooding context.
6. Creating atomic evidence notes for ordinary work; threshold is Connect/promotion/leadership proof only.
7. Compressing explicit action items into broad themes and losing the owner, due timing, expected output, or source.
8. Collapsing manager career conversations into recognition evidence while missing future role direction, goals, and 1-3 year trajectory.

---

## Note Type Schemas

Each schema specifies required fields, optional fields, and inline wikilink conventions.

### Required frontmatter fields by note type

| Note type | Required | Optional |
|---|---|---|
| daily | `type`, `date` | `projects`, `people`, `decisions`, `impact-areas` |
| project | `type`, `status`, `domains` | `technologies`, `people`, `decisions`, `patterns`, `toolkits`, `related` |
| person | `type` | `projects`, `decisions`, `patterns`, `tags` |
| pattern | `type` | `projects`, `decisions`, `toolkits`, `tags` |
| decision | `type`, `date`, `status` | `projects`, `people`, `patterns`, `supersedes`, `superseded-by` |
| toolkit | `type` | `projects`, `patterns`, `tags` |
| career-evidence | `type`, `date`, `impact-areas`, `so-what`, `source-type` | `observers`, `projects`, `people`, `patterns`, `decisions` |
| active-now | `type`, `updated` | `projects`, `people` |
| open-loops | `type`, `updated` | `projects`, `people` |

---

### Daily note schema

```yaml
---
type: daily
date: YYYY-MM-DD
projects:
  - "[[content/projects/otp-bank-agentic]]"
people:
  - "[[content/people/george-theologou]]"
decisions: []
impact-areas: []
---
```

Body uses the standard section schema. Link projects and people in frontmatter only when mentioned in the note body. Do not add links for projects or people that are not clearly relevant to that day's content.

---

### Project note schema

```yaml
---
type: project
status: active
domains:
  - banking
  - agentic-ai
technologies:
  - Azure OpenAI
  - Cosmos DB
people:
  - "[[content/people/george-theologou]]"
  - "[[content/people/harish-chandran]]"
decisions:
  - "[[content/decisions/otp-storage-architecture]]"
patterns:
  - "[[content/patterns/agentic-ai-delivery]]"
toolkits: []
related:
  - "[[content/projects/premier-league]]"
tags:
  - regulated-fsi
  - human-in-the-loop
---
```

`status` values: `active`, `paused`, `closed`.

`domains`: business domain labels such as `banking`, `insurance`, `retail`, `sport`, `public-sector`.

`related` is for projects with meaningful pattern or domain overlap, not just any project that exists.

---

### Person note schema

```yaml
---
type: person
projects:
  - "[[content/projects/otp-bank-agentic]]"
  - "[[content/projects/premier-league]]"
decisions:
  - "[[content/decisions/otp-storage-architecture]]"
patterns:
  - "[[content/patterns/agentic-ai-delivery]]"
tags:
  - stakeholder
  - customer-facing
---
```

Only add decisions and patterns when the person was directly involved in making or shaping them.

---

### Pattern note schema

```yaml
---
type: pattern
projects:
  - "[[content/projects/otp-bank-agentic]]"
  - "[[content/projects/premier-league]]"
decisions:
  - "[[content/decisions/pl-agent-flow-simplification]]"
toolkits: []
tags:
  - agentic-ai
  - regulated-fsi
---
```

`projects` lists the source projects that originated or validated this pattern.

---

### Decision note schema

```yaml
---
type: decision
date: YYYY-MM-DD
status: active
projects:
  - "[[content/projects/otp-bank-agentic]]"
people:
  - "[[content/people/george-theologou]]"
patterns:
  - "[[content/patterns/agentic-ai-delivery]]"
supersedes: []
superseded-by: ""
tags: []
---
```

`status` values: `active`, `superseded`, `revisit`.

`supersedes` and `superseded-by` are wikilinks to other decision notes.

---

### Toolkit note schema

```yaml
---
type: toolkit
projects:
  - "[[content/projects/otp-bank-agentic]]"
patterns:
  - "[[content/patterns/agentic-ai-delivery]]"
tags:
  - git
  - parallel-agents
---
```

---

### Career evidence note schema

```yaml
---
type: career-evidence
date: YYYY-MM-DD
impact-areas:
  - "High Quality Delivery"
  - "AI Design Wins / Pre-sales"
so-what: "One sentence: what changed and why it matters for Florian's career."
source-type: shipped-outcome
observers:
  - "[[content/people/george-theologou]]"
projects:
  - "[[content/projects/otp-bank-agentic]]"
people:
  - "[[content/people/harish-chandran]]"
patterns:
  - "[[content/patterns/agentic-ai-delivery]]"
decisions:
  - "[[content/decisions/otp-storage-architecture]]"
tags: []
---
```

**Capture threshold:** Only create a standalone career evidence note when proof is strong enough for Connect, promotion, or a leadership narrative. Everyday work goes into project notes or daily notes.

**`source-type` controlled vocabulary:**
- `shipped-outcome` — a working system, shipped feature, or live demo
- `customer-testimonial` — direct positive signal from a customer or partner
- `stakeholder-reaction` — positive or notable reaction from an internal stakeholder
- `manager-feedback` — explicit feedback from manager
- `peer-feedback` — explicit feedback from a peer
- `meeting-outcome` — a decision, agreement, or advance made in a meeting
- `email-recognition` — recognition captured in email or Teams

**`impact-areas` controlled vocabulary (aligned to manager evaluation rubric):**
- `High Quality Delivery`
- `Customer Orientation`
- `AI Design Wins / Pre-sales`
- `Thought & Technical Leadership`
- `Microsoft Business Understanding and Management`
- `Growth Mindset & Problem Solving`
- `Diversity & Inclusion`
- `Security`

---

### Active-now schema

```yaml
---
type: active-now
updated: YYYY-MM-DD
projects:
  - "[[content/projects/otp-bank-agentic]]"
  - "[[content/projects/premier-league]]"
people: []
---
```

---

### Open-loops schema

```yaml
---
type: open-loops
updated: YYYY-MM-DD
projects: []
people: []
---
```

---

## Wikilink Rules

Use Obsidian wikilink syntax `[[folder/slug]]` when referencing notes from other notes.

| Relationship | Wikilink pattern | Example |
|---|---|---|
| Reference a project | `[[content/projects/slug]]` | `[[content/projects/otp-bank-agentic]]` |
| Reference a person | `[[content/people/slug]]` | `[[content/people/george-theologou]]` |
| Reference a pattern | `[[content/patterns/slug]]` | `[[content/patterns/agentic-ai-delivery]]` |
| Reference a decision | `[[content/decisions/slug]]` | `[[content/decisions/otp-storage-architecture]]` |
| Reference a toolkit | `[[content/toolkits/slug]]` | `[[content/toolkits/git-worktrees-parallel-agents]]` |
| Reference career evidence | `[[content/career/evidence/slug]]` | `[[content/career/evidence/otp-stage3-ecif-close]]` |

**Both conventions apply simultaneously:** add the wikilink in the frontmatter list field AND use it inline in prose when giving context. This makes the link machine-readable (frontmatter) and human-readable (inline).

Example (project note body):
```markdown
This architecture was shaped by [[content/people/george-theologou]] and locked in [[content/decisions/otp-storage-architecture]].
The pattern generalizes across [[content/patterns/agentic-ai-delivery]] and overlaps with [[content/projects/premier-league]].
```

---

## Edge Types and Directionality

| Edge | Direction | Fields used |
|---|---|---|
| daily -> project | outbound from daily | `projects` frontmatter |
| daily -> person | outbound from daily | `people` frontmatter |
| project -> person | outbound from project | `people` frontmatter |
| project -> decision | outbound from project | `decisions` frontmatter |
| project -> pattern | outbound from project | `patterns` frontmatter |
| project -> toolkit | outbound from project | `toolkits` frontmatter |
| project -> project | bidirectional | `related` frontmatter on both |
| person -> project | outbound from person | `projects` frontmatter |
| pattern -> project | outbound from pattern | `projects` frontmatter (source projects) |
| decision -> project | outbound from decision | `projects` frontmatter |
| career-evidence -> project | outbound from evidence | `projects` frontmatter |
| career-evidence -> person | outbound from evidence | `people` + `observers` frontmatter |
| career-evidence -> pattern | outbound from evidence | `patterns` frontmatter |

Backlinks in Obsidian automatically reveal the reverse direction. Do not duplicate bidirectional entries unless both directions carry different context.

---

## Atomic Career Evidence Model

Evidence notes live under `memory/content/career/evidence/`. Each note:

1. Captures one atomic proof unit — a single observable outcome or recognition event.
2. Maps to one or more `impact-areas` from the rubric taxonomy.
3. Includes a one-sentence `so-what` that could appear verbatim in Connect.
4. Lists at least one proof source via `source-type` and optionally `observers`.
5. Links back to the relevant project, people, patterns, or decisions.

`memory/content/career/accomplishments.md` is the human-readable roll-up. It summarizes themes and pointers to evidence notes for Connect and quarterly impact writing. It is not the primary proof store.

The capture threshold is strict: only create a standalone evidence note when the proof is strong enough to cite in Connect, a promotion case, or a leadership narrative.

---

## Retrieval Priority Order

When the agent needs to answer a memory question, use this order:

1. **Direct file lookup**: if the exact file path is known, read it.
2. **Explicit linked notes**: follow frontmatter `projects`, `people`, `patterns`, `decisions` wikilinks from the anchor note.
3. **Property-based search**: search notes with matching `type`, `status`, `domains`, or `impact-areas` values.
4. **Semantic search**: use Smart Connections when the topic is conceptual or the exact filename is unknown.
5. **Daily notes as evidence**: retrieve daily notes only when you need chronological evidence, source details, or a specific date.

Prefer explicit links over semantic search when the graph has been populated. Use semantic search when the graph is incomplete or the question is conceptual.
