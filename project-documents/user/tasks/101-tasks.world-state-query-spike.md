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
status: complete
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

- [x] **Task 0 — Branch for slice work**
  - [x] Confirm working directory is the repo root
    (`/home/manta/source/repos/minecraft/aviary`)
  - [x] Confirm tree is clean (`git status`); confirm slice 100 work is present on
    `main` (the `spikes/` workspace and `discovery-finding.template.md` exist)
  - [x] Create and switch to the slice branch from `main`:
    `git checkout -b 101-slice.world-state-query-spike`
  - [x] **Success:** on branch `101-slice.world-state-query-spike`, tree clean,
    branched from `main`; `spikes/README.md` and the findings template both present
  - Effort: 1/5

- [x] **Task 1 — Start the finding from the template**
  - [x] Copy the findings template to the conventional finding path:
    `cp project-documents/user/templates/discovery-finding.template.md project-documents/user/notes/101-notes.world-state-finding.md`
    (materialize `user/notes/` if needed)
  - [x] Fill frontmatter: `slice: world-state-query-spike`, `dateCreated` (today),
    `status: in_progress`
  - [x] Delete the template's trailing "Storage and Naming (convention …)" section —
    it is template scaffolding, not finding content (the template says to delete it
    in a filled-in finding)
  - [x] Write the **Question** field: "How should aviary read ground-truth world
    state for eval scoring, and at what cost?" (one question, per the design)
  - [x] Leave remaining fields as stubs to fill as evidence accrues
  - [x] **Success:** `101-notes.world-state-finding.md` exists with valid `notes`
    frontmatter, the Question filled, and all eight field headings present
  - Effort: 1/5

- [x] **Task 2 — Bring up the stack and confirm baseline readiness**
  - [x] Confirm the Paper server is listening: `ss -ltn | grep :25565` (start it if
    not, per the project's stack startup; it is the long-running half)
  - [x] Bring up the upstream Mindcraft runtime and connect the bot using the
    existing profile (this also starts the Socket.IO `MindServer`, default `:8080`)
  - [x] Confirm the bot is in-world (visible to the server; the runtime logs a
    successful spawn) and that **no agent-behavior or runtime-source changes** were
    made to bring it up
  - [x] Record into the finding's **Method** field: the stack components exercised
    (Paper 1.21.6 on :25565, upstream Mindcraft runtime, MindServer on :8080) and
    that the runtime is unmodified
  - [x] **Success:** server on :25565, MindServer on :8080, a bot spawned in-world;
    Method field notes the unmodified baseline being probed
  - Effort: 2/5

## Mechanism 1 — Mineflayer View

- [x] **Task 3 — Mineflayer-view read probe**
  - [x] Under `spikes/world-state/`, write a throwaway probe that reads world state
    through the runtime's **existing** `world.js` helpers (do not re-implement them):
    at minimum position, health/food, time, biome, nearby entities, nearby blocks,
    and inventory counts (the helpers used by `mindcraft/src/agent/commands/queries.js`)
  - [x] The probe must be **read-only**: it reads the live bot's view; it does not
    issue actions or alter agent behavior
  - [x] Run the probe against the live bot; capture the raw state it returns
  - [x] Record raw outputs into the finding's **Evidence / Observations** field
  - [x] **Success:** the probe prints real world state for all the listed read
    categories from the live bot; outputs captured in the finding
  - Effort: 3/5

- [x] **Task 4 — Measure mineflayer-view cost (test-with for Task 3)**
  - [x] Extend/re-run the probe to capture the three cost dimensions: (a) **payload
    size** of a representative combined read (order-of-magnitude bytes/fields),
    (b) a **sustainable read frequency** (reads/sec held steady for a short window
    without degrading the bot or saturating the channel), (c) the **channel** the
    read crosses to reach a would-be Python consumer
  - [x] Record all three into the finding's **Cost notes** field with real numbers
    (order-of-magnitude, not a tuned benchmark — per the design's anti-over-benchmark
    guidance)
  - [x] **Success:** Cost notes contains observed payload size, a sustained read
    frequency, and the channel — concrete enough for 120 to design against
  - Effort: 2/5

- [x] **Task 5 — Ground-truth comparison (test-with for Task 3)**
  - [x] Establish independently-known ground truth (e.g. operator-placed blocks or
    entities at known coordinates, or a server-side `/data`-style truth reference)
  - [x] Re-read via the mineflayer-view probe and compare what the view reports
    against that ground truth
  - [x] Capture **at least one concrete example** of agreement and (if any) one of
    divergence; record into **Evidence / Observations**
  - [x] In the finding, characterize the **bot-perception-vs-ground-truth gap**
    concretely — enough to judge whether the mineflayer view is trustworthy as the
    scoring authority
  - [x] **Success:** the finding contains at least one observed ground-truth
    comparison example and a concrete description of the perception gap
  - Effort: 3/5

## Seam — Python ↔ Node

- [x] **Task 6 — Characterize the Python↔Node seam**
  - [x] Determine how a **Python** caller would obtain the mineflayer-view state
    today over the existing Socket.IO `MindServer` bridge
    (`mindcraft/src/mindcraft-py/mindcraft.py`, `mindcraft/src/mindcraft/mindserver.js`):
    do the existing events carry world-state reads, or what minimal addition would be
    needed?
  - [x] If a quick Python-side check is useful, place it under `spikes/world-state/`
    too (throwaway). Do **not** build a production state-transfer protocol — only
    characterize the channel and the shape of the data crossing it
  - [x] Record into the finding's **Implications for downstream initiatives** field:
    the protocol/shape, whether the existing bridge suffices, and any minimal
    addition required (a note for 120/140, not built here)
  - [x] **Success:** the finding states whether/how world-state reads flow over the
    existing `MindServer` bridge to Python, with the protocol/shape noted; no
    transfer subsystem was built
  - Effort: 3/5

## Mechanism 2 — Independent Observer (conditional)

- [x] **Task 7 — Decide whether the observer probe is warranted**
  - [x] Using Task 5's gap evidence, judge whether the mineflayer view is trustworthy
    enough as the scoring authority for 120
  - [x] Record the **decision and its rationale** in the finding's **Decision** field
    (this is the F003 resolution in practice: build the observer **only if** the view
    is insufficient)
  - [x] If the view **clears the bar:** mark Task 8 **n/a with a one-line reason** in
    the finding (the observer was considered and not needed — never silently skipped)
    and proceed to Task 9
  - [x] If the view is **insufficient:** proceed to Task 8
  - [x] **Success:** the finding records, with rationale, whether the independent
    observer is needed; the gate decision is explicit, not implicit
  - Effort: 1/5

- [x] **Task 8 — Independent-observer probe (only if Task 7 says warranted)**
  - [x] Under `spikes/world-state/`, stand up a **minimal observer-only** connection
    (a second/headless connection that reports what is actually there), used to
    characterize the gap the mineflayer view could not close
  - [x] Keep it minimal: characterize the gap and the observer's cost (same three
    dimensions as Task 4); do **not** build a reusable observer subsystem
  - [x] Record the observer's evidence and cost into **Evidence / Observations** and
    **Cost notes**; state the **accepted coupling** trade (independent connection vs.
    eval-to-runtime) in the **Decision** field
  - [x] **Success:** if built, the observer yields concrete gap + cost evidence and
    the finding states the coupling accepted and why; if not built, this task is
    marked n/a in the finding per Task 7
  - Effort: 3/5

## Finalize Finding

- [x] **Task 9 — Complete the Decision, coupling, and Confidence fields**
  - [x] Fill **Decision**: the chosen mechanism (mineflayer view / independent
    observer / server-side, or a **staged path** — e.g. "view now with a documented
    accuracy caveat; revisit an observer if scoring proves it insufficient"),
    justified by the observed evidence above, not documentation
  - [x] Ensure the **accepted coupling** is stated with rationale (eval-to-runtime via
    the bot view vs. independent connection)
  - [x] Fill **Confidence**: how strongly the evidence supports the choice and what
    would change it
  - [x] **Success:** Decision names a mechanism (or staged path) grounded in observed
    behavior; coupling stated with rationale; Confidence filled
  - Effort: 2/5

- [x] **Task 10 — Resolve the Inconclusive → next step field (F002)**
  - [x] If the question was **settled:** mark the field `n/a` with a one-line reason
    (never delete it)
  - [x] If **not settled** (all mechanisms prohibitively expensive, or none yields
    trustworthy ground truth): record the dead ends and the **cost wall hit** (the
    specific numbers), a **recommended fallback** so 120 is unblocked with a stated
    assumption (e.g. "proceed with mineflayer view + named accuracy caveat"), and the
    specific remaining unknown + what evidence would resolve it
  - [x] **Success:** the field is either justified `n/a` or carries a downstream-
    unblocking documented assumption — 120 is never left hard-blocked
  - Effort: 1/5

- [x] **Task 11 — Verify the finding is complete (test-with for Tasks 1-10)**
  - [x] Confirm all eight fields are filled to the bar (n/a fields justified, not
    deleted):
    `grep -cE '^## (Question|Method|Evidence / Observations|Decision|Cost notes|Implications for downstream initiatives|Confidence|Inconclusive → next step)$' project-documents/user/notes/101-notes.world-state-finding.md`
    → expect `8`
  - [x] Confirm the finding's frontmatter is valid `notes`-docType YAML per
    `file-naming-conventions.md`; set `status: complete`
  - [x] Cross-check each finding field against the slice design's "Finding — required
    content" table (each field meets its slice-specific bar)
  - [x] **Success:** grep prints 8; frontmatter valid; every field meets its bar per
    the design table
  - Effort: 1/5

- [x] **Task 12 — Commit the finding checkpoint**
  - [x] Confirm scope guard: `git status --short spikes/` prints **nothing** (all
    probe code under `spikes/world-state/` is gitignored and uncommitted)
  - [x] `git add project-documents/user/notes/101-notes.world-state-finding.md`
  - [x] Commit: `docs: record world-state query spike finding (slice 101)`
  - [x] **Success:** the finding is committed; no `spikes/` content is staged or
    committed; `git status` clean apart from any pending concept update (Task 13)
  - Effort: 1/5

## Close the Loop

- [x] **Task 13 — Update the concept's Open Questions**
  - [x] In the concept (`user/project-guides/000-concept.aviary.md`), update the
    **world-state mechanism** Open Question to reflect the finding's decision (or its
    documented scoped assumption), referencing the finding
  - [x] Commit: `docs: update concept open questions from world-state finding`
  - [x] **Success:** the concept's world-state Open Question reflects the resolved (or
    scoped) decision and points to `101-notes.world-state-finding.md`
  - Effort: 1/5

## Final Validation

- [x] **Task 14 — Run the full slice verification walkthrough**
  - [x] Execute the slice design's **Verification Walkthrough** steps 1-6 against the
    actual probes and confirm each behaves as described: stack up; mineflayer-view
    read works and is measured; ground-truth comparison observable; seam
    characterized; finding exists/complete/committed; spike code disposable and
    uncommitted (`git status --short spikes/` prints nothing — contents gitignored
    per slice 100)
  - [x] Confirm all slice **Success Criteria** are met: mechanism chosen (justified by
    observed behavior); cost characterized on all four dimensions; coupling stated;
    perception gap described with an example; seam characterized; finding recorded;
    concept updated
  - [x] Confirm scope/baseline guards held: **no durable subsystem committed**, the
    **baseline unmodified**, probes read-only
  - [x] Optionally delete the spent probe workspace: `rm -rf spikes/world-state`
    (allowed any time after the finding is recorded)
  - [x] **Success:** every walkthrough step passes; all slice Success Criteria met;
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

### Implementation addendum (2026-06-18)

Completed against the live stack. Outcome: **mineflayer view chosen**, cost is
bimodal (scalar reads free; 16-radius block scans ~75 ms / ~13/sec dominate), view
matches server ground truth exactly within loaded chunks. Finding:
`user/notes/101-notes.world-state-finding.md`.

Caveats discovered (folded into the slice design's Verification Walkthrough):
- **`world.js` is not usable standalone with a bare `mineflayer.createBot()`** — it
  needs `mcdata` initialized on login. The probe must use the runtime's own
  `initBot()` (`mindcraft/src/utils/mcdata.js`), which is also aviary's real
  connection path (loads plugins, throttles position packets for Paper). This is
  itself a finding for downstream consumers.
- Probe deps (`mineflayer`, `vec3`) import from the runtime's `node_modules` by path
  (`spikes/` has none of its own); `vec3` is CommonJS (default import).
- **Task 7/8 gate (F003) resolved: independent-observer NOT built as a separate
  step** — the view matched ground truth exactly, so it is trustworthy as the scoring
  authority. The `view-probe` was itself an independent read-only connection, so the
  observer's cost/shape was characterized for free and recorded as an available
  decoupling option, not a requirement.
- **Seam finding (richer than anticipated):** a world-state channel to Python already
  exists — `MindServer`'s `listen-to-agents` → `state-update` push at ~1 Hz, carrying
  scalar state only (via `src/agent/library/full_state.js`), deliberately omitting the
  expensive block scans. Block-region ground truth would need a small addition or the
  eval's own mineflayer connection.
