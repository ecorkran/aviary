---
docType: slice-design
slice: spike-workspace-and-findings-convention
project: aviary
parent: user/architecture/100-slices.discovery.md
dependencies: []
interfaces: [101-slice.world-state-query-spike, 102-slice.mindcraft-capability-and-fork-boundary-spike]
dateCreated: 20260618
dateUpdated: 20260618
status: complete
---

# Slice Design: Spike Workspace and Findings Convention

## Overview

This is the foundation slice of the Discovery initiative (100). Before any probing
begins, it establishes the two pieces of shared infrastructure every Discovery
spike depends on:

1. **A disposable spike workspace** — a gitignored location where throwaway probe
   code lives, structurally separated from the durable tree so a spike cannot
   silently harden into a real subsystem.
2. **A findings template** — a single document skeleton every spike fills in, so a
   spike's *answer* (not its code) is the durable artifact and "done" means
   "template filled to the bar," not "system exhaustively understood."

It operationalizes the arch doc's two governing principles — *spike, don't build*
and *findings are the artifact* — by giving them a physical home and a shared
definition of done. This slice writes **no probe code itself**; it sets up the
conventions the 101 and 102 spikes will use.

## Value

Architectural enablement (developer-facing, for the project author as sole
implementer):

- **Unblocks 101 and 102.** Both spikes declare a dependency on [100]; they cannot
  record a finding to the criteria bar without the template, and cannot place probe
  code without an agreed disposable location. Doing this once, up front, prevents
  each spike from inventing its own ad-hoc structure.
- **Operationalizes the discipline.** The arch doc's "resist letting a spike harden
  into the first version of a real subsystem" stops being an exhortation and becomes
  a structural fact: spike code lives in a gitignored path, so it is never committed
  and never accumulates into the durable tree.
- **Defines "sufficient finding" (review F001).** The template's required fields are
  the exit criteria for the open-ended "surveying enough" risk — a spike is done
  when every field is filled to its slice's Success Criteria.
- **Bakes in the inconclusive path (review F002).** The template has a first-class
  "inconclusive → next step" field, so a spike that hits a wall still produces a
  usable, downstream-unblocking artifact rather than nothing.

## Technical Scope

**Included:**

- A gitignored `spikes/` directory at the repo root for disposable probe code, with
  a committed marker that explains its purpose and disposal expectation (the marker
  is the only tracked file under `spikes/`).
- A `.gitignore` rule that ignores `spikes/` contents while keeping the marker
  tracked.
- A findings template document under the durable tree, with the field set fixed by
  the slice plan (question, method, evidence/observations, decision, cost notes,
  implications for downstream initiatives, confidence, inconclusive → next step).
- A short, written convention for *where a completed finding lives* and *how it is
  named*, consistent with `file-naming-conventions.md`, so 101/102 don't each decide
  this independently.

**Explicitly excluded:**

- Any probe/spike code (that is 101 and 102 work).
- Any tooling, scripts, or automation around the template (no generator, no linter).
  A copy-and-fill markdown template is the whole mechanism — adding tooling here
  would itself violate "spike, don't build."
- Any Python or Node packaging, dependency setup, or test harness. The world-state
  spike (101) decides its own test-infra needs per the slice plan; this slice does
  not pre-build them.

## Dependencies

### Prerequisites

- None. This is the foundation slice; it depends only on the repo existing and the
  Discovery arch + slice-plan docs being in place (they are, committed to `main`).

### Interfaces Required

- The findings-storage convention must align with `file-naming-conventions.md`
  (indices, docType, frontmatter). No code interfaces are required.

## Architecture

### Component Structure

Two artifacts, in two locations, with a clear durable/disposable split:

| Artifact | Location | Tracked? | Role |
|---|---|---|---|
| Spike workspace | `spikes/` (repo root) | No (gitignored) | Holds throwaway probe code for 101/102 |
| Workspace marker | `spikes/README.md` | Yes | Explains purpose + disposal expectation; the only tracked file under `spikes/` |
| Findings template | `project-documents/user/templates/discovery-finding.template.md` | Yes | The skeleton every spike copies and fills |
| Completed findings | `project-documents/user/notes/` (per convention below) | Yes | The durable artifact a spike produces |

The split is the architecture: **code is disposable and untracked; findings are
durable and tracked.** Crossing that line (committing spike code, or producing a
finding that lives only as code comments) is the failure mode this structure
prevents.

### Data Flow

A spike's lifecycle, which this slice defines but does not execute:

1. Author copies `discovery-finding.template.md` to a new finding note.
2. Author writes probe code under `spikes/<spike-name>/` and runs it against the
   live stack (Paper server + upstream Mindcraft).
3. Observations and costs are recorded into the finding's fields as evidence
   accrues.
4. When every template field is filled to the slice's Success Criteria bar, the
   finding is committed and the spike is "done."
5. Spike code under `spikes/` is left to be discarded — never committed, never
   promoted into the durable tree.
6. The finding's "implications for downstream initiatives" and the concept's Open
   Questions are updated, closing the loop back to the living concept.

This slice delivers steps 0's preconditions: the template (for step 1), the
workspace + ignore rule (for steps 2 and 5), and the storage convention (for
step 4).

## Technical Decisions

### Technology Choices

- **Plain gitignored directory, not a separate branch or submodule, for spike code.**
  A `spikes/` path ignored by git is the simplest thing that enforces "disposable":
  it is physically present for running, invisible to commits, and removable with a
  single `rm -rf`. A branch or submodule adds ceremony and a path back into the
  durable history — exactly what we want to avoid. *Rejected:* a throwaway branch
  (still in history; tempts promotion-by-merge) and an out-of-repo scratch dir
  (loses co-location with the stack and the marker's documentation).
- **A committed `spikes/README.md` marker rather than a fully-empty ignored dir.**
  Git does not track empty directories, and an unexplained ignored path invites
  confusion later. A single tracked marker file both materializes the directory and
  documents *why it exists and that its contents are throwaway*. The `.gitignore`
  rule ignores everything under `spikes/` except this marker.
- **A copy-and-fill markdown template, no tooling.** The findings template is a
  static `.md` skeleton kept in `user/templates/`. There is deliberately no
  generator or validator — per the project's "resist adding complexity" principle
  and the arch doc's anti-build stance, the mechanism is "copy the file, fill the
  fields."
- **Findings stored as `notes` docType under `user/notes/`.** Per
  `file-naming-conventions.md`, a finding is investigative output, not a slice or
  architecture artifact; `notes` is the fitting docType. Findings carry the Discovery
  base index lineage (e.g. `101-notes.world-state-finding.md`,
  `102-notes.fork-boundary-finding.md`) so they trace to their spike slice.

### Patterns and Conventions

- **`.gitignore` rule shape:** ignore the workspace contents, re-include the marker:
  ```
  spikes/*
  !spikes/README.md
  ```
  This keeps the marker tracked while everything else under `spikes/` is ignored.
- **Finding naming:** `nnn-notes.{finding-name}.md` under `project-documents/user/notes/`,
  where `nnn` is the spike slice's index. Aligns with the existing index-lineage
  convention.
- **Template field set is fixed by the slice plan** and must not be silently trimmed
  by a spike. A field that genuinely does not apply is marked "n/a" with a one-line
  reason — never deleted — so reviewers can see it was considered.

## Implementation Details

### Findings Template — Specification

The template (`discovery-finding.template.md`) carries `docType: notes` frontmatter
and the following required sections, matching the slice-plan field set verbatim:

| Field | Purpose |
|---|---|
| **Question** | The single, specific question this spike answers. One question per finding. |
| **Method** | How it was probed — what was run, against what, observing what. Establishes the finding rests on *observed behavior*, not docs (arch "measure, don't assume"). |
| **Evidence / Observations** | The raw observations: outputs, measurements, behaviors seen. The factual basis for the decision. |
| **Decision** | The answer reached and the choice made. The headline output. |
| **Cost notes** | Efficiency/cost characteristics observed (e.g. how much state, how often, over what channel) — required so downstream initiatives design against real numbers. |
| **Implications for downstream initiatives** | What 120 (Eval Harness) and/or 140 (Orchestration) should now assume or design against. The hand-off. |
| **Confidence** | How strongly the evidence supports the decision; what would change it. |
| **Inconclusive → next step** | If the question could not be settled: what was learned, the specific remaining unknown, and the recommended documented assumption so the downstream initiative proceeds rather than stalls (review F002). |

The template includes one line of guidance under each heading and a frontmatter stub
for the copying author to fill (`slice`, `dateCreated`, `status`).

### Workspace Marker — Content Outline

`spikes/README.md` (tracked) states, briefly:

- This directory holds **disposable** Discovery spike code.
- Its contents are **gitignored** — nothing here is committed; only this marker is.
- Findings, not code, are the durable artifact — see the findings template and
  `user/notes/`.
- A spike directory may be deleted at any time after its finding is recorded.

## Integration Points

### Provides to Other Slices

- **To 101 and 102:** the `spikes/` workspace to place probe code, the
  `discovery-finding.template.md` to copy, and the `user/notes/` storage +
  naming convention for the completed finding. After this slice, both spikes can be
  designed (Phase 4) and run without inventing their own structure.

### Consumes from Other Slices

- Nothing. Foundation slice with no upstream dependency.

## Success Criteria

### Functional Requirements

- A `spikes/` directory exists at the repo root with a tracked `spikes/README.md`
  marker documenting its purpose and disposal expectation.
- `.gitignore` ignores `spikes/` contents while keeping `spikes/README.md` tracked;
  a file created under `spikes/` (other than the marker) does not appear in
  `git status`.
- `discovery-finding.template.md` exists in `user/templates/` with all eight
  required fields from the slice-plan field set and correct `notes`-docType
  frontmatter.
- The finding storage + naming convention is written down (in the template or an
  adjacent note) and is consistent with `file-naming-conventions.md`.

### Technical Requirements

- No probe code, tooling, scripts, or dependencies are introduced (scope guard:
  this slice is structure only).
- All committed markdown carries valid YAML frontmatter per
  `file-naming-conventions.md`.

### Verification Walkthrough

This is the demo script proving the slice delivers. Run from the repo root
(`/home/manta/source/repos/minecraft/aviary`). Verified end-to-end during
implementation (2026-06-18) on branch
`100-slice.spike-workspace-and-findings-convention`; actual results and caveats
recorded inline below.

1. **Workspace exists and is documented:**
   ```
   cat spikes/README.md
   ```
   Expect the marker text explaining the disposable/gitignored purpose (four
   points: disposable spike code; contents gitignored, only the marker tracked;
   findings are the durable artifact; a spike dir may be deleted after its finding
   is recorded). **Verified — present.**

2. **Spike code is ignored, marker is tracked:**
   ```
   mkdir -p spikes/probe-test && echo "scratch" > spikes/probe-test/scratch.js
   git status --short spikes/
   ```
   Expect: `spikes/probe-test/scratch.js` does **not** appear (it is ignored).
   **Verified** — once the marker is committed (Task 4), `git status --short
   spikes/` prints nothing. *Note:* before the marker is committed, this command
   instead prints `?? spikes/` (the untracked marker; the ignored scratch file is
   still correctly absent). Clean up: `rm -rf spikes/probe-test`.

3. **Marker itself is tracked, scratch is ignored** — use the *quiet* form for an
   unambiguous exit code:
   ```
   git check-ignore -q spikes/README.md ; echo "marker ignored? exit=$?"
   git check-ignore -q spikes/probe-test/scratch.js ; echo "scratch ignored? exit=$?"
   ```
   Expect: marker `exit=1` (**not** ignored), scratch `exit=0` (**is** ignored).
   **Verified.**

   **Caveat — do not use `-v` to judge the marker.** `git check-ignore -v
   spikes/README.md` reports the *last matching pattern*, which is the negation
   rule (`.gitignore:NN:!spikes/README.md`), and **exits 0**, not 1. That match
   line confirms the un-ignore rule fired — i.e. the marker is *not* ignored — but
   the exit code is the opposite of what a naive reading expects. The quiet form
   above is the reliable check. (`-v` on the scratch file behaves as expected:
   prints `.gitignore:NN:spikes/*` and exits 0.)

4. **Template is complete and copyable:**
   ```
   grep -cE '^## (Question|Method|Evidence / Observations|Decision|Cost notes|Implications for downstream initiatives|Confidence|Inconclusive → next step)$' \
     project-documents/user/templates/discovery-finding.template.md
   ```
   Expect `8` — all eight fields present, in order: Question, Method,
   Evidence / Observations, Decision, Cost notes, Implications for downstream
   initiatives, Confidence, Inconclusive → next step. **Verified — prints 8.**
   (To read the template, `sed -n '1,80p' <path>` also works.)

5. **Dry-run the convention (no commit needed):** copy the template to the
   conventional location for the next spike and confirm the path/name fits the
   convention:
   ```
   mkdir -p project-documents/user/notes
   cp project-documents/user/templates/discovery-finding.template.md \
      project-documents/user/notes/101-notes.world-state-finding.md
   ```
   Confirm the name matches `nnn-notes.{finding-name}.md`. **Verified — copies
   cleanly.** Remove it if not starting 101 yet:
   `rm project-documents/user/notes/101-notes.world-state-finding.md`. (The
   `user/notes/` directory is not committed by this slice — git does not track
   empty directories; it materializes when slice 101 writes its real finding.)

When steps 1–5 behave as described, the foundation is in place and 101/102 are
unblocked.

#### Caveat: workspace marker has no YAML frontmatter (intentional)

`spikes/README.md` deliberately carries **no** YAML frontmatter, unlike the
findings template. It is a workspace marker / signage for a gitignored scratch
directory at the repo root, not a typed `project-documents/` artifact — no docType
in `file-naming-conventions.md` fits it, and the slice design fixes its content as
four prose bullets. The frontmatter requirement applies to the project documents
this slice adds (the findings template, which carries valid `notes` frontmatter).

## Implementation Notes

### Development Approach

Small and mechanical. Suggested order:

1. Add the `.gitignore` rule (`spikes/*`, `!spikes/README.md`).
2. Create `spikes/README.md` marker.
3. Create `discovery-finding.template.md` with the eight fields and frontmatter.
4. Run the verification walkthrough; commit.

No tests beyond the verification walkthrough — there is no executable logic to test.
The walkthrough's git-status / check-ignore checks are the verification.

### Special Considerations

- **Scope discipline is the main risk here, not technical difficulty.** The
  temptation is to "just add a small helper script" or "make the template a bit
  smarter." Resist it — the whole point of this slice is to embody *spike, don't
  build*. If a helper feels necessary, that is a finding for a later initiative, not
  scope for this one.
- `user/notes/` and `user/templates/` may not yet exist; create them as needed
  (directories are materialized by their first tracked file).
