# PersoMemory v3 Ontology

## Core Model

PersoMemory v3 separates evidence, three maintained domains, views, and governance.

1. Evidence lives in `evidence/`.
2. Outcomes live in `outcomes/`.
3. Execution lives in `execution/`.
4. Reusable Memory lives in `reusable/`.
5. Views live in `views/`.
6. Governance lives in `governance/`.

`MEMORY.md` and `dreams.md` are intentionally not part of v3. Skills retrieve deliberately; consolidation outputs are dated maintenance reports.

## Main Rule

Evidence notes do not become memory by default. They are routed into Outcomes, Execution, Reusable Memory, or Views only when the signal changes future action, retrieval, judgment, or reuse.

## Operational Contract

The canonical live routing and maintenance policy is the vault note `governance/ontology/contract.md`.

This repository document remains the recovery and schema reference. The vault contract is what agents should read before ambiguous routing, durable promotion recommendations, monthly compression, retrieval-policy changes, and ontology-maintenance decisions.

Changes to the contract affect future agent behavior and are approval-gated unless Florian explicitly asks for the exact change in the current conversation.

## Physical Structure

```text
ObsidianVaultMemory/
  evidence/
    daily/
    sessions/
  outcomes/
  execution/
    open-loops.md
  reusable/
  views/
    active-now.md
    career-impact.md
  governance/
    ontology/contract.md
    approvals/
    maintenance/
    preferences/approval-routing.md
```

## Frontmatter Schema

Mirrors the canonical vault contract (`governance/ontology/contract.md`, v3). Every maintained note declares a controlled `type`, an optional controlled `subtype`, and optional `tags`.

- `type` is **flat and equals the top-level folder**. Exactly six values, never compound or free-text:
  `evidence | outcome | execution | reusable | view | governance`.
- `subtype` is a controlled granular kind within the folder:

  | `type` | allowed `subtype` |
  | --- | --- |
  | evidence | `daily`, `session` |
  | outcome | `delivery`, `pursuit`, `initiative` |
  | execution | `open-loops` |
  | reusable | `pattern`, `framework`, `career` |
  | view | `attention`, `career-impact` |
  | governance | `ontology-contract`, `approval-queue`, `approval-routing`, `maintenance-report` |

- `tags` are cross-cutting facets (account/customer/theme), disjoint from `type`/`subtype`. A value is never both a type/subtype and a tag: if it names *what the note is*, it is `type`/`subtype`; if it names *what the note is about*, it is a `tag`.
- **Targeted wikilinks:** the curated `links:` field uses Obsidian wikilinks (`"[[record]]"`) so edges appear in the graph; `sources:` stays plain provenance strings and is never wikilinked.

## Maintained Domains

### Outcomes

Projects, initiatives, pursuits, deliverables, strategic goals, and durable workstreams.

Use for: goals, status, constraints, stakeholders, decisions, risks, evidence of value, and reusable outcomes.

Minimum frontmatter:

```yaml
---
type: outcome
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
review_date:
importance:
urgency:
confidence:
sources: []
people: []
depends_on: []
supports: []
informs: []
---
```

### Execution

Commitments, obligations, follow-ups, blockers, waiting items, and handover state.

`execution/open-loops.md` is the default operational execution view. Standalone execution notes are optional and should be created only when an item needs lifecycle metadata beyond the open-loops list.

Minimum fields for each loop:

1. Owner.
2. Expected output.
3. Due date or timing, if known.
4. Source.
5. Explicit or inferred.
6. Status.

### Reusable Memory

Reusable patterns, frameworks, and durable career material. Exactly three subtypes:

- `pattern` — a repeatable way of working or behaving that proved effective; reuse it.
- `framework` — a structured method or model for tackling a class of problem.
- `career` — durable career material: evidence, growth guidance, and leadership signals.

Minimum frontmatter:

```yaml
---
type: reusable
subtype: pattern | framework | career
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
why_keep:
retrieval_cues: []
sources: []
outcomes: []
people: []
supersedes: []
---
```

## Evidence

Evidence under `evidence/` is episodic and source-backed. It is useful for source detail, chronology, contradiction checks, and consolidation. It is not the default retrieval layer.

Daily evidence:

```yaml
---
type: evidence
subtype: daily
date: YYYY-MM-DD
sources: []
outcomes: []
people: []
---
```

Session evidence:

```yaml
---
type: evidence
subtype: session
date: YYYY-MM-DD
source: copilot-cli
outcomes: []
people: []
---
```

## Views

Views are retrieval functions, not primary stores:

1. `views/active-now.md`: current attention view over outcomes and execution.
2. `views/career-impact.md`: curated career-impact projection over evidence, outcomes, execution, people links, and reusable memory.

Do not duplicate facts in views when a maintained record should own them. Views should summarize, rank, and point.

## Governance

1. `governance/ontology/contract.md`: live routing and maintenance policy.
2. `governance/approvals/`: pending hard-gate decisions.
3. `governance/maintenance/`: dated consolidation, stewardship, archive, merge, supersede, and compression reports.
4. `governance/preferences/approval-routing.md`: approved routing preferences.

## Edge Vocabulary

Use the ADR-defined vocabulary:

1. `part_of`
2. `source_for`
3. `supports`
4. `depends_on`
5. `produced_by`
6. `informs`
7. `involves(role)`
8. `supersedes`

Avoid broad `relates_to` except for temporary capture, migration, or unresolved inbox cases.

## Retrieval

Retrieval is two-stage (canonical detail in the vault contract):

1. **Deterministic expansion.** From the anchor record, expand via `links:` wikilinks and property/grep search on `type`, `subtype`, `tags`, `status`, and relationship fields.
2. **Semantic widening.** Only when deterministic expansion is insufficient, use Smart Connections for conceptually related notes; treat results as candidates and confirm with exact reads.

**Edge promotion:** when Smart Connections repeatedly surfaces the same strong neighbor across sessions, maintenance may promote it to a curated `links:` wikilink so future retrieval reaches it deterministically.

## Approval Gates

Ask before:

1. Creating or changing durable self-model, career-impact, or operating-principle records.
2. Creating career-impact evidence.
3. Promoting durable outcome or reusable records.
4. Closing or reopening outcomes.
5. Closing ambiguous commitments.
6. Resolving conflicting evidence.
7. Capturing potentially sensitive content.
8. Changing approval-routing preferences, the ontology contract, retrieval policy, or skill behavior.

## Failure Modes

1. Recreating `MEMORY.md` as a stale all-purpose dump.
2. Recreating `dreams.md` as an unstructured consolidation sink.
3. Treating WorkIQ output as truth instead of evidence.
4. Burying obligations in evidence notes instead of `execution/open-loops.md`.
5. Retrieving evidence by default and flooding context.
6. Creating standalone people/career folders before there is durable evidence that they are needed.
