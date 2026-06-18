---
docType: slice-plan
parent: user/architecture/100-arch.discovery.md
project: aviary
dateCreated: 20260617
dateUpdated: 20260617
status: not_started
---

# Slice Plan: Discovery

## Parent Document
`user/architecture/100-arch.discovery.md` (initiative 100 — Discovery)

This initiative's deliverable is **findings, not a built subsystem**. Slices below
produce written findings backed by throwaway spike code. Success criteria are
therefore phrased around *answering questions to a defined bar*, and each spike
slice carries an explicit inconclusive-result path (addressing accepted review
findings F001 and F002 from `100-review.arch.discovery.md`).

## Foundation Work

1. [ ] **(100) Spike Workspace and Findings Convention** — Establish where spike
   code lives and how findings are recorded before any probing begins. Define a
   disposable spike location (kept out of the durable tree, e.g. a gitignored
   `spikes/` path) and a single findings template that every spike fills in:
   *question, method, evidence/observations, decision, cost notes, implications for
   downstream initiatives, confidence, and an "inconclusive → next step" field*.
   This operationalizes the arch doc's "spike, don't build / findings are the
   artifact" principles and gives the spike slices a shared definition of done.
   Effort: 1/5

## Feature Slices (in implementation order)

*Both spikes are largely independent and may run in parallel once foundation is
done. Ordered here by enablement priority: the world-state spike unblocks the
Eval Harness (120), the highest-value downstream initiative.*

1. [ ] **(101) World-State Query Spike** — Empirically determine how aviary reads
   ground-truth world state for eval scoring, and at what cost. Exercise at least
   the bot's own mineflayer view; probe an independent-observer connection if the
   view proves insufficient for ground truth. Characterize the Python↔Node seam
   (how Python aviary will ultimately read this state). Dependencies: [100].
   Risk: Medium. Effort: 3/5
   - **Success Criteria:**
     - A query mechanism is chosen (mineflayer view / independent observer /
       server-side, or a staged path between them), with the choice justified by
       observed behavior, not documentation.
     - Cost is characterized: how much state, how often, over what channel —
       enough for the Eval Harness to design its checks against real numbers.
     - The coupling accepted (eval-to-runtime vs. independent connection) is stated
       with rationale.
     - The bot-perception-vs-ground-truth gap is described concretely enough to
       decide which source is authoritative for scoring.
     - Finding recorded in the standard template; concept Open Questions updated.
   - **Inconclusive path (F002):** If all mechanisms prove prohibitively expensive
     or none yields trustworthy ground truth, the finding documents the dead ends,
     the cost wall hit, and a recommended fallback (e.g. proceed with mineflayer
     view + documented accuracy caveat) so initiative 120 is unblocked with a
     stated assumption rather than stalled.

2. [ ] **(102) Mindcraft Capability and Fork-Boundary Spike** — Map what the
   upstream runtime does today, where it is practically modifiable, and what a fork
   would need to add versus upstream. Produce an evidence-based position on the
   aviary/fork boundary. Dependencies: [100]. Risk: Medium. Effort: 3/5
   - **Success Criteria:**
     - The runtime's command/action surface, configuration knobs, and
       world-perception model are mapped from actually exercising it, not just
       reading its source.
     - Concrete modification points are identified (where a fork would intervene),
       with the author's "rudimentary vs. squadron" instinct tested against
       evidence.
     - An evidence-based aviary/fork boundary position is stated: what is wanted
       from the fork (runtime capability) vs. what stays in aviary, noting any
       points where the boundary is tempted.
     - Finding recorded in the standard template; concept Open Questions
       (fork management & boundary) updated.
   - **Inconclusive path (F002):** If the runtime proves materially less
     modifiable than hoped, or the survey cannot bound "enough" within reasonable
     effort, the finding states what was learned, names the specific unknowns that
     remain, and recommends whether initiative 140 proceeds with documented
     assumptions or whether a deeper, separately-scoped investigation is warranted.

## Notes

- **Exit criteria (F001):** "Sufficient finding" is defined by the foundation
  slice's findings template plus each spike's Success Criteria. A spike is done
  when its template is filled to the criteria bar — not when the systems are
  exhaustively understood. This bounds the open-ended "surveying enough" risk the
  review flagged.
- **Inconclusive handling (F002):** Every spike carries an explicit inconclusive
  path so downstream initiatives are never hard-blocked with no recovery — they
  proceed on a documented assumption, with the gap recorded.
- **Spike disposal (F005):** Foundation slice (100) defines the disposable spike
  location and disposal expectation up front, rather than leaving "resist building"
  as an exhortation.
- **No integration work:** This is a knowledge initiative; there is no subsystem to
  integrate. Findings flow back into the concept and initiative plan as their
  integration.
- **Parallelism:** 101 and 102 are independent after 100 and may be designed and
  run concurrently.
- **Test infrastructure (review F003):** The independent-observer option in 101 may
  require a second connection/headless bot; whether that infrastructure is in scope
  is decided during slice design (Phase 4) for 101.

## Future Work
*(none identified yet — backlog for items surfaced during slice design,
task breakdown, or implementation)*
