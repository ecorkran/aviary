---
docType: notes
project: aviary
slice: <spike-slice-name, e.g. world-state-query-spike>
dateCreated: <YYYYMMDD>
dateUpdated: <YYYYMMDD>
status: not_started
---

# Discovery Finding: <short title>

> **How to use this template.** Copy this file to a finding note (see *Storage and
> Naming* at the bottom), then fill every field below. A field that genuinely does
> not apply is marked `n/a` with a one-line reason — **never deleted** — so a
> reviewer can see it was considered. The spike is "done" when every field is
> filled to its slice's Success Criteria bar.

## Question

<The single, specific question this spike answers. One question per finding.>

## Method

<How it was probed — what was run, against what, observing what. The finding must
rest on observed behavior, not documentation ("measure, don't assume").>

## Evidence / Observations

<The raw observations: outputs, measurements, behaviors seen. The factual basis
for the decision below.>

## Decision

<The answer reached and the choice made. The headline output of the spike.>

## Cost notes

<Efficiency / cost characteristics observed — e.g. how much state, how often, over
what channel. Required so downstream initiatives design against real numbers.>

## Implications for downstream initiatives

<What 120 (Eval Harness) and/or 140 (Orchestration) should now assume or design
against. This is the hand-off to the next initiative.>

## Confidence

<How strongly the evidence supports the decision, and what would change it.>

## Inconclusive → next step

<If the question could not be settled: what was learned, the specific remaining
unknown, and the recommended documented assumption so the downstream initiative
proceeds rather than stalls. Mark `n/a` (with reason) if the question was settled.>

---

## Storage and Naming (convention — delete this section in a filled-in finding)

A completed finding is a durable, tracked artifact. It lives under:

```
project-documents/user/notes/nnn-notes.{finding-name}.md
```

where `nnn` is the **spike slice's index** (carrying the Discovery base-index
lineage) and `{finding-name}` is a short kebab-case description. Examples:

- `101-notes.world-state-finding.md`  (finding for slice 101)
- `102-notes.fork-boundary-finding.md`  (finding for slice 102)

This matches `file-naming-conventions.md`: `notes` docType, index lineage, and the
`{type}.{subject}.md` filename shape. The completed finding is committed; the spike
code under `spikes/` that produced it is not.
