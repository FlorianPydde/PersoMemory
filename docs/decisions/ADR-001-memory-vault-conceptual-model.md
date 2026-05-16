# ADR-001: Use a Three-Layer Executive Memory Model

## Status

Accepted

## Date

2026-05-16

## Context

PersoMemory is intended to act as an executive memory system, not just a note archive. It must help organize thoughts, tasks, commitments, important discussion outcomes, reusable assets, and future recall while keeping maintenance cost low.

The design is guided by two constraints:

1. Human memory is not organized as many rigid folders. It relies on a few functional systems: episodic evidence, goal-directed context, prospective memory, semantic/procedural reuse, social cues, attention, and consolidation.
2. A useful personal vault must be maintainable. Every durable record, edge, and metadata field creates future update cost.

The primary optimization target is reliable executive action: knowing what matters, what is owed, why it matters, and what prior knowledge should be reused.

## Decision

Use a three-layer conceptual model:

1. **Evidence layer**
   - Source-backed episodic memory.
   - Contains lightweight summaries and source pointers from WorkIQ/Microsoft 365 evidence, Copilot CLI conversations, and other intake channels.
   - Evidence is cheap to capture and lightly maintained.
   - Evidence promotes into maintained records only when it changes future action, judgment, retrieval, or durable reuse.

2. **Maintained core domains**
   - The source-of-truth record classes that carry lifecycle and maintenance responsibility.
   - Keep this set small:
     1. **Outcomes**: projects, initiatives, strategic goals, customer outcomes, and long-running workstreams.
     2. **Execution**: commitments, tasks, follow-ups, open loops, blockers, dependencies, and due dates.
     3. **Reusable Memory**: reusable assets, playbooks, prompts, frameworks, lessons, technical patterns, narrative patterns, code artifacts, and durable know-how.

3. **Control and retrieval views**
   - Dashboards or lenses over records rather than separate sources of truth.
   - Includes Active Now, Open Loops, Today/This Week Attention, Stale Items, Reusable Memory Lookup, and Career/Impact Portfolio.
   - Attention is a view over what matters now, not a domain that owns records.
   - Career/Impact is a curated portfolio view fed by outcomes, execution, evidence, people links, and reusable memory.
   - Sensemaking/Judgment is a memory function embedded in other records, not a default top-level domain.
   - People are contextual graph entities and edge endpoints, not a maintained people database by default.

## Definitions

### Domain

A domain is a maintained class of records. It owns facts, lifecycle, review rules, and update responsibility.

Examples: Outcome, Execution item, Reusable Memory item.

### View

A view is a generated or curated dashboard over records that already live elsewhere. It should not duplicate facts.

Examples: Today/This Week Attention, Career/Impact Portfolio, Stale Items.

### Edge

An edge is a typed link between retrievable records or entities. Use an edge only when the relationship should be traversed later for recall, accountability, lifecycle, or reasoning.

### Metadata

Metadata describes one record. It helps filter, rank, display, review, or validate that record, but it is not itself a traversable relationship.

Examples: `status`, `created`, `updated`, `review_date`, `importance`, `urgency`, `confidence`, `due_date`, `owner`, `source_type`.

In Markdown/frontmatter, a link field can be stored as metadata while conceptually representing an edge. The distinction is about behavior: if agents or views should traverse the relationship, it is an edge.

## Core Edge Vocabulary

Use soft formal semantics: a small controlled edge vocabulary as an operating contract for agents and views, not a heavy graph API ontology.

| Edge | Direction | Purpose | Notes |
| --- | --- | --- | --- |
| `part_of` | child -> parent | Hierarchy | Use for outcome/workstream hierarchy and reusable-memory collections. Do not use as the default task-to-project relationship. |
| `source_for` | evidence -> curated record | Provenance | Source type, date, confidence, and source pointer are metadata. Avoid separate provenance edges like `mentioned_in` or `extracted_from`. |
| `supports` | execution/reusable memory -> outcome | Purpose and contribution | Main executive edge: connects activity and assets to the outcome they help achieve. |
| `depends_on` | dependent record -> dependency | Sequencing and blockers | Store `depends_on`; derive `blocks` as the inverse view. |
| `produced_by` | reusable asset -> outcome/work | Output lineage | Keeps artifact origin distinct from later reuse. |
| `informs` | evidence/reusable memory/prior decision -> record | Guidance and reasoning | Use when something should shape thinking but does not directly deliver the outcome. |
| `involves(role)` | record -> person/entity | Contextual people/entity link | Roles such as requester, approver, collaborator, mentor, feedback_source, stakeholder, owner, or guidance_source are edge metadata. |
| `supersedes` | newer record -> older record | Lifecycle replacement | Rare edge for replacing outdated decisions, assets, or guidance. Derive `superseded_by` as the inverse. |

Avoid broad `relates_to` edges except for temporary capture, migration, or unresolved inbox cases. A graph dominated by `relates_to` loses semantic value.

## Required Metadata for Maintained Records

All maintained records should carry the smallest shared metadata set that supports lifecycle, attention, and provenance:

| Field | Purpose |
| --- | --- |
| `type` | Identifies the record type/domain. |
| `status` | Shared lifecycle state. |
| `created` | Creation date. |
| `updated` | Last meaningful update. |
| `review_date` | Next review or staleness trigger. |
| `importance` | Whether the item matters strategically or consequentially. |
| `urgency` | Whether the item is time-sensitive or blocking. |
| `confidence` | How certain the system is about the record. |
| `sources` | Lightweight source pointers for readability and provenance. |

Use a shared lifecycle vocabulary where possible: `active`, `waiting`, `done`, `closed`, `archived`, and `superseded`. Domain-specific statuses are allowed only when they drive a real lifecycle or view.

Execution records may additionally require task-specific fields such as `due_date`, `owner`, `next_action`, and `blocking`. These should not be mandatory for Outcomes or Reusable Memory.

Reusable Memory records should explain why they deserve durable storage:

| Field | Purpose |
| --- | --- |
| `why_keep` | Why this item should survive beyond the original project or day. |
| `retrieval_cues` | Future situations where the vault should bring the item back. |

## Promotion Rules

Evidence should promote into maintained records only when it creates or changes one of the following:

1. An Outcome.
2. An Execution item.
3. A Reusable Memory item.
4. A high-signal view such as Career/Impact.
5. A governance or lifecycle decision that changes future routing, retrieval, or maintenance.

Most evidence should remain evidence and decay unless it changes future action or retrieval.

Strict edge hygiene is required for curated durable records. Evidence and transient captures may use provisional or incomplete links until promotion.

## Rationale

This model balances memory science and executive usefulness:

1. **Evidence** maps to episodic memory: source-backed traces of what happened.
2. **Outcomes** map to goal-directed schemas: the brain organizes action around goals and contexts.
3. **Execution** maps to prospective memory: remembering what must happen in the future.
4. **Reusable Memory** maps to semantic and procedural memory: generalized knowledge and how-to patterns.
5. **Attention views** map to working memory and executive control: limited focus on what matters now.
6. **Review and consolidation** map to replay/compression: weak traces are linked, promoted, or forgotten over time.

The design intentionally avoids a large set of top-level domains because too many domains increase maintenance cost and reduce consistency. Richness should come from explicit links, retrieval cues, lifecycle metadata, and consolidation rather than from many folders.

## Alternatives Considered

### Many maintained domains

Examples: separate domains for Projects, People, Decisions, Risks, Opportunities, Career, Patterns, Toolkits, Artifacts, Tasks, Meetings, and Discussions.

- Pros: Precise labels and intuitive browsing for some content types.
- Cons: High maintenance cost, unclear boundaries, duplicate facts, and increased need for retroactive updates.
- Rejected: The vault should use few maintained domains and push nuance into metadata, edges, and views.

### Prose-only plus semantic search

- Pros: Low capture friction and flexible recall.
- Cons: Weak for obligations, stale-loop detection, provenance, dashboards, and agent consistency.
- Rejected: Semantic search is useful but not reliable enough for executive accountability.

### Full formal graph ontology or graph database

- Pros: Strong query semantics, constraints, and traversal.
- Cons: Implementation-heavy, premature for a personal memory system, and likely to increase schema maintenance before the conceptual model stabilizes.
- Rejected for now: The vault needs soft formal semantics, not a heavy graph API ontology.

### People as a core maintained domain

- Pros: Strong relationship recall.
- Cons: Encourages maintaining a people database and storing professional context that is often only relevant through outcomes, execution, feedback, or guidance.
- Rejected as a default: People should primarily be contextual graph entities and edge endpoints. Full people notes are reserved for durable, high-leverage relationships.

### Sensemaking/Judgment as a core domain

- Pros: Preserves reasoning, tradeoffs, assumptions, and risks.
- Cons: Easy to turn into a dumping ground for brainstorms and AI conversations.
- Rejected as a default domain: Sensemaking is a function embedded in Outcome, Execution, and Reusable Memory records. Standalone sensemaking records are reserved for cross-outcome strategic theses or unresolved questions.

## Consequences

1. PersoMemory should maintain fewer durable record types than earlier drafts suggested.
2. Existing templates and ontology docs may need follow-up alignment with this conceptual model.
3. Agents should prefer creating or updating Outcomes, Execution, and Reusable Memory over adding new domain categories.
4. Views should assemble and rank existing records rather than duplicating facts.
5. Edge vocabulary should remain small and stable. New edge types require a clear retrieval, lifecycle, accountability, or reasoning benefit.
6. Capture remains lightweight; promotion is where quality gates, edge hygiene, and lifecycle metadata become strict.

## Non-Goals

1. This ADR does not define a storage implementation.
2. This ADR does not require a graph database.
3. This ADR does not rewrite the active vault ontology by itself.
4. This ADR does not require immediate migration of existing notes.
5. This ADR does not define WorkIQ, MCPVault, Smart Connections, or Obsidian implementation details.

## Follow-Up Work

1. Align `docs/ontology.md` and note templates with the three-domain conceptual model.
2. Decide whether existing project, decision, pattern, toolkit, person, and career templates become domain records, view records, entity references, or legacy compatibility templates.
3. Add examples of one Outcome, one Execution item, one Reusable Memory item, and one Evidence record using the new model.
4. Define migration guidance that avoids bulk rewrites and relies on consolidation over time.
