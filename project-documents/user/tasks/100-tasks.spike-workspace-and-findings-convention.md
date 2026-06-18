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
status: not_started
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

- [ ] **Task 0 — Branch for slice work**
  - [ ] Confirm working directory is the repo root
    (`/home/manta/source/repos/minecraft/aviary`)
  - [ ] Confirm current branch is `main` and tree is clean (`git status`)
  - [ ] Create and switch to the slice branch from `main`:
    `git checkout -b 100-slice.spike-workspace-and-findings-convention`
  - [ ] **Success:** on branch `100-slice.spike-workspace-and-findings-convention`,
    tree clean, branched from `main`
  - Effort: 1/5

## Spike Workspace

- [ ] **Task 1 — Add the `.gitignore` rule for the spike workspace**
  - [ ] Append a rule to the repo-root `.gitignore` that ignores `spikes/`
    contents while re-including the marker:
    `spikes/*` then `!spikes/README.md`
  - [ ] Place it under a clear comment (e.g. `# disposable discovery spike code`)
  - [ ] **Success:** `.gitignore` contains both lines in order; existing rules
    (`server/`, `mindcraft/`, `keys.json`, etc.) are unchanged
  - Effort: 1/5

- [ ] **Task 2 — Create the spike workspace marker**
  - [ ] Create `spikes/README.md` (this also materializes the directory)
  - [ ] Content per slice design "Workspace Marker — Content Outline": states the
    directory holds **disposable** Discovery spike code; contents are gitignored
    (only the marker is tracked); findings (not code) are the durable artifact —
    see the findings template and `user/notes/`; a spike dir may be deleted any
    time after its finding is recorded
  - [ ] **Success:** `spikes/README.md` exists with the four points above
  - Effort: 1/5

- [ ] **Task 3 — Verify the ignore behavior (test-with for Tasks 1-2)**
  - [ ] Create a throwaway file: `echo "scratch" > spikes/probe-test/scratch.js`
  - [ ] Run `git status --short spikes/` — confirm `spikes/probe-test/scratch.js`
    does **not** appear (ignored)
  - [ ] Run `git check-ignore -v spikes/README.md`; confirm it is **not** ignored
    (no match; exit code 1)
  - [ ] Run `git check-ignore -v spikes/probe-test/scratch.js`; confirm it **is**
    ignored (prints a match line)
  - [ ] Clean up: `rm -rf spikes/probe-test`
  - [ ] **Success:** marker is tracked; arbitrary spike content is ignored; cleanup
    leaves only `spikes/README.md` under `spikes/`
  - Effort: 1/5

- [ ] **Task 4 — Commit the workspace checkpoint**
  - [ ] `git add .gitignore spikes/README.md`
  - [ ] Commit: `feat: add gitignored spikes workspace with marker`
  - [ ] **Success:** commit present; `git status` clean; `git log --oneline -1`
    shows the commit
  - Effort: 1/5

## Findings Template

- [ ] **Task 5 — Create the findings template skeleton + frontmatter**
  - [ ] Create `project-documents/user/templates/discovery-finding.template.md`
    (materializing `user/templates/` if needed)
  - [ ] Add valid YAML frontmatter per `file-naming-conventions.md`:
    `docType: notes`, plus fill-in stubs for `slice`, `dateCreated`, `status`
  - [ ] **Success:** file exists with frontmatter; `docType` is `notes`; frontmatter
    parses as valid YAML
  - Effort: 1/5

- [ ] **Task 6 — Add the eight required finding fields**
  - [ ] Add one markdown section per field, in this order, each with a one-line
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
  - [ ] Add a note in the template that a non-applicable field is marked `n/a` with
    a one-line reason — never deleted
  - [ ] **Success:** all eight headings present and ordered; each has guidance text;
    the n/a convention is stated
  - Effort: 2/5

- [ ] **Task 7 — Write the finding-storage + naming convention**
  - [ ] Document the convention (in the template's body or an adjacent short note):
    completed findings live in `project-documents/user/notes/` named
    `nnn-notes.{finding-name}.md`, where `nnn` is the spike slice's index
    (e.g. `101-notes.world-state-finding.md`)
  - [ ] Confirm the convention is consistent with `file-naming-conventions.md`
    (notes docType, index lineage)
  - [ ] **Success:** the storage location and naming pattern are written down and
    match `file-naming-conventions.md`
  - Effort: 1/5

- [ ] **Task 8 — Verify the template is complete and copyable (test-with for Tasks 5-7)**
  - [ ] Print the template and confirm all eight fields are present
    (`sed -n '1,80p' project-documents/user/templates/discovery-finding.template.md`)
  - [ ] Dry-run the convention: copy the template to
    `project-documents/user/notes/101-notes.world-state-finding.md` (materializing
    `user/notes/` if needed) and confirm the path/name matches
    `nnn-notes.{finding-name}.md`
  - [ ] Remove the dry-run copy (101 is not being started yet):
    `rm project-documents/user/notes/101-notes.world-state-finding.md`
  - [ ] **Success:** all eight fields confirmed present; the template copies cleanly
    to a convention-compliant path; dry-run copy removed
  - Effort: 1/5

- [ ] **Task 9 — Commit the template checkpoint**
  - [ ] `git add project-documents/user/templates/discovery-finding.template.md`
    (and any `user/notes/` placeholder if one was intentionally kept)
  - [ ] Commit: `docs: add discovery finding template and storage convention`
  - [ ] **Success:** commit present; `git status` clean
  - Effort: 1/5

## Final Validation

- [ ] **Task 10 — Run the full slice verification walkthrough**
  - [ ] Execute steps 1-5 of the slice design's **Verification Walkthrough** and
    confirm each behaves as described (marker documented; spike code ignored;
    marker tracked; template complete; convention dry-run passes)
  - [ ] Confirm no probe code, tooling, scripts, or dependencies were introduced
    (scope guard)
  - [ ] Confirm all new markdown carries valid frontmatter per
    `file-naming-conventions.md`
  - [ ] **Success:** every walkthrough step passes; scope guard holds; the slice's
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
