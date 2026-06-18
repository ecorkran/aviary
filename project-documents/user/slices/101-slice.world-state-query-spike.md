---
docType: slice-design
slice: world-state-query-spike
project: aviary
parent: user/architecture/100-slices.discovery.md
dependencies: [100-slice.spike-workspace-and-findings-convention]
interfaces: []
dateCreated: 20260618
dateUpdated: 20260618
status: not_started
---

# Slice Design: World-State Query Spike

## Overview

This is the first feature spike of the Discovery initiative (100). It answers one
empirical question: **how should aviary read ground-truth world state for eval
scoring, and at what cost?** The arch doc names this as one of the two
highest-uncertainty unknowns blocking downstream design — the Eval Harness (120)
cannot design its world-state checks without it.

The spike exercises candidate query mechanisms against the **live, unmodified**
stack (Paper 1.21.6 server + upstream Mindcraft runtime), measures their cost, and
records a single finding using the Discovery findings template established by slice
100. It produces **no durable subsystem** — only throwaway probe code under
`spikes/` and a committed finding under `user/notes/`.

The mechanism question has three candidates the arch doc already names:
1. **Bot's own mineflayer view** — what the agent perceives, read through the
   runtime's existing `world.js` helpers (mineflayer 4.33).
2. **Independent observer** — a second, observer-only connection reporting what is
   *actually* there, decoupled from the agent.
3. **Server-side** — reading state from the Paper server directly (RCON, plugin,
   or log/query channel).

This spike must choose among them (or a staged path between them) on **observed
behavior**, not documentation.

## Value

Architectural enablement (de-risks the highest-value downstream initiative):

- **Unblocks the Eval Harness (120).** 120 scores agent runs against ground-truth
  world state. It cannot design its checks — what it reads, how often, over what
  channel, with what accuracy — until this finding gives it real interfaces and real
  numbers. This spike is the ordered-first Discovery spike precisely because it
  gates the highest-value downstream work.
- **Replaces a guess with a measurement.** The concept leans toward the mineflayer
  view with a *temptation* toward an independent observer, but "no measurement
  supports a choice" (arch doc, Current State). This spike supplies the measurement.
- **Characterizes the bot-perception-vs-ground-truth gap concretely.** The gap
  between what the agent believes and what is actually there is itself a capability
  signal and decides which source is authoritative for scoring. This spike describes
  it with observed examples, not assumption.
- **Maps the Python↔Node seam for state transfer.** aviary proper is Python; the
  runtime is Node. How Python will ultimately read this state (protocol, bridge,
  IPC) informs both 120 and 140. A bridge already exists in the runtime
  (Socket.IO `MindServer`); this spike characterizes whether world state can flow
  across it.

## Technical Scope

**Included:**

- Throwaway probe code under `spikes/world-state/` (gitignored per slice 100) that:
  - reads world state through the **bot's mineflayer view** using the runtime's
    existing `src/agent/library/world.js` helpers (position, health/food, time,
    biome, nearby entities, nearby blocks, inventory) — exercising the view aviary
    would actually use, not a hand-rolled re-implementation;
  - measures the **cost** of those reads: payload size (how much state), achievable
    frequency (how often a read can be issued), and the channel it crosses;
  - probes the **Python↔Node seam** — confirms whether/how world-state reads can be
    surfaced to a Python caller over the existing Socket.IO `MindServer` bridge
    (`src/mindcraft-py/`), since that is how Python aviary will ultimately read it.
- A **conditional, staged** independent-observer probe (see Technical Decisions):
  built **only if** the mineflayer view proves insufficient for trustworthy ground
  truth. If built, it is a minimal observer-only connection used to characterize the
  perception-vs-ground-truth gap — not a finished subsystem.
- A single completed finding at
  `project-documents/user/notes/101-notes.world-state-finding.md`, copied from
  `discovery-finding.template.md` and filled to this slice's Success Criteria bar.
- An update to the concept's **Open Questions** (world-state mechanism) reflecting
  the resolved (or scoped) decision.

**Explicitly excluded:**

- **Any production world-state subsystem, client, or library.** This is a spike; its
  code is disposable. Building a reusable "WorldStateReader" here would invert the
  baseline-first discipline and pre-empt the Eval Harness's own design.
- **Any modification to agent behavior or the unmodified runtime.** Discovery probes
  the *baseline*. The spike may add read-only probe code under `spikes/` and may
  stand up an observer connection, but must not change how the agent acts (that
  would compromise the baseline the Eval Harness later establishes). Reading through
  existing `world.js` helpers is observation, not modification.
- **An exhaustive benchmark.** Cost characterization is "enough numbers for 120 to
  design against" (order-of-magnitude payload size, a sustainable read frequency,
  the channel), not a tuned performance study.
- **Resolving the fork-boundary question.** That is slice 102. This spike notes any
  seam findings relevant to 102 but does not decide the boundary.

## Dependencies

### Prerequisites

- **[100] Spike Workspace and Findings Convention — complete.** Provides the
  gitignored `spikes/` workspace for probe code, the `discovery-finding.template.md`
  to copy, and the `user/notes/` storage + naming convention for the finding.
  (Confirmed complete and on `main`.)
- **The live stack, runnable.** Paper 1.21.6 server reachable on `:25565` and the
  upstream Mindcraft runtime able to connect a bot with the existing profile. (Stack
  was stood up and verified per the arch doc's Current State; the server is the
  long-running half, the runtime/bot is brought up per-spike.)

### Interfaces Required

- **From the runtime (read-only):** `src/agent/library/world.js` (the existing
  world-read helpers) and the bot's mineflayer instance they operate on. The spike
  consumes these as the "mineflayer view" candidate.
- **From the runtime (seam):** the Socket.IO `MindServer` bridge
  (`src/mindcraft/mindserver.js`, `src/mindcraft-py/mindcraft.py`) as the existing
  Python↔Node channel to characterize.
- **From slice 100:** the findings template and storage convention (documents, not
  code).

## Architecture

### Component Structure

Everything this spike builds is disposable and lives under `spikes/world-state/`.
The durable output is the finding. The runtime and server are exercised, not
modified.

| Component | Location | Tracked? | Role |
|---|---|---|---|
| Mineflayer-view probe | `spikes/world-state/` | No (gitignored) | Reads world state via the runtime's `world.js` helpers; records payload + frequency |
| Seam probe | `spikes/world-state/` | No | Confirms whether world-state reads can surface to a Python caller over the `MindServer` Socket.IO bridge |
| Independent-observer probe (conditional) | `spikes/world-state/` | No | Built only if the mineflayer view is insufficient; a minimal observer-only connection to characterize the ground-truth gap |
| World-state finding | `project-documents/user/notes/101-notes.world-state-finding.md` | Yes | The durable artifact: chosen mechanism + cost + coupling + gap, per template |

The unmodified runtime (`mindcraft/`) and Paper server (`server/`) are **inputs the
spike reads against**, not components it owns. Both are gitignored runtime/upstream
already.

### Data Flow

The spike's measurement flow:

1. Bring up the stack: Paper server (already up on `:25565`) and the Mindcraft
   runtime with a bot connected (via the existing profile / `MindServer`).
2. **Mineflayer-view read:** invoke the `world.js` helpers against the live bot and
   capture (a) the state returned and (b) its size; repeat at increasing cadence to
   find a sustainable read frequency. Record over what channel the read crosses to
   reach a would-be Python consumer.
3. **Seam check:** determine how a Python caller would obtain that state today —
   whether the existing Socket.IO `MindServer` events can carry world-state reads,
   or what minimal addition would be required — and note the protocol/shape.
4. **Ground-truth comparison:** compare what the mineflayer view reports against
   independently-known ground truth (e.g. blocks/entities the operator placed, or
   `/data`-style server truth) to characterize the perception gap. If the gap is
   unacceptable for scoring, escalate to the conditional independent-observer probe.
5. Record observations, costs, the chosen mechanism, the accepted coupling, and the
   gap into the finding's fields as evidence accrues.
6. When every template field is filled to the Success Criteria bar, commit the
   finding; **discard the `spikes/world-state/` code** (it is never committed).
7. Update the concept's Open Questions (world-state mechanism) and the finding's
   "implications for downstream initiatives" — closing the loop to the living
   concept and handing off to 120.

## Technical Decisions

### Mechanism evaluation order (and what "chosen" means)

Evaluate in ascending cost/coupling order, stopping as soon as a candidate clears
the bar for trustworthy, affordable ground truth:

1. **Mineflayer view first.** It is the cheapest (no second connection), it is what
   the agent already perceives, and the read helpers already exist in `world.js`.
   The spike exercises it first and measures it.
2. **Independent observer only if warranted.** Escalate to a second, observer-only
   connection **only if** the mineflayer view's perception gap makes it untrustworthy
   as the scoring authority. This is the **review F003 decision, resolved here:** the
   independent-observer infrastructure is **conditionally in scope** — a fallback the
   spike builds *if and only if* evidence demands it, kept minimal (characterize the
   gap, do not build a reusable observer). Defaulting to building it up front would
   violate "spike, don't build."
3. **Server-side noted, not built unless forced.** Reading from the Paper server
   directly (RCON / plugin / `/data`) is the heaviest-coupling option. The spike
   *names* it as the authoritative ground-truth source for the comparison in step 4,
   and recommends it only if both lighter mechanisms fail.

A mechanism is "chosen" when the finding justifies it from observed behavior:
adequate accuracy for scoring, acceptable cost, and an accepted coupling — possibly
as a **staged path** (e.g. "mineflayer view now with a documented accuracy caveat;
revisit an observer if scoring proves it insufficient").

### Coupling decision is a required output

The finding must state which coupling aviary accepts and why:
- **Mineflayer view** couples eval to the agent runtime (eval reads what the agent's
  connection sees).
- **Independent observer** decouples eval from the runtime at the cost of a second
  connection/headless bot.

This is a deliberate trade the finding records — not a default.

### Python↔Node seam: characterize, don't bridge-build

A Socket.IO `MindServer` bridge already exists (`src/mindcraft-py/mindcraft.py`
launches Node and speaks `socketio` events; `src/mindcraft/mindserver.js` is the
server). The spike **characterizes** whether world-state reads can flow over this
existing channel and in what shape — it does **not** build a production state-transfer
protocol. If the existing events cannot carry world state, the finding records *what
minimal addition would be needed* as an implication for 120/140, rather than building
it.

### Probe code conventions

- All probe code lives under `spikes/world-state/` and is gitignored (slice 100).
- Probes are **read-only against the baseline**: they may read via `world.js` and may
  open an observer connection, but must not alter agent behavior or modify the
  runtime's tracked source.
- Probe code is throwaway; nothing under `spikes/` is committed. If a probe wants a
  dependency, it installs it locally under `spikes/` (or reuses the runtime's
  `node_modules`), never by editing the runtime's `package.json`.

## Implementation Details

### Cost characterization — what to capture

"Enough for the Eval Harness to design against real numbers" means, at minimum:

| Dimension | What to record |
|---|---|
| **How much state** | Approximate payload size of a representative world-state read (e.g. position + health + nearby entities + nearby blocks + inventory) — order of magnitude in bytes/fields, not a tuned figure. |
| **How often** | A sustainable read frequency observed without degrading the bot or saturating the channel (e.g. "N reads/sec held steady for M seconds"). |
| **Over what channel** | The path the state crosses to reach a Python consumer (in-process Node → Socket.IO `MindServer` → Python client), and any serialization cost noted. |
| **Accuracy** | How closely the chosen source matches independently-known ground truth, with at least one concrete example of agreement and (if any) divergence. |

### Finding — required content (maps to template + Success Criteria)

The finding at `101-notes.world-state-finding.md` fills every
`discovery-finding.template.md` field; the slice-specific bar per field:

| Template field | This slice's bar |
|---|---|
| **Question** | "How should aviary read ground-truth world state for eval scoring, and at what cost?" (one question). |
| **Method** | Which probes were run, against the live stack, observing what — establishing the finding rests on observed behavior. |
| **Evidence / Observations** | The captured reads, payload sizes, frequencies, and at least one ground-truth comparison example. |
| **Decision** | The chosen mechanism (or staged path), stated as the answer 120 designs against. |
| **Cost notes** | The four cost dimensions above, with real numbers. |
| **Implications for downstream initiatives** | What 120 should assume/design against (interface, channel, accuracy caveat); any seam note relevant to 140. |
| **Confidence** | How strongly the evidence supports the choice and what would change it. |
| **Inconclusive → next step** | `n/a` (with reason) if settled; otherwise the F002 path below. |

## Integration Points

### Provides to Other Slices

- **To initiative 120 (Eval Harness):** the chosen world-state query mechanism, its
  cost numbers, the accepted coupling, the bot-perception-vs-ground-truth gap, and
  the Python↔Node seam characterization — everything 120 needs to design its
  world-state checks against real interfaces.
- **To initiative 140 (Orchestration):** any seam/bridge findings noted in passing
  (how Python talks to the runtime), without deciding the fork boundary (that is 102).

### Consumes from Other Slices

- **From [100]:** the `spikes/` workspace, the findings template, and the
  `user/notes/` storage convention. No code interface.

## Success Criteria

These mirror the slice plan's Success Criteria for slice 101, made specific enough
for task creation.

### Functional Requirements

- **A query mechanism is chosen** (mineflayer view / independent observer /
  server-side, or a staged path), with the choice **justified by observed behavior,
  not documentation.**
- **Cost is characterized** along all four dimensions (how much state, how often,
  over what channel, accuracy) — with real numbers, enough for 120 to design its
  checks against.
- **The accepted coupling is stated** (eval-to-runtime via the bot view vs.
  independent connection) with rationale.
- **The bot-perception-vs-ground-truth gap is described concretely** — with at least
  one observed example — enough to decide which source is authoritative for scoring.
- **The Python↔Node seam is characterized** — whether/how world-state reads flow over
  the existing Socket.IO `MindServer` bridge, or what minimal addition would be
  needed.
- **The finding is recorded** in `101-notes.world-state-finding.md` per the template,
  every field filled to the bar (n/a fields justified, not deleted).
- **The concept's Open Questions** (world-state mechanism) are updated.

### Technical Requirements

- **No durable subsystem is committed.** All probe code stays under the gitignored
  `spikes/world-state/`; only the finding (and the concept update) are committed.
- **The baseline is unmodified.** No change to agent behavior or to the runtime's
  tracked source; probes are read-only against the live stack.
- **The committed finding carries valid `notes`-docType frontmatter** per
  `file-naming-conventions.md`.

### Inconclusive path (review F002)

If **all** mechanisms prove prohibitively expensive, or **none** yields trustworthy
ground truth within reasonable effort, the finding does **not** stall — it records:
- the dead ends explored and the **cost wall hit** (the specific numbers that made a
  mechanism untenable);
- a **recommended fallback** so 120 is unblocked with a stated assumption — e.g.
  "proceed with the mineflayer view plus a documented accuracy caveat," naming the
  caveat;
- the specific remaining unknown and what evidence would resolve it.

The "Inconclusive → next step" field carries this; downstream initiative 120 proceeds
on a documented assumption rather than being hard-blocked.

### Verification Walkthrough

This is the demo script the user follows to confirm the spike delivered. It is a
**draft** to be refined when Phase 6 (Implementation) completes with the actual probe
commands and observed numbers. Run from the repo root
(`/home/manta/source/repos/minecraft/aviary`).

1. **Stack is up.** Confirm the Paper server is listening and bring up the runtime
   bot:
   ```
   ss -ltn | grep :25565            # server reachable (long-running half)
   # bring up the Mindcraft runtime + bot per the existing profile / MindServer
   ```
   Expect the server on `:25565` and a bot connected (the `MindServer` Socket.IO
   endpoint, default `:8080`, listening once the runtime is up).

2. **Mineflayer-view read works and is measured.** Run the mineflayer-view probe and
   observe it reading real world state via the existing `world.js` helpers:
   ```
   node spikes/world-state/<view-probe>.js     # exact name set at implementation
   ```
   Expect printed world state (position, health/food, time, biome, nearby entities,
   nearby blocks, inventory) plus the captured **payload size** and a **sustained
   read frequency** — the raw cost numbers.

3. **Ground-truth comparison is observable.** Place or note a known block/entity in
   the world, re-read, and confirm the probe surfaces the agreement (and any
   divergence) the finding cites as its perception-gap example.

4. **Seam is characterized.** Confirm how a Python caller obtains the state — either
   the existing `MindServer` Socket.IO events carry it, or the finding states the
   minimal addition needed. (If a Python-side check exists, it lives under
   `spikes/world-state/` too.)

5. **Finding exists, is complete, and is committed.** Confirm the durable artifact:
   ```
   ls project-documents/user/notes/101-notes.world-state-finding.md
   grep -cE '^## (Question|Method|Evidence / Observations|Decision|Cost notes|Implications for downstream initiatives|Confidence|Inconclusive → next step)$' \
     project-documents/user/notes/101-notes.world-state-finding.md
   ```
   Expect the file to exist and the grep to print `8` (every template field present;
   each filled to the bar, n/a fields justified not deleted).

6. **Spike code is disposable, not committed.** Confirm nothing under
   `spikes/world-state/` is tracked:
   ```
   git status --short spikes/        # prints nothing (contents gitignored per slice 100)
   ```
   The finding is committed; the probe code that produced it is not. The
   `spikes/world-state/` directory may be deleted at any point after the finding is
   recorded.

When steps 1–6 behave as described, the world-state mechanism question is answered
(or scoped with a documented fallback) and initiative 120 is unblocked.

## Risk Assessment

### Technical Risks

- **Spike hardening into a subsystem.** The mineflayer-view probe is genuinely useful
  code; the temptation is to keep and grow it. The structural guard (gitignored
  `spikes/`, finding-as-artifact from slice 100) plus the explicit "no durable
  subsystem" scope line counter this — the probe is discarded once the finding is
  recorded.
- **Open-ended "is the gap acceptable?" judgment.** Deciding when the
  perception-vs-ground-truth gap is "trustworthy enough" for scoring is a judgment
  call that could expand the spike indefinitely. Bounded by: evaluate mechanisms in
  cost order, stop at the first that clears the bar, and fall back to the F002
  documented-assumption path rather than chasing perfect ground truth.

### Mitigation Strategies

- Time-box to the Success Criteria bar (template filled to the bar = done), not to
  exhaustive understanding — the explicit F001 exit criterion.
- Build the independent-observer probe **only** on evidence the mineflayer view is
  insufficient; otherwise record the staged-path decision and stop.

## Implementation Notes

### Development Approach

Suggested order (each step feeds finding fields as it produces evidence):

1. Copy `discovery-finding.template.md` to
   `project-documents/user/notes/101-notes.world-state-finding.md`; write the
   **Question** and **Method** stubs.
2. Bring up the stack; write the mineflayer-view probe under `spikes/world-state/`
   using the runtime's `world.js` helpers. Capture state + payload size + frequency.
3. Run the ground-truth comparison; record the gap example.
4. Characterize the Python↔Node seam over the existing `MindServer` bridge.
5. **Only if** the view proves insufficient: build the minimal independent-observer
   probe and characterize the gap it closes.
6. Fill **Decision**, **Cost notes**, **Implications**, **Confidence**, and
   **Inconclusive → next step**; update the concept's Open Questions.
7. Commit the finding (and concept update). Discard `spikes/world-state/`.

### Special Considerations

- **Baseline discipline.** Probes read; they do not change agent behavior or the
  runtime's tracked source. The mineflayer-view read goes through the *existing*
  `world.js` helpers precisely so the spike measures the real view aviary would use.
- **Real numbers over precision.** Cost characterization is order-of-magnitude and
  "sustainable frequency," not a tuned benchmark — enough for 120 to design against,
  per the slice plan's anti-over-benchmarking guidance.
- **Parallelism.** 101 and 102 are independent after 100 and may be designed/run
  concurrently. This spike notes seam facts useful to 102 but does not decide the
  fork boundary.
