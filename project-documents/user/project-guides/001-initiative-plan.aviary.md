---
docType: initiative-plan
layer: project
project: aviary
source: user/project-guides/000-concept.aviary.md
dateCreated: 20260617
dateUpdated: 20260617
status: in_progress
---

# Initiative Plan: aviary

## Source
000-concept.aviary.md

## Index Convention
20-based gap (100, 120, 140). Standard default — appropriate for ~3 infrastructure
initiatives with modest expected growth. Wider gaps were considered but rejected:
the project is small and the natural expansion (multi-agent, reasoning studies)
will arrive as new capability work, not as subdivision of these initiatives.
Indices are tentative and may be re-indexed if initiatives are added or reorganized.

## Scope Note
Capability R&D — improving complex building and autonomous task completion (later,
multi-agent collaboration and reasoning studies) — is intentionally **not** an
initiative. It is the *purpose of the project*; every initiative below exists to
make that R&D possible and measurable. It is planned as ongoing capability work
driven by measured deltas against the baseline, not as a bounded body of
architecture/slice work.

## Initiatives

1. [ ] **(100) Discovery** — Resolve the two highest-uncertainty unknowns via
   throwaway spikes, before downstream design commits. (a) Mindcraft capability
   mapping: what the runtime can do today, where it is practically modifiable, and
   what a fork would need to add versus upstream — the basis for the aviary/fork
   boundary. (b) World-state query mechanism: bot's own mineflayer view vs.
   independent observer connection vs. server-side (RCON/plugin), including the
   efficiency dimension (how much state, how often). Output is findings that refine
   the concept and seed both downstream initiatives — not production code.
   Dependencies: None (foundation). Status: not_started

2. [ ] **(120) Eval Harness** — The ruler. Task definition format (repeatable,
   version-controllable), a runner that sets a task against the agent, and scoring
   via programmatic world-state checks plus task completion/telemetry (duration,
   action/token counts, `!newAction` error capture). Establishes the baseline by
   running the *unmodified upstream* runtime against the evals. Built in Python.
   Dependencies: [100] (needs the world-state query answer). Status: not_started

3. [ ] **(140) Orchestration / Tool Surface** — CLI-first control to spawn/kill
   bots, inject tasks, query world state, and collect results; the means to
   automate complex agent tasks. Early containerization of the runtime lands here
   (demonstration of good practice + reinforces the aviary/fork boundary). An MCP
   tool surface may follow the CLI. Built in Python; runtime stays the Node.js
   Mindcraft fork consumed as an external dependency.
   Dependencies: [100] (needs the Mindcraft capability/fork-boundary findings);
   [120] informational (should be aware of the eval result/telemetry contract but
   can design independently). Status: not_started

## Cross-Initiative Dependencies
- 120 depends on 100: the eval harness's world-state checks cannot be designed
  until the world-state query mechanism is chosen (view vs. observer vs.
  server-side). Blocking.
- 140 depends on 100: orchestration scope and the fork boundary depend on knowing
  what Mindcraft already provides and where it is modifiable. Blocking.
- 140 informational on 120: orchestration collects eval results, so it should be
  aware of the harness's result/telemetry contract, but does not block on it for
  architecture design.

## Notes
- Indices are tentative and may be reassigned as initiatives are added or
  reorganized.
- New initiatives discovered during development are added here with the next
  available base index. Likely future additions (not yet initiatives): multi-agent
  collaboration, reasoning/eval research — these arrive as new capability work once
  the baseline and infrastructure exist.
- Capability R&D is tracked as ongoing measured work, not as an initiative here
  (see Scope Note).
- Check off initiatives as their architecture documents and slice plans are complete.
