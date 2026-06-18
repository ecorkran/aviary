---
docType: concept
layer: project
phase: 0
phaseName: concept
project: aviary
audience: [human, ai]
description: Concept for aviary
dependsOn: []
dateCreated: 20260617
dateUpdated: 20260617
status: in_progress
---

# Aviary

## Overview
An orchestration and evaluation layer for LLM-driven Minecraft agents, used to develop and measure agent capabilities — starting with complex building and autonomous task completion.

## User-Provided Concept

Aviary is a Minecraft agent experiment. The goal is capability R&D toward a goal:
getting LLM-driven bots to do things well, starting with complex building and
autonomous task completion, then expanding toward multi-agent collaboration and
using Minecraft as a sandbox to study LLM reasoning/tool-use.

Critically, we want an eval baseline first — which means we need to design evals
so we can measure improvement. You can't claim improvement without a measurement
established before changing anything.

The agent runtime is a fork of Mindcraft that will live in its own separate
repo and be deployed independently (likely containerized). Aviary is the
orchestration + eval layer only — it consumes that runtime as an external
deployable dependency; it does not vendor the runtime's code.

Audience is me now, others later — clean interfaces, but no over-building for
hypothetical users yet. The orchestration interface (squadron/MCP tools vs. a
CLI) is undecided; CLI is probably fine initially. The initial concern is the
ability to perform and automate complex tasks with agents — of course with the
eval baseline in place so we can see whether they're succeeding.

We'll build this in public. It's "just a demo" in some ways — not built for a
true production use case — but hopefully it gains life and relevance as a
research project. We'll use real engineering and eval principles, probably learn
a lot, and it's fun. The subject matter lends itself easily to social media
posts, Medium articles, etc. (screenshots, video).

We'll containerize Mindcraft early, maybe at the outset — more to demonstrate
good principles than from any real security concern on my LAN. Not first
priority, but it looks easy, so we'll add it soon.

Some concern about the aviary/fork split: I'm positive we'll need to fork
Mindcraft, probably soon. The agent capabilities feel rudimentary compared to
squadron's pipeline actions and configuration. Unsure of the best way to manage
this.

Eval scoring (for the baseline) should be objective and automatable:
programmatic world-state checks (does the structure exist, did the agent reach
the location, is the inventory correct) plus task completion + telemetry
(finished?, duration, action/token count, did `!newAction` error). Subjective
build-quality scoring (rubric / LLM judge) is deliberately out of the baseline.

## Refined Concept

### Problem & Motivation
LLM-driven Minecraft agents (via Mindcraft) can execute canned commands and, with
`!newAction` enabled, write and run their own code to solve problems. But there is
no way to know whether changes to profiles, prompts, models, or the runtime itself
make the agent *better* — there is no ruler. Aviary's purpose is to be that ruler
and the harness around it: a repeatable way to set agents tasks, observe outcomes,
and score them objectively, so that capability R&D (building, autonomy) can be
driven by measured improvement rather than impression.

Why now: the underlying stack is stood up and verified (Paper 1.21.6 server,
Mindcraft runtime, working bot with `!newAction` enabled). The next bottleneck is
not "can a bot act" but "can we tell if it's getting better" — which is exactly
what aviary addresses.

### Target Users
Primary: the author, as a solo experimentation/R&D tool — optimize for iteration
speed. Secondary/future: collaborators or a wider audience, so interfaces and docs
should be clean enough to hand off, without building multi-user infrastructure now.

This is also a **build-in-public** project. It is nominally "just a demo" (no
true production use case), but the aspiration is research relevance: real
engineering and eval discipline, applied to a subject that documents well
(screenshots, video, write-ups). That public-facing intent is itself a design
input — it favors clean, demonstrable practices (e.g. containerizing the runtime
early) over the bare minimum a private lab would need.

### Solution Approach
Aviary is the orchestration + evaluation layer that sits *around* the agent
runtime. It does not contain the agent runtime. The clean boundary is deliberate:
the Mindcraft fork is its own deployable repo (its own versioning, build, and
container image); aviary consumes it as an external dependency.

The work falls into a few named capability areas (not yet sequenced initiatives —
Phase 1 will formalize):

- **Eval harness** — the first and foundational piece. Defines what a "task" is,
  runs it against the agent, and scores the outcome via world-state checks and
  telemetry. Produces the baseline.
- **Orchestration / tool surface** — the means to drive the harness and runtime:
  spawn/kill bots, inject tasks, query world state, collect results. Squadron-style
  MCP tools and/or a CLI (interface choice deferred).
- **Runtime interface (the seam)** — what aviary needs *from* the forked Mindcraft
  to orchestrate and evaluate it: process lifecycle control, world-state queries,
  task injection, and result/telemetry extraction. Discovery work maps what the
  upstream runtime already provides versus what the fork must add. The gaps found
  here become work items in the fork's own repo, not aviary's.
- **Capability R&D** — the eventual payload: improving complex building and
  autonomous task completion (later, multi-agent collaboration and reasoning
  studies), driven by measured deltas against the baseline.

The intended sequence: design evals → run the *unmodified* upstream runtime
against them to establish a baseline → then pursue capability improvements
measured against that baseline.

**On the fork (a known tension to manage, not resolve here):** a Mindcraft fork
is considered near-certain and likely soon — its agent capabilities feel
rudimentary next to the pipeline actions and configuration in the author's
existing squadron tooling. This does not break baseline-first discipline: the
baseline is measured against *unmodified upstream*, and the fork's first changes
simply become the first measured delta against the same evals. The boundary stays
clean **only while** what's wanted from the fork is *runtime capability* (richer
actions, better configuration). If orchestration logic starts wanting to live
*inside* the fork, the boundary is at risk — Phase 1/2 must watch for that and
decide deliberately. Containerizing the runtime early reinforces the boundary by
making the fork a self-contained deployable.

### Initial Technical Direction
- **Aviary implementation language:** Python — the eval/experiment/scoring layer
  is Python's home turf (data, scoring, plotting for write-ups), and the Java MC
  server is *not* a constraint since aviary talks to it over network protocols,
  never in-process. This is a clean language split: aviary in Python, runtime in
  Node.js.
- **Agent runtime:** Fork of Mindcraft (Node.js / JavaScript), separate repo,
  deployed independently. Consumed by aviary as an external dependency, not
  vendored.
- **Containerization:** Containerize the runtime early (possibly at the outset).
  Primarily a demonstration of good practice rather than a security need (host is
  LAN-only); it also reinforces the aviary/fork boundary. Low priority but cheap.
- **Server:** Paper 1.21.6, Java 21, already running (offline mode, LAN-only host).
- **Orchestration interface:** CLI likely first (scriptable, no agent-in-the-loop
  needed to automate complex tasks); a squadron-style MCP tool surface may follow.
  Not committal — settle in Phase 2. (Author has existing squadron/repowire MCP
  tooling the tool-surface approach would fit.)
- **World-state query:** Lean toward reading the bot's own view (mineflayer) the
  runtime already maintains — cheap, no extra connection. Strong temptation toward
  an *independent observer connection* for ground-truth scoring: the gap between
  "what the bot believes it built" and "what is actually there" is itself a
  capability signal, and a decoupled observer makes a more trustworthy judge.
  Likely path: start with the mineflayer view, adopt an independent observer for
  ground truth; settle with a spike. This decision also drives the efficiency
  question (how much state, how often, where to optimize).
- **Eval scoring:** Objective and automatable — programmatic world-state checks
  plus task completion/telemetry (duration, action/token counts, `!newAction`
  error capture). Rubric/LLM-judge scoring of subjective build quality is out of
  the baseline scope and may be revisited later.

### Development Approach
- Favor simplicity; avoid over-engineering for the "others later" audience.
- Baseline-first discipline: do not modify the runtime before a baseline exists,
  or there is nothing to measure against.
- Keep the aviary/fork boundary clean — resist pulling runtime code into aviary.
- Standard semantic commits and the project's existing doc/guide conventions.

### Open Questions
- **World-state query mechanism** (key efficiency + architecture decision): bot's
  own mineflayer view vs. independent observer connection vs. server-side
  (RCON/plugin). Leaning view-first with observer for ground truth; resolve with a
  spike. Drives the efficiency question (how much state, how often).
- **Fork management & boundary:** when to fork (likely soon), and how to keep the
  fork = runtime-capability / aviary = orchestration split from eroding. What,
  concretely, do we want from the fork beyond upstream Mindcraft? (Discovery work.)
- **Task definition format:** how a building/autonomy task and its success criteria
  are specified in a single repeatable, version-controllable form.
- **Orchestration interface beyond CLI:** if/when an MCP tool surface is added.
- **(Resolved this pass):** aviary language = Python; runtime = Node.js fork in a
  separate repo; containerize runtime early; CLI-first interface.
