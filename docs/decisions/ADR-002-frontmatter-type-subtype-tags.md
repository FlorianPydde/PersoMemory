# ADR-002: Flat `type` + controlled `subtype` + `tags`, with targeted wikilinks and Bases views

## Status

Accepted

## Date

2026-06-02

## Context

The v2 vault used a single compound free-text `type` field. In practice this drifted
to **17 distinct values across ~50 notes**, including duplicate spellings of the same
concept (`evidence-daily` vs `daily-evidence`, `approval-queue` vs `approvals`) and a
`reusable-*` family split four ways (`reusable-pattern`, `reusable-operating-pattern`,
`reusable-work-pattern`, `reusable-career-guidance`). The compound value was also
redundant with the folder a note already lived in, yet not reliably equal to it, which
made property search and any Bases-style view unreliable.

Obsidian's own guidance (kepano / Steph Ango) favours a single, low-cardinality `type`
that mirrors the kind of thing a note is, with finer distinctions expressed separately.
Obsidian 1.9+ ships **Bases**, a native database view over frontmatter properties, which
rewards a small controlled `type` vocabulary. An AI harness (Copilot CLI / Claude Code)
retrieves most reliably when the deterministic layer (folder, `type`, `subtype`, `tags`,
explicit links) is clean and a separate semantic layer (Smart Connections) only widens
discovery.

## Decision

Adopt a three-field frontmatter classification plus a link convention:

1. **`type` is flat and equals the top-level folder.** Exactly six values:
   `evidence | outcome | execution | reusable | view | governance`. Never compound,
   never free-text.
2. **`subtype` is a controlled granular kind within the folder.** Vocabulary:
   - evidence: `daily`, `session`
   - outcome: `delivery`, `pursuit`, `initiative`
   - execution: `open-loops`
   - reusable: `pattern`, `framework`, `career`
   - view: `attention`, `career-impact`
   - governance: `ontology-contract`, `approval-queue`, `approval-routing`,
     `maintenance-report`
3. **`tags` are cross-cutting facets** (account/customer/theme), disjoint from
   `type`/`subtype`. A value is never both a class and a facet.
4. **Targeted wikilinks.** The curated `links:` field uses Obsidian wikilinks so edges
   appear in the graph and backlinks; `sources:` stays plain provenance and is never
   wikilinked.
5. **Bases views** (`.base` files) replace hand-maintained markdown projections.

The canonical statement of this schema lives in the vault contract
(`governance/ontology/contract.md`, v3); this repo's `docs/ontology.md` and the note
templates mirror it.

## Rationale

- `type` = folder makes class unambiguous, deduplicates the drift, and makes property
  search and Bases views deterministic.
- `subtype` keeps the granularity the compound `type` was trying to express, without
  polluting the class axis.
- Separating `tags` (facets) from `type` (class) prevents the overlap that caused the
  original drift.
- Targeted (not blanket) wikilinks add graph value to curated relationships while keeping
  the audit trail (`sources:`) plain and low-noise; one re-embed is enough.
- Bases are plain-text YAML, git-friendly, and agent-authorable, so views become
  versioned artifacts instead of hand-maintained notes.

## Alternatives Considered

### Single `type` only (kepano-strict, no `subtype`)

Closest to Obsidian's default advice, but loses the genuine intra-folder distinctions the
team relies on (e.g. delivery vs pursuit outcomes; pattern vs framework reusable assets).
Rejected in favour of `type` + `subtype`, which keeps a flat class axis *and* the
granularity.

### Keep compound `type`, add a validation lint only

Would codify the drift rather than fix it and still breaks Bases/property search.
Rejected; an in-flight change that documented the compound vocabulary as canonical was
explicitly superseded by this ADR.

### Blanket wikilinking of every path field (including `sources:`)

Maximises graph density but turns the provenance/audit trail into navigation noise and
forces large re-embeds. Rejected in favour of targeted wikilinks on `links:` only.

### Wikilinks instead of Smart Connections (or vice versa)

Treated as complementary, not exclusive: deterministic links/property search first,
semantic widening second, with an edge-promotion path that converts recurring semantic
neighbours into durable `links:` wikilinks.

## Consequences

- Existing notes migrated from 17 compound `type` values to the 6 flat values plus
  `subtype` (bodies unchanged; validated byte-for-byte).
- Templates, `docs/ontology.md`, and the validate script follow the new schema; a
  schema-drift lint enforces the controlled vocabulary going forward.
- `person-note` (a `people` type with no folder in the six-type model) was **retired**
  (2026-06-02): the template is removed and no `people` type is introduced. People are
  referenced inline within evidence/outcome notes and by wikilink; a dedicated people type
  can be reconsidered if per-person aggregation is ever needed.
- **Reusable subtypes simplified 9 → 3 (2026-06-02):** `pattern`, `framework`, `career`.
  The earlier set mixed *form* (pattern/operating-pattern/narrative/rubric/framework) with
  *topic* (career-guidance/career-evidence) and duplicated `pattern`/`operating-pattern`.
  `operating-pattern`→`pattern`; `career-guidance`+`career-evidence`+`rubric`(career use)+
  `narrative`(career-direction)→`career`; unused `decision`/`toolkit` dropped (templates
  removed). `career` is kept as a single-valued subtype by decision (tags not used here).
- Tag normalisation and the `related:`/`informs:` → wikilinked `links:` unification are a
  deliberate follow-on curation pass, not part of the type/subtype migration.
