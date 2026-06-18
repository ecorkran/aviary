---
docType: review
layer: project
reviewType: arch
slice: discovery
project: squadron
verdict: CONCERNS
sourceDocument: project-documents/user/architecture/100-arch.discovery.md
aiModel: z-ai/glm-5
status: complete
dateCreated: 20260617
dateUpdated: 20260617
findings:
  - id: F001
    severity: concern
    category: completeness
    summary: "No exit criteria or acceptance definition for findings"
    location: 100-arch.discovery.md#envisioned-state
  - id: F002
    severity: concern
    category: completeness
    summary: "No failure mode handling if investigations are inconclusive"
    location: unverified
  - id: F003
    severity: note
    category: completeness
    summary: "Test infrastructure requirements for world-state investigation unspecified"
    location: 100-arch.discovery.md#current-state
  - id: F004
    severity: note
    category: completeness
    summary: "Findings integration mechanism unspecified"
    location: 100-arch.discovery.md#envisioned-state
  - id: F005
    severity: note
    category: completeness
    summary: "Spike code disposal mechanism absent despite stated risk"
    location: 100-arch.discovery.md#architectural-principles
---

# Review: arch — slice 100

**Verdict:** CONCERNS
**Model:** z-ai/glm-5

## Findings

### [CONCERN] No exit criteria or acceptance definition for findings

The Envisioned State section states "At completion, Discovery has produced two findings" but provides no criteria for what constitutes a sufficient finding. Technical Considerations hints at requirements ("finding must include enough cost data to inform the Eval Harness design, not just a yes/no on mechanism") and "concrete modification points," but these aren't formalized as acceptance criteria. The Anticipated Slices section defers to "slice planning (Phase 3)" for boundary formalization, but the architecture document itself should define what "done" looks like—minimum required sections for each finding, evidence bar, or decision criteria. Without this, there's no clear stopping point; the Mindcraft capability mapping could expand indefinitely since "surveying enough" is undefined.

### [CONCERN] No failure mode handling if investigations are inconclusive

Discovery initiatives can fail or produce inconclusive results. The document doesn't address what happens if: Mindcraft capability mapping reveals no practical modification points (the runtime is less extensible than hoped); world-state query mechanisms are all prohibitively expensive; or empirical investigation yields ambiguous results with no clear winner. The downstream initiatives (120 Eval Harness, 140 Orchestration) are explicitly blocked on these findings with no recovery mechanism specified. The architecture should define escalation paths—who decides when findings are inconclusive, what fallback decisions exist, and whether downstream work can proceed with documented assumptions.

### [NOTE] Test infrastructure requirements for world-state investigation unspecified

Current State mentions "a working bot" (singular), but the world-state query investigation might require additional infrastructure: the independent-observer approach needs a second bot/connection, and meaningful cost measurement requires controlled test scenarios plus network monitoring tools. The document should clarify whether this infrastructure is already available, part of spike scope, or to be spun up as-needed.

### [NOTE] Findings integration mechanism unspecified

The document states "The concept and initiative plan are updated to reflect resolved unknowns" but doesn't specify: where findings documents are stored, what template/format they use, how updates to dependent documents are triggered, or who approves findings as complete. This is addressable during execution but should be clarified to ensure findings actually flow back to concept and initiative plan as intended.

### [NOTE] Spike code disposal mechanism absent despite stated risk

The Principles correctly identify the risk of "spike harden[ing] into the first version of a real subsystem" and instruct to "resist" this. However, no mechanism is specified for: where probe code lives during investigation, how it's disposed of after findings are produced, or what prevents accidental commitment. A concrete mitigation (e.g., "spike code lives in `/spikes/` with explicit `.gitignore`, deleted after finding merged") would strengthen the guard against the identified antipattern.
