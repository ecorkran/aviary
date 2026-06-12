# aviary

Minecraft agent experiment lab. Headless Minecraft server + LLM-driven bots
(Mindcraft first, Claude Agent SDK later) running on `hammerhead` (Linux, 3090s).
Human players and pretty rendering happen on *other* machines connecting as clients.

> Rename freely — `aviary` is a placeholder (bots in a cage, watching flocking emerge).

---

## Architecture (what runs where)

```
hammerhead (this machine, headless)          other machines (Mac, etc.)
┌──────────────────────────────────┐         ┌─────────────────────────┐
│ Paper server (JVM, port 25565)   │◄────────│ Minecraft Java client   │
│   └─ world state = ground truth  │  LAN    │  (spectator/player,     │
│                                  │         │   shaders/textures OK — │
│ Mindcraft bot(s) (Node)          │         │   client-side only)     │
│   └─ connect as players via      │         └─────────────────────────┘
│      protocol (Mineflayer)       │
│   └─ prismarine-viewer on        │◄──────── any browser (bot POV,
│      http://hammerhead:3000+     │          low-fi but headless)
│                                  │
│ [later] Agent SDK bot brain      │
│ [later] local model on 3090s     │
│ [later] squadron campaign layer  │
└──────────────────────────────────┘
```

Key facts that shape everything:

- **The server is NOT the regular Minecraft client.** It's a standalone headless
  JVM process (Paper, a high-performance fork of the vanilla server). No display,
  no GPU use, no Minecraft account needed to run it.
- **Bots are NOT mods.** They connect over the network protocol exactly like a
  player client would. The server can't tell the difference. Zero mods required.
- **Textures/shaders are client-side.** Bots never see them; your Mac client can
  run the full polished visual stack against this same server with zero coupling.
- **`online-mode=false`** (offline mode) so bots don't each need a Microsoft
  account. This means the server MUST stay LAN-only / firewalled. Do not port-forward.

## Toolchain

| Tool | Why | Install |
|---|---|---|
| Java 21 (headless JRE) | Paper server for MC 1.21.x | `apt install openjdk-21-jre-headless` |
| Node.js ≥ 18 (22 LTS preferred) | Mindcraft / Mineflayer | system pkg or nvm |
| Paper server jar | the Minecraft server | fetched by `scripts/10-setup-server.sh` |
| Mindcraft (upstream repo) | bot framework: perception, skills, prompt loop, tasks | cloned by `scripts/20-setup-mindcraft.sh` |
| tmux or systemd | leave-it-running | systemd unit provided |
| (later) Claude Agent SDK | custom bot brain, subscription auth | pip, when we get there |
| (later) ollama/vllm on 3090s | cheap inner-loop model | when API costs bite |

## Build vs. use

| Layer | Decision |
|---|---|
| Server | **Use** Paper. Nothing to build. |
| Bot loop, skills, perception | **Use** Mindcraft as-is for phase 1–2. Read its code as the reference design. |
| Bot POV viewer | **Use** Mindcraft's built-in prismarine-viewer. |
| Profiles, settings, scripts, docs | **Build** (this repo — it's all config + glue). |
| Agent SDK tool surface (~MCP wrapper over Mineflayer) | **Build later**, phase 4. The one real dev slice in this project. |
| Campaign orchestration / verification | **Build later** as squadron pipeline steps (phase 5). |

## Repo layout

```
aviary/
├── README.md            ← you are here
├── CLAUDE.md            ← context for AI agents working in this repo
├── scripts/             ← numbered setup + run scripts (idempotent-ish)
├── config/              ← server.properties template
├── profiles/            ← mindcraft bot profiles (scout.json, ...)
├── systemd/             ← unit files for leave-it-running
├── docs/                ← experiment log
├── server/              ← runtime: jar + world data   (gitignored)
└── mindcraft/           ← upstream clone               (gitignored)
```

Yes, this is a git repo — normal development. Runtime state (world saves, jars,
the mindcraft clone, keys) is gitignored; everything reproducible from scripts.

---

## Plan

### Phase 0 — prereqs (AI-runnable, ~5 min)
```bash
./scripts/00-check-prereqs.sh
```
Installs/verifies Java 21 + Node. **HITL:** sudo password if installs needed.

### Phase 1 — server up (AI-runnable except one step)
```bash
EULA_ACCEPT=yes MC_VERSION=<see note> ./scripts/10-setup-server.sh
./scripts/start-server.sh        # or: install systemd unit (below)
```
**HITL (genuinely human):** setting `EULA_ACCEPT=yes` is agreeing to the
Minecraft EULA. A human says yes to that, once.
**HITL:** confirm firewall — port 25565 reachable from LAN only
(`sudo ufw allow from 192.168.0.0/16 to any port 25565` or equivalent).

> **Version note:** MC version must match what Mindcraft currently supports —
> check the table in the [Mindcraft README](https://github.com/mindcraft-bots/mindcraft)
> *first* and pass that as `MC_VERSION`. Mismatched protocol versions are the
> #1 wasted-evening failure mode in this stack.

Sanity check: connect from your Mac client (Direct Connect → `hammerhead:25565`).

### Phase 2 — first bot (AI-runnable except API key)
```bash
./scripts/20-setup-mindcraft.sh
# put ANTHROPIC_API_KEY (or other) into mindcraft/keys.json   ← HITL: secrets
./scripts/start-bot.sh scout
```
Bot `scout` joins the server. Watch its POV at `http://hammerhead:3000`.
In game chat (from your Mac client): tell it to collect wood. Or run a
structured task:
```bash
cd mindcraft && node main.js --task_path tasks/basic/single_agent.json --task_id gather_oak_logs
```
**Exit criteria:** bot completes a gather task you watched happen.

### Phase 3 — leave it running
Install systemd units (`systemd/README` in-file comments), point a browser at
the viewer occasionally, append observations to `docs/experiment-log.md`.
Try multi-bot (second profile), longer-horizon tasks, survival mode.

### Phase 4 — Agent SDK brain (the dev slice)
Design the tool surface (what the bot perceives, at what granularity, with what
verification affordances) — this is a cf slice with an arch doc, built by
squadron like normal work. Reference: mindcraft's action set + haksnbot-agent's
~50-tool layout. Subscription auth = flat cost, burst-mode autonomy.

### Phase 5 — campaigns (squadron's actual entry point)
Squadron pipeline step shape: launch bot(s) with task → poll → **verify against
world state** (Mineflayer query script = objective ground truth, no LLM reviewer
needed) → record → dispatch next variant. Results DB + nightly analysis session
(Routines pattern).

### Phase 6 — modded/polished worlds
World-gen + decoration mods (emit vanilla blocks): bots generally fine.
Content mods (new items/machines): bots confused — Mineflayer's registries are
vanilla. Sequence accordingly. Shaders/textures: client-side, do anytime.

---

## Day-to-day driving

- **Claude Code (terminal or VS Code) on hammerhead** is the primary driver for
  all of the above — it can run every script, edit settings.js, read logs,
  tail the bot's reasoning. `CLAUDE.md` gives it context.
- **This chat project** stays the architecture/decision layer.
- **Claude Cowork: not needed here.** This is dev/ops work, not document work.
- **Squadron:** not in the loop until phase 4–5. Phases 0–3 are config, not code.

## Cost notes

Embodied loops are token-hungry (world state re-sent every cycle). For long
unattended runs prefer: cheaper models in mindcraft profiles, or local models
on the 3090s (mindcraft supports ollama-style endpoints), reserving
Claude-class models for tasks where reasoning quality is the variable under test.
