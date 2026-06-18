---
docType: tasks
slice: world-state-query-spike
project: aviary
lld: user/slices/101-slice.world-state-query-spike.md
dependencies: [100-slice.spike-workspace-and-findings-convention]
projectState: >
  Discovery (100) arch + slice plan in place. Slice 100 (spike workspace +
  findings convention) complete and merged to main: gitignored `spikes/`
  workspace with tracked marker, `discovery-finding.template.md`, and the
  `user/notes/` finding-storage convention all exist. Slice 101 design approved
  (`user/slices/101-slice.world-state-query-spike.md`). Stack: Paper 1.21.6
  server reachable on :25565; upstream Mindcraft runtime (gitignored) connects a
  bot via the Socket.IO MindServer (default :8080) and exposes world-read helpers
  at `mindcraft/src/agent/library/world.js`; a Python bridge exists at
  `mindcraft/src/mindcraft-py/`. No world-state probe code exists yet.
dateCreated: 20260618
dateUpdated: 20260618
status: not_started
---

## Context Summary

- Working on the **101-slice.world-state-query-spike** slice — the first feature
  spike of the Discovery initiative (100).
- **Goal (one question):** how should aviary read ground-truth world state for eval
  scoring, and at what cost? Answered **empirically** against the live, unmodified
  stack — not from documentation.
- **This is a spike.** All probe code is throwaway and lives under the gitignored
  `spikes/world-state/` (from slice 100). The **durable artifact is the finding**,
  not the code. Nothing under `spikes/` is committed.
- **Delivers:** a completed finding at
  `project-documents/user/notes/101-notes.world-state-finding.md` (copied from
  `discovery-finding.template.md`, all eight fields filled to the bar) plus an
  update to the concept's Open Questions (world-state mechanism).
- **Mechanism evaluation order** (cheapest/least-coupled first, stop at first that
  clears the bar): (1) bot's **mineflayer view** via the runtime's existing
  `world.js` helpers; (2) **independent observer** — built **only if** the view is
  insufficient for trustworthy ground truth (resolves review F003: conditionally in
  scope); (3) **server-side** named as the authoritative ground-truth reference, not
  built unless both lighter options fail.
- **Seam:** Python↔Node is the existing Socket.IO `MindServer` bridge
  (`mindcraft/src/mindcraft-py/mindcraft.py`). The spike **characterizes** whether
  world state flows over it — it does **not** build a transfer protocol.
- **Baseline discipline:** probes are **read-only against the baseline** — they may
  read via `world.js` and open an observer connection, but must not change agent
  behavior or modify the runtime's tracked source.
- **Unblocks:** initiative 120 (Eval Harness), which designs its world-state checks
  against this finding's mechanism + cost numbers.
- **Next planned slice:** 102 (Mindcraft Capability and Fork-Boundary Spike) —
  independent of 101, may run in parallel.

## Pre-Work

- [ ] **Task 0 — Branch for slice work**
  - [ ] Confirm working directory is the repo root
    (`/home/manta/source/repos/minecraft/aviary`)
  - [ ] Confirm tree is clean (`git status`); confirm slice 100 work is present on
    `main` (the `spikes/` workspace and `discovery-finding.template.md` exist)
  - [ ] Create and switch to the slice branch from `main`:
    `git checkout -b 101-slice.world-state-query-spike`
  - [ ] **Success:** on branch `101-slice.world-state-query-spike`, tree clean,
    branched from `main`; `spikes/README.md` and the findings template both present
  - Effort: 1/5

- [ ] **Task 1 — Start the finding from the template**
  - [ ] Copy the findings template to the conventional finding path:
    `cp project-documents/user/templates/discovery-finding.template.md project-documents/user/notes/101-notes.world-state-finding.md`
    (materialize `user/notes/` if needed)
  - [ ] Fill frontmatter: `slice: world-state-query-spike`, `dateCreated` (today),
    `status: in_progress`
  - [ ] Delete the template's trailing "Storage and Naming (convention …)" section —
    it is template scaffolding, not finding content (the template says to delete it
    in a filled-in finding)
  - [ ] Write the **Question** field: "How should aviary read ground-truth world
    state for eval scoring, and at what cost?" (one question, per the design)
  - [ ] Leave remaining fields as stubs to fill as evidence accrues
  - [ ] **Success:** `101-notes.world-state-finding.md` exists with valid `notes`
    frontmatter, the Question filled, and all eight field headings present
  - Effort: 1/5

- [ ] **Task 2 — Bring up the stack and confirm baseline readiness**
  - [ ] Confirm the Paper server is listening: `ss -ltn | grep :25565` (start it if
    not, per the project's stack startup; it is the long-running half)
  - [ ] Bring up the upstream Mindcraft runtime and connect the bot using the
    existing profile (this also starts the Socket.IO `MindServer`, default `:8080`)
  - [ ] Confirm the bot is in-world (visible to the server; the runtime logs a
    successful spawn) and that **no agent-behavior or runtime-source changes** were
    made to bring it up
  - [ ] Record into the finding's **Method** field: the stack components exercised
    (Paper 1.21.6 on :25565, upstream Mindcraft runtime, MindServer on :8080) and
    that the runtime is unmodified
  - [ ] **Success:** server on :25565, MindServer on :8080, a bot spawned in-world;
    Method field notes the unmodified baseline being probed
  - Effort: 2/5

## Mechanism 1 — Mineflayer View

- [ ] **Task 3 — Mineflayer-view read probe**
  - [ ] Under `spikes/world-state/`, write a throwaway probe that reads world state
    through the runtime's **existing** `world.js` helpers (do not re-implement them):
    at minimum position, health/food, time, biome, nearby entities, nearby blocks,
    and inventory counts (the helpers used by `mindcraft/src/agent/commands/queries.js`)
  - [ ] The probe must be **read-only**: it reads the live bot's view; it does not
    issue actions or alter agent behavior
  - [ ] Run the probe against the live bot; capture the raw state it returns
  - [ ] Record raw outputs into the finding's **Evidence / Observations** field
  - [ ] **Success:** the probe prints real world state for all the listed read
    categories from the live bot; outputs captured in the finding
  - Effort: 3/5

- [ ] **Task 4 — Measure mineflayer-view cost (test-with for Task 3)**
  - [ ] Extend/re-run the probe to capture the three cost dimensions: (a) **payload
    size** of a representative combined read (order-of-magnitude bytes/fields),
    (b) a **sustainable read frequency** (reads/sec held steady for a short window
    without degrading the bot or saturating the channel), (c) the **channel** the
    read crosses to reach a would-be Python consumer
  - [ ] Record all three into the finding's **Cost notes** field with real numbers
    (order-of-magnitude, not a tuned benchmark — per the design's anti-over-benchmark
    guidance)
  - [ ] **Success:** Cost notes contains observed payload size, a sustained read
    frequency, and the channel — concrete enough for 120 to design against
  - Effort: 2/5

- [ ] **Task 5 — Ground-truth comparison (test-with for Task 3)**
  - [ ] Establish independently-known ground truth (e.g. operator-placed blocks or
    entities at known coordinates, or a server-side `/data`-style truth reference)
  - [ ] Re-read via the mineflayer-view probe and compare what the view reports
    against that ground truth
  - [ ] Capture **at least one concrete example** of agreement and (if any) one of
    divergence; record into **Evidence / Observations**
  - [ ] In the finding, characterize the **bot-perception-vs-ground-truth gap**
    concretely — enough to judge whether the mineflayer view is trustworthy as the
    scoring authority
  - [ ] **Success:** the finding contains at least one observed ground-truth
    comparison example and a concrete description of the perception gap
  - Effort: 3/5

## Seam — Python ↔ Node

- [ ] **Task 6 — Characterize the Python↔Node seam**
  - [ ] Determine how a **Python** caller would obtain the mineflayer-view state
    today over the existing Socket.IO `MindServer` bridge
    (`mindcraft/src/mindcraft-py/mindcraft.py`, `mindcraft/src/mindcraft/mindserver.js`):
    do the existing events carry world-state reads, or what minimal addition would be
    needed?
  - [ ] If a quick Python-side check is useful, place it under `spikes/world-state/`
    too (throwaway). Do **not** build a production state-transfer protocol — only
    characterize the channel and the shape of the data crossing it
  - [ ] Record into the finding's **Implications for downstream initiatives** field:
    the protocol/shape, whether the existing bridge suffices, and any minimal
    addition required (a note for 120/140, not built here)
  - [ ] **Success:** the finding states whether/how world-state reads flow over the
    existing `MindServer` bridge to Python, with the protocol/shape noted; no
    transfer subsystem was built
  - Effort: 3/5

## Mechanism 2 — Independent Observer (conditional)

- [ ] **Task 7 — Decide whether the observer probe is warranted**
  - [ ] Using Task 5's gap evidence, judge whether the mineflayer view is trustworthy
    enough as the scoring authority for 120
  - [ ] Record the **decision and its rationale** in the finding's **Decision** field
    (this is the F003 resolution in practice: build the observer **only if** the view
    is insufficient)
  - [ ] If the view **clears the bar:** mark Task 8 **n/a with a one-line reason** in
    the finding (the observer was considered and not needed — never silently skipped)
    and proceed to Task 9
  - [ ] If the view is **insufficient:** proceed to Task 8
  - [ ] **Success:** the finding records, with rationale, whether the independent
    observer is needed; the gate decision is explicit, not implicit
  - Effort: 1/5

- [ ] **Task 8 — Independent-observer probe (only if Task 7 says warranted)**
  - [ ] Under `spikes/world-state/`, stand up a **minimal observer-only** connection
    (a second/headless connection that reports what is actually there), used to
    characterize the gap the mineflayer view could not close
  - [ ] Keep it minimal: characterize the gap and the observer's cost (same three
    dimensions as Task 4); do **not** build a reusable observer subsystem
  - [ ] Record the observer's evidence and cost into **Evidence / Observations** and
    **Cost notes**; state the **accepted coupling** trade (independent connection vs.
    eval-to-runtime) in the **Decision** field
  - [ ] **Success:** if built, the observer yields concrete gap + cost evidence and
    the finding states the coupling accepted and why; if not built, this task is
    marked n/a in the finding per Task 7
  - Effort: 3/5

## Finalize Finding

- [ ] **Task 9 — Complete the Decision, coupling, and Confidence fields**
  - [ ] Fill **Decision**: the chosen mechanism (mineflayer view / independent
    observer / server-side, or a **staged path** — e.g. "view now with a documented
    accuracy caveat; revisit an observer if scoring proves it insufficient"),
    justified by the observed evidence above, not documentation
  - [ ] Ensure the **accepted coupling** is stated with rationale (eval-to-runtime via
    the bot view vs. independent connection)
  - [ ] Fill **Confidence**: how strongly the evidence supports the choice and what
    would change it
  - [ ] **Success:** Decision names a mechanism (or staged path) grounded in observed
    behavior; coupling stated with rationale; Confidence filled
  - Effort: 2/5

- [ ] **Task 10 — Resolve the Inconclusive → next step field (F002)**
  - [ ] If the question was **settled:** mark the field `n/a` with a one-line reason
    (never delete it)
  - [ ] If **not settled** (all mechanisms prohibitively expensive, or none yields
    trustworthy ground truth): record the dead ends and the **cost wall hit** (the
    specific numbers), a **recommended fallback** so 120 is unblocked with a stated
    assumption (e.g. "proceed with mineflayer view + named accuracy caveat"), and the
    specific remaining unknown + what evidence would resolve it
  - [ ] **Success:** the field is either justified `n/a` or carries a downstream-
    unblocking documented assumption — 120 is never left hard-blocked
  - Effort: 1/5

- [ ] **Task 11 — Verify the finding is complete (test-with for Tasks 1-10)**
  - [ ] Confirm all eight fields are filled to the bar (n/a fields justified, not
    deleted):
    `grep -cE '^## (Question|Method|Evidence / Observations|Decision|Cost notes|Implications for downstream initiatives|Confidence|Inconclusive → next step)$' project-documents/user/notes/101-notes.world-state-finding.md`
    → expect `8`
  - [ ] Confirm the finding's frontmatter is valid `notes`-docType YAML per
    `file-naming-conventions.md`; set `status: complete`
  - [ ] Cross-check each finding field against the slice design's "Finding — required
    content" table (each field meets its slice-specific bar)
  - [ ] **Success:** grep prints 8; frontmatter valid; every field meets its bar per
    the design table
  - Effort: 1/5

- [ ] **Task 12 — Commit the finding checkpoint**
  - [ ] Confirm scope guard: `git status --short spikes/` prints **nothing** (all
    probe code under `spikes/world-state/` is gitignored and uncommitted)
  - [ ] `git add project-documents/user/notes/101-notes.world-state-finding.md`
  - [ ] Commit: `docs: record world-state query spike finding (slice 101)`
  - [ ] **Success:** the finding is committed; no `spikes/` content is staged or
    committed; `git status` clean apart from any pending concept update (Task 13)
  - Effort: 1/5

## Close the Loop

- [ ] **Task 13 — Update the concept's Open Questions**
  - [ ] In the concept (`user/project-guides/000-concept.aviary.md`), update the
    **world-state mechanism** Open Question to reflect the finding's decision (or its
    documented scoped assumption), referencing the finding
  - [ ] Commit: `docs: update concept open questions from world-state finding`
  - [ ] **Success:** the concept's world-state Open Question reflects the resolved (or
    scoped) decision and points to `101-notes.world-state-finding.md`
  - Effort: 1/5

## Final Validation

- [ ] **Task 14 — Run the full slice verification walkthrough**
  - [ ] Execute the slice design's **Verification Walkthrough** steps 1-6 against the
    actual probes and confirm each behaves as described: stack up; mineflayer-view
    read works and is measured; ground-truth comparison observable; seam
    characterized; finding exists/complete/committed; spike code disposable and
    uncommitted (`git status --short spikes/` prints nothing — contents gitignored
    per slice 100)
  - [ ] Confirm all slice **Success Criteria** are met: mechanism chosen (justified by
    observed behavior); cost characterized on all four dimensions; coupling stated;
    perception gap described with an example; seam characterized; finding recorded;
    concept updated
  - [ ] Confirm scope/baseline guards held: **no durable subsystem committed**, the
    **baseline unmodified**, probes read-only
  - [ ] Optionally delete the spent probe workspace: `rm -rf spikes/world-state`
    (allowed any time after the finding is recorded)
  - [ ] **Success:** every walkthrough step passes; all slice Success Criteria met;
    scope/baseline guards hold; 120 is unblocked
  - Effort: 2/5

## Notes

- **Test-with mapping:** this slice has no unit-testable executable logic — the
  "tests" are evidence-verification tasks placed immediately after the probe that
  produces the evidence: Task 4 (cost) and Task 5 (ground truth) validate Task 3's
  mineflayer-view probe; Task 11 validates the assembled finding (Tasks 1-10). This
  preserves the test-with discipline for a spike whose output is a finding, not code.
- **Conditional branch (Tasks 7-8):** the independent-observer probe is built **only
  if** Task 7 judges the mineflayer view insufficient — the review-F003 "is observer
  infrastructure in scope?" decision, resolved at runtime on evidence. If skipped, it
  is marked `n/a` with a reason in the finding, never silently dropped.
- **No tool guide consulted:** no curated guide exists for mineflayer / Mindcraft in
  `ai-project-guide/tool-guides/`. The spike reads through the runtime's existing
  `world.js` helpers (mineflayer 4.33) and the existing Socket.IO `MindServer` bridge
  rather than introducing a new library. The `context7` MCP may be used for
  mineflayer API reference if a helper's behavior is unclear.
- **No `package.json` added:** probe code lives under the gitignored `spikes/` and
  installs any dependency locally there (or reuses the runtime's `node_modules`) —
  the npm-scripts setup task does not apply; the runtime's tracked `package.json` is
  not modified.
- **Scope discipline is the primary risk** (per slice design): the mineflayer-view
  probe is genuinely useful code and tempts hardening into a subsystem. The gitignored
  `spikes/` workspace plus the "no durable subsystem" guard counter this — the probe
  is discarded once the finding is recorded.
