---
docType: tasks
slice: spike-workspace-and-findings-convention
project: aviary
lld: user/slices/100-slice.spike-workspace-and-findings-convention.md
dependencies: []
projectState: >
  Planning phases 0-3 complete and committed to main. Discovery (100) arch +
  slice plan in place. Slice 100 design approved. Stack stood up: Paper 1.21.6
  server, upstream Mindcraft clone (gitignored), bot with !newAction enabled.
  No spike workspace or findings convention exists yet. Repo on main, clean.
dateCreated: 20260618
dateUpdated: 20260618
status: complete
---

## Context Summary

- Working on the **100-slice.spike-workspace-and-findings-convention** slice — the
  foundation slice of the Discovery initiative (100).
- This slice is **structure only**: it creates a disposable spike workspace and a
  findings template/convention. It writes **no probe code** — that is slices 101
  and 102.
- **Delivers:** (1) gitignored `spikes/` workspace with a tracked marker, (2)
  `discovery-finding.template.md` with the eight slice-plan fields, (3) a written
  finding-storage + naming convention under `user/notes/`.
- **Unblocks:** slices 101 (World-State Query Spike) and 102 (Mindcraft Capability
  and Fork-Boundary Spike), both of which depend on [100].
- **Key assumption:** no tooling, scripts, or dependencies are introduced — adding
  them would violate the slice's "spike, don't build" purpose. Verification is by
  `git`-command inspection, not an executable test suite.
- **Next planned slice:** 101 (World-State Query Spike), then 102.

## Pre-Work

- [x] **Task 0 — Branch for slice work**
  - [x] Confirm working directory is the repo root
    (`/home/manta/source/repos/minecraft/aviary`)
  - [x] Confirm current branch is `main` and tree is clean (`git status`)
  - [x] Create and switch to the slice branch from `main`:
    `git checkout -b 100-slice.spike-workspace-and-findings-convention`
  - [x] **Success:** on branch `100-slice.spike-workspace-and-findings-convention`,
    tree clean, branched from `main`
  - Effort: 1/5

## Spike Workspace

- [x] **Task 1 — Add the `.gitignore` rule for the spike workspace**
  - [x] Append a rule to the repo-root `.gitignore` that ignores `spikes/`
    contents while re-including the marker:
    `spikes/*` then `!spikes/README.md`
  - [x] Place it under a clear comment (e.g. `# disposable discovery spike code`)
  - [x] **Success:** `.gitignore` contains both lines in order; existing rules
    (`server/`, `mindcraft/`, `keys.json`, etc.) are unchanged
  - Effort: 1/5

- [x] **Task 2 — Create the spike workspace marker**
  - [x] Create `spikes/README.md` (this also materializes the directory)
  - [x] Content per slice design "Workspace Marker — Content Outline": states the
    directory holds **disposable** Discovery spike code; contents are gitignored
    (only the marker is tracked); findings (not code) are the durable artifact —
    see the findings template and `user/notes/`; a spike dir may be deleted any
    time after its finding is recorded
  - [x] **Success:** `spikes/README.md` exists with the four points above
  - Effort: 1/5

- [x] **Task 3 — Verify the ignore behavior (test-with for Tasks 1-2)**
  - [x] Create a throwaway file: `echo "scratch" > spikes/probe-test/scratch.js`
  - [x] Run `git status --short spikes/` — confirm `spikes/probe-test/scratch.js`
    does **not** appear (ignored)
  - [x] Run `git check-ignore -v spikes/README.md`; confirm it is **not** ignored
    (no match; exit code 1)
  - [x] Run `git check-ignore -v spikes/probe-test/scratch.js`; confirm it **is**
    ignored (prints a match line)
  - [x] Clean up: `rm -rf spikes/probe-test`
  - [x] **Success:** marker is tracked; arbitrary spike content is ignored; cleanup
    leaves only `spikes/README.md` under `spikes/`
  - Effort: 1/5

- [x] **Task 4 — Commit the workspace checkpoint**
  - [x] `git add .gitignore spikes/README.md`
  - [x] Commit: `feat: add gitignored spikes workspace with marker`
  - [x] **Success:** commit present; `git status` clean; `git log --oneline -1`
    shows the commit
  - Effort: 1/5

## Findings Template

- [x] **Task 5 — Create the findings template skeleton + frontmatter**
  - [x] Create `project-documents/user/templates/discovery-finding.template.md`
    (materializing `user/templates/` if needed)
  - [x] Add valid YAML frontmatter per `file-naming-conventions.md`:
    `docType: notes`, plus fill-in stubs for `slice`, `dateCreated`, `status`
  - [x] **Success:** file exists with frontmatter; `docType` is `notes`; frontmatter
    parses as valid YAML
  - Effort: 1/5

- [x] **Task 6 — Add the eight required finding fields**
  - [x] Add one markdown section per field, in this order, each with a one-line
    guidance prompt under the heading (per slice design "Findings Template —
    Specification"):
    1. Question
    2. Method
    3. Evidence / Observations
    4. Decision
    5. Cost notes
    6. Implications for downstream initiatives
    7. Confidence
    8. Inconclusive → next step
  - [x] Add a note in the template that a non-applicable field is marked `n/a` with
    a one-line reason — never deleted
  - [x] **Success:** all eight headings present and ordered; each has guidance text;
    the n/a convention is stated
  - Effort: 2/5

- [x] **Task 7 — Write the finding-storage + naming convention**
  - [x] Document the convention (in the template's body or an adjacent short note):
    completed findings live in `project-documents/user/notes/` named
    `nnn-notes.{finding-name}.md`, where `nnn` is the spike slice's index
    (e.g. `101-notes.world-state-finding.md`)
  - [x] Confirm the convention is consistent with `file-naming-conventions.md`
    (notes docType, index lineage)
  - [x] **Success:** the storage location and naming pattern are written down and
    match `file-naming-conventions.md`
  - Effort: 1/5

- [x] **Task 8 — Verify the template is complete and copyable (test-with for Tasks 5-7)**
  - [x] Print the template and confirm all eight fields are present
    (`sed -n '1,80p' project-documents/user/templates/discovery-finding.template.md`)
  - [x] Dry-run the convention: copy the template to
    `project-documents/user/notes/101-notes.world-state-finding.md` (materializing
    `user/notes/` if needed) and confirm the path/name matches
    `nnn-notes.{finding-name}.md`
  - [x] Remove the dry-run copy (101 is not being started yet):
    `rm project-documents/user/notes/101-notes.world-state-finding.md`
  - [x] **Success:** all eight fields confirmed present; the template copies cleanly
    to a convention-compliant path; dry-run copy removed
  - Effort: 1/5

- [x] **Task 9 — Commit the template checkpoint**
  - [x] `git add project-documents/user/templates/discovery-finding.template.md`
    (and any `user/notes/` placeholder if one was intentionally kept)
  - [x] Commit: `docs: add discovery finding template and storage convention`
  - [x] **Success:** commit present; `git status` clean
  - Effort: 1/5

## Final Validation

- [x] **Task 10 — Run the full slice verification walkthrough**
  - [x] Execute steps 1-5 of the slice design's **Verification Walkthrough** and
    confirm each behaves as described (marker documented; spike code ignored;
    marker tracked; template complete; convention dry-run passes)
  - [x] Confirm no probe code, tooling, scripts, or dependencies were introduced
    (scope guard)
  - [x] Confirm all new markdown carries valid frontmatter per
    `file-naming-conventions.md`
  - [x] **Success:** every walkthrough step passes; scope guard holds; the slice's
    functional and technical Success Criteria are all met
  - Effort: 1/5

## Notes

- **No tool guides consulted:** this slice introduces no third-party tools,
  libraries, or `package.json` — so the npm-scripts setup task and tool-guide
  consultation steps do not apply.
- **No dedicated test infrastructure:** there is no executable logic to unit-test.
  The "test" tasks (3 and 8) are `git`/inspection verifications placed immediately
  after the implementation they validate, per the test-with pattern.
- **Scope discipline is the primary risk** (per slice design): resist adding helper
  scripts or "smarter" template tooling. If a helper feels necessary, it is a
  finding for a later initiative, not scope for this slice.
