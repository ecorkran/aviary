---
docType: architecture
layer: project
project: aviary
initiative: 100
component: discovery
source: user/project-guides/001-initiative-plan.aviary.md
dependsOn:
  - user/project-guides/000-concept.aviary.md
  - user/project-guides/001-initiative-plan.aviary.md
dateCreated: 20260617
dateUpdated: 20260617
status: not_started
---

# Architecture: Discovery (100)

## Overview

Discovery is a foundation initiative whose deliverable is **knowledge, not a
built subsystem**. It resolves the two highest-uncertainty unknowns in the
aviary concept before downstream initiatives (Eval Harness, Orchestration) commit
to a design that would be expensive to reverse.

**Scope.** Two investigations, each producing a written finding that refines the
concept and seeds a downstream initiative:
1. **Mindcraft capability mapping** — what the runtime does today, where it is
   practically modifiable, and what a fork would need to add versus upstream.
2. **World-state query mechanism** — how aviary reads ground truth from the world
   for eval scoring, and at what cost.

**Motivation.** The concept flagged both as open questions that can only be
answered empirically — by poking the actual systems, not by reasoning. They are
also *upstream* dependencies: the Eval Harness cannot design its world-state
checks without answer (2), and Orchestration cannot scope itself or place the
aviary/fork boundary without answer (1). Designing those initiatives on guessed
answers would propagate error through architecture and slices. Discovery exists to
replace guesses with measurements.

## Design Goals

- **De-risk downstream design.** Produce answers concrete enough that Eval Harness
  and Orchestration architecture can be written against real interfaces and real
  costs, not assumptions.
- **Establish the aviary/fork boundary on evidence.** Determine what is wanted from
  Mindcraft (runtime capability) versus what belongs in aviary, grounded in what
  the runtime actually exposes and where it is modifiable.
- **Choose a world-state query approach with its cost understood.** Select among
  bot-view / independent-observer / server-side, knowing the efficiency dimension
  (how much state, how often, where it can be optimized).
- **Keep findings cheap and disposable.** Spike code is a means to an answer, not a
  foundation to build on. The durable output is the written finding.
- **Feed the living concept.** Resolved unknowns flow back into the concept and
  initiative plan, keeping them honest.

## Architectural Principles

- **Spike, don't build.** Probe code exists only to answer a question and is
  expected to be thrown away. Resist letting a spike harden into the first version
  of a real subsystem — that inverts the baseline-first discipline.
- **Findings are the artifact.** Each investigation produces a written finding
  (decision + evidence + cost notes + implications for downstream initiatives), not
  a merged feature.
- **Measure, don't assume.** Both questions are empirical. A finding must rest on
  observed behavior (what mineflayer actually exposes, how Mindcraft actually
  behaves), not on documentation read or plausibility.
- **Respect the boundary while probing it.** Investigating what the fork needs must
  not quietly pull orchestration logic into the runtime. Note where the boundary is
  tempted; do not erode it in a spike.
- **Baseline-first is preserved.** Discovery probes the *unmodified upstream*
  runtime. It does not modify agent behavior — that would compromise the baseline
  the Eval Harness will later establish.

## Current State

The stack is stood up and verified: Paper 1.21.6 server, an upstream Mindcraft
runtime, a working bot with `!newAction` enabled. But two foundational questions
are unanswered:

- It is unknown how much of the world Mindcraft's bot perceives, what its action
  and configuration surface really is, and where the runtime can be practically
  modified. The concept's instinct that its capabilities feel "rudimentary versus
  squadron" is untested.
- It is unknown how aviary should read ground-truth world state for scoring, or
  what that costs in bandwidth/frequency. The concept leans toward the bot's
  mineflayer view with a temptation toward an independent observer, but no
  measurement supports a choice.

Designing Eval Harness or Orchestration now would mean designing against guesses.

## Envisioned State

At completion, Discovery has produced two findings that turn open questions into
settled (or scoped) decisions:

- **Mindcraft capability finding** — a map of the runtime's command/action surface,
  configuration knobs, world-perception model, and concrete modification points;
  an evidence-based position on the aviary/fork boundary and what a fork would add.
  Orchestration designs against this.
- **World-state finding** — a chosen query mechanism (bot-view / independent
  observer / server-side, or a staged path between them) with its cost
  characteristics documented. Eval Harness designs its world-state checks against
  this.

The concept and initiative plan are updated to reflect resolved unknowns. No
production subsystem exists from this initiative — its role in the larger system is
to make the next two initiatives designable on solid ground.

## Technical Considerations

- **Empirical access to Mindcraft internals.** Determining modification points
  requires reading and exercising the runtime, not just its docs. The challenge is
  surveying enough to make a boundary decision without sliding into building the
  fork prematurely.
- **Ground truth vs. agent perception.** The bot's mineflayer view reports what the
  *agent* believes; an independent observer reports what is *actually* there. The
  gap between them is itself a capability signal — but it complicates "which source
  is authoritative for scoring." This trade-off must be characterized, not assumed.
- **Efficiency of state transfer.** How much state is read, how often, and over
  which channel directly affects eval throughput and cost. The finding must include
  enough cost data to inform the Eval Harness design, not just a yes/no on
  mechanism.
- **Coupling risk.** Reading state via the bot's own view couples eval to the
  runtime; an independent observer decouples it at the price of a second
  connection. The finding should state which coupling aviary accepts and why.
- **Language seam.** Spikes that touch Mindcraft are Node.js/JS; aviary proper is
  Python. Probes may cross this seam — note any findings about how Python aviary
  will ultimately talk to the runtime (protocol, bridge, IPC), since that informs
  both downstream initiatives.

## Anticipated Slices (exploratory)

- **Mindcraft capability spike** — survey the runtime's actions, config, perception
  model, and modification points; produce the capability + fork-boundary finding.
- **World-state query spike** — exercise candidate mechanisms (at minimum the
  mineflayer view; an independent-observer probe if warranted), measure cost,
  produce the world-state finding.

These two are largely independent and could run in parallel. Boundaries are
provisional — slice planning (Phase 3) formalizes them.

## Related Work

- Concept: `user/project-guides/000-concept.aviary.md` (Open Questions — world-state
  mechanism, fork management & boundary)
- Initiative plan: `user/project-guides/001-initiative-plan.aviary.md`
  (initiative 100 Discovery)
- Downstream consumers: initiative 120 (Eval Harness) depends on the world-state
  finding; initiative 140 (Orchestration) depends on the capability/fork-boundary
  finding.
- Runtime under investigation: the upstream Mindcraft clone (`mindcraft/`,
  gitignored) and the running Paper 1.21.6 server.
