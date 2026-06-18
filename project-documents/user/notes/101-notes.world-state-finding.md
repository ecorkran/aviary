---
docType: notes
project: aviary
slice: world-state-query-spike
dateCreated: 20260618
dateUpdated: 20260618
status: complete
---

# Discovery Finding: World-State Query Mechanism and Cost

> Finding for slice 101. Backed by throwaway probes under `spikes/world-state/`
> (gitignored, not committed) run against the live stack (Paper 1.21.6 on :25565 +
> upstream Mindcraft runtime with the `scout` agent in-world) on 2026-06-18. The
> finding is the durable artifact; the probe code is disposable.

## Question

How should aviary read ground-truth world state for eval scoring, and at what cost?

## Method

Probed the **unmodified** baseline empirically — never read from documentation alone:

- **`view-probe.mjs`** — a standalone, read-only connection created with the
  runtime's own `initBot()` (`mindcraft/src/utils/mcdata.js`), the same connection
  path aviary uses. It reads world state through the runtime's existing
  `src/agent/library/world.js` helpers (the helpers `queries.js` already uses for
  `!stats`, `!inventory`, `!nearbyBlocks`, `!entities`): position, health/food,
  time, biome, inventory, nearby entities, nearby block types, nearby players. It
  records per-read payload size and a sustained read frequency.
- **`bench-breakdown.mjs`** — times each `world.js` helper individually
  (200 iters each, 50 for the block scans) to locate where the cost actually is.
- **`groundtruth-probe.mjs`** — compares the mineflayer view against authoritative
  server truth: a `diamond_block` was placed via the Paper console
  (`setblock 375 64 -80 minecraft:diamond_block`, server-confirmed) and the view was
  queried at that exact coordinate and via the 16-radius scan.
- **Server log + console** as the independent ground-truth reference (RCON/query are
  disabled in `server.properties`; the console via the `mc` tmux session and
  `server/logs/latest.log` serve the same role).
- **Seam read** — read `mindcraft/src/mindcraft/mindserver.js`,
  `src/agent/mindserver_proxy.js`, `src/agent/library/full_state.js`, and
  `src/mindcraft-py/mindcraft.py` to determine how a Python caller obtains world
  state over the existing Socket.IO `MindServer` bridge.

All probes are read-only: no actions issued, no agent behaviour changed, no runtime
source modified. The one world mutation (the marker block) was reverted
(`setblock … minecraft:air`, server-confirmed) to leave the baseline untouched.

## Evidence / Observations

**Mineflayer view reads (all categories returned real data):**
position `{x:375.5, y:63, z:-80.5}`, health 20, food 20, timeOfDay 7163,
biome `beach`, inventory `{}` (fresh bot), nearbyEntities `["player"]` (the scout
agent), nearbyBlockTypes `[sand, water, sandstone, stone, gravel, granite, dirt,
clay, coal_ore, andesite, grass_block, short_grass, copper_ore, diorite]`.

**Ground-truth comparison (mineflayer view vs. authoritative server truth):**

| Axis | Server truth | Mineflayer view reported | Match |
|---|---|---|---|
| Bot position | log: `logged in … at (375.5, 63.0, -80.5)` | `{375.5, 63, -80.5}` | exact |
| Placed block @ (375,64,-80) | `setblock … diamond_block` (console-confirmed) | `bot.blockAt(375,64,-80) → "diamond_block"` | exact |
| Same block in 16-radius scan | present | `getNearbyBlockTypes` includes `diamond_block` | yes |
| Nearby entities | scout agent + probe online | view reports one nearby `player` | agrees |

No divergence observed on any axis. The bot's mineflayer view reflects server
ground truth for position, block state, and entity presence.

**Per-helper cost breakdown (the decisive cost result — strongly bimodal):**

| Read | ms/call | calls/sec |
|---|---|---|
| position + health + food + time | ~0 | >100k |
| `getBiomeName` | 0.005 | ~200k |
| `getInventoryCounts` | 0.005 | ~200k |
| `getNearbyPlayerNames` | 0.01 | ~100k |
| `getNearbyEntities(16)` | 0.02 | ~50k |
| **`getNearbyBlockTypes(16)`** | **76.4** | **13** |
| **`getNearestBlocks(16)`** | **73.5** | **14** |

The combined representative read (`view-probe`) measured **320 bytes/read** and a
**sustained ~14 reads/sec** — and that whole rate is consumed by the two block-scan
helpers; every other read is effectively free.

## Decision

**Read ground-truth world state from the bot's own mineflayer view** (via the
runtime's `world.js` helpers), with cost managed by read class:

- **Scalar / entity / inventory / immediate-surroundings state** — read at whatever
  frequency the eval needs; it is effectively free (sub-0.02 ms/read,
  tens of thousands/sec).
- **Block-region scans** (16-radius `getNearbyBlockTypes` / `getNearestBlocks`) — the
  only expensive reads (~75 ms each, ~13/sec ceiling). Use sparingly, with a tighter
  radius, or query a specific coordinate via `bot.blockAt` (cheap, exact) when the
  eval knows where to look.

The mineflayer view is trustworthy as the scoring authority: it matched server
ground truth exactly on every axis tested. A separate independent observer is **not
required** (see Confidence / coupling below).

**Staged path:** mineflayer view now, authoritative for scoring. If a future eval
needs truth the agent's loaded chunks can't provide (state outside render distance,
or the agent's own perception is itself under test), escalate to a server-side
source (RCON or a query plugin) for that specific check — not a wholesale switch.

## Cost notes

- **How much state:** ~320 bytes for a representative combined read (JSON-serialized:
  position, health, food, time, biome, inventory, nearby entities/blocks/players).
  Scalar fields are a few bytes; the block-type list dominates the payload.
- **How often:** scalar/entity reads sustain >50k/sec; **block-region scans cap the
  full combined read at ~14/sec** (~75 ms each). This is the number the Eval Harness
  must design against — block ground-truth is the throughput bottleneck, nothing
  else.
- **Over what channel:** the read itself is an **in-process JS call** into
  mineflayer's locally-maintained world model — **no network round-trip per read**.
  Cost is CPU (chunk iteration), not bandwidth.
- **Accuracy:** exact agreement with server truth on position (to 0.01), block
  identity at a queried coordinate, and entity presence. No observed divergence.

## Implications for downstream initiatives

**For 120 (Eval Harness) — design against these real interfaces:**

1. **Two world-state read classes, not one.** Budget block-region scans explicitly
   (~75 ms, ~13/sec); treat all other reads as free. A naive "poll everything at
   high frequency" design would be bottlenecked entirely by block scans. Prefer
   targeted `bot.blockAt(coord)` checks (cheap, exact) over broad scans when the
   eval knows the coordinate of interest.
2. **A world-state channel to Python already exists — at ~1 Hz, scalar only.** The
   Socket.IO `MindServer` exposes a **`listen-to-agents` → `state-update`** push:
   register as a listener and receive `getFullState(agent)` for every in-game agent
   **every 1000 ms** (`mindserver.js` `addListener`; payload defined by
   `src/agent/library/full_state.js`). That payload is **scalar/summary** — position,
   health/hunger, biome, weather, time, inventory + equipment, three immediate
   surrounding blocks (below/legs/head + first block above head), nearby entity
   types and player names. It deliberately **omits the expensive 16-radius block
   scans**, consistent with the cost finding.
   - If the Eval Harness needs only this scalar state, **no new bridge work** —
     consume `state-update` from Python (the bridge already uses `python-socketio`;
     see `src/mindcraft-py/mindcraft.py`).
   - If it needs block-region ground truth, that is **not** on the existing channel.
     Minimal addition: either add a request/response Socket.IO event that runs a
     scoped block query agent-side, or have the eval open its **own** read-only
     mineflayer connection (the `view-probe` shape) and read blocks directly. The
     latter needs no runtime change and was demonstrated working in this spike.
3. **Accuracy caveat is small but real:** the mineflayer view only knows **loaded
   chunks** (the bot's render distance). Ground truth outside that radius is invisible
   to the view; for such checks, a server-side source is required. Within render
   distance, the view is exact.

**For 140 (Orchestration):** the Python↔Node seam is **Socket.IO over HTTP**
(`MindServer`, default :8080); `src/mindcraft-py/mindcraft.py` launches Node via
subprocess and speaks `python-socketio`. World state crosses this seam today only
via the 1 Hz `state-update` broadcast. (Boundary decision deferred to slice 102.)

## Confidence

**High** for the mineflayer-view decision and the cost shape. The cost bimodality
(block scans ~75 ms vs. everything else <0.02 ms) is large and unambiguous; the
ground-truth match was exact on three independent axes; the seam was read directly
from the runtime source and the bridge.

**Coupling accepted:** eval reads via a mineflayer connection — *but* the spike
showed this need not couple eval to the agent's own connection. `view-probe` was a
**second, independent read-only connection** (offline-mode server allows it; one
extra bot slot), and it read identically to the agent's view. So aviary gets the
mineflayer view's exactness **without** hard-coupling eval to the agent process: the
eval can run its own observer connection. The "independent observer" option from the
slice plan is therefore **available and cheap**, characterized here, and recommended
as the decoupling mechanism *if* eval-to-agent coupling later proves undesirable.

**What would change it:** evals that must verify state outside the bot's render
distance, or that put the agent's own perception under test (where reading *through*
that perception is circular), would force a server-side source for those specific
checks. The block-scan cost would also matter more if an eval needs frequent
full-region snapshots — in which case a tighter radius or a server-side block query
becomes worth the added coupling.

## Inconclusive → next step

`n/a` — the question was settled. A mechanism was chosen (mineflayer view, with a
documented two-class cost model and a server-side escalation path), its cost was
measured against the live stack, accuracy was confirmed against server ground truth,
the coupling trade was characterized (independent observer connection available and
cheap), and the Python↔Node seam was mapped to a concrete existing channel
(`state-update` at 1 Hz). 120 is unblocked with real numbers, not assumptions.
