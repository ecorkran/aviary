---
docType: changelog
scope: project-wide
---

# Changelog

All notable changes to the aviary project are documented in this file. Entries
should be concise, ideally 1-2 lines. Changes not yet released accumulate under
[Unreleased].

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Slice 101 (world-state query spike): empirical world-state finding
  (`project-documents/user/notes/101-notes.world-state-finding.md`). Mineflayer
  view chosen as the scoring source — matches server ground truth exactly within
  loaded chunks; cost is bimodal (scalar reads effectively free, 16-radius block
  scans ~75 ms / ~13/sec dominate). Existing Socket.IO `MindServer` `state-update`
  push (~1 Hz, scalar only) characterized as the Python↔Node seam. Unblocks
  initiative 120 (Eval Harness). Probe code disposable (gitignored `spikes/`).
- Slice 100 (spike workspace and findings convention): gitignored `spikes/`
  workspace with a tracked `spikes/README.md` marker, and a `discovery-finding`
  template (`project-documents/user/templates/discovery-finding.template.md`) with
  the eight required fields plus a finding storage/naming convention. Foundation
  slice for the Discovery initiative — unblocks slices 101 and 102.
