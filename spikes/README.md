# Spike Workspace

This directory holds **disposable** Discovery spike code — throwaway probes that
answer a single question against the live stack (Paper server + upstream
Mindcraft).

- Its contents are **gitignored**. Nothing here is committed; only this marker
  (`spikes/README.md`) is tracked. See the `.gitignore` rule (`spikes/*` then
  `!spikes/README.md`).
- **Findings, not code, are the durable artifact.** Record what a spike learns in
  a finding note — copy `project-documents/user/templates/discovery-finding.template.md`
  and store the filled-in result under `project-documents/user/notes/` (see that
  template for the storage and naming convention).
- A spike directory under `spikes/` may be **deleted at any time** once its
  finding is recorded. The probe code is scaffolding; the finding is the keep.

This separation is deliberate: spike code is disposable and untracked so it can
never silently harden into the first version of a real subsystem.
