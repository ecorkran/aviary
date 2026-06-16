# aviary — operations guide

How to run, control, configure, and stop everything. Written after the first
successful bot run (2026-06-15). Update it when things change.

---

## Stack overview

```
Paper server (JVM, tmux session "mc")
  └─ world state = ground truth
Mindcraft bot (Node, tmux session "bot" or "task")
  └─ connects as a player via Mineflayer
    └─ calls LLM API per action cycle
PrismLauncher (GUI, hammerhead desktop)
  └─ your client window into the same world
```

---

## Starting things up

### 1 — Minecraft server

```bash
# Foreground (in a dedicated tmux pane):
tmux new -s mc
./scripts/start-server.sh

# Or use the existing session:
tmux attach -t mc
```

Wait for: `Done (Xs)! For help, type "help"` in the log.

```bash
# Watch log without attaching:
tail -f server/logs/latest.log
```

### 2 — PrismLauncher (your client)

```bash
flatpak run org.prismlauncher.PrismLauncher
```

Or find it in the application menu. Use your Microsoft account. Create a
Minecraft Java 1.21.6 instance. Connect via Direct Connect → `127.0.0.1:25565`.

### 3 — Bot (freeform / interactive)

```bash
./scripts/start-bot.sh scout
# Bot POV viewer: http://localhost:3000
```

The bot joins as a player named `scout`. You can talk to it in game chat
(see "Talking to the bot" below).

### 4 — Bot (structured task)

```bash
cd mindcraft && node main.js \
  --profiles './profiles/scout.json' \
  --task_path tasks/basic/single_agent.json \
  --task_id gather_oak_logs
```

The task runner sets the bot's inventory, teleports it, runs the task, verifies
inventory against the goal, and shuts down cleanly with `Task successful` or
`Task failed`.

---

## Shutting things down

### Stop the bot

```bash
# If running in a tmux session:
tmux kill-session -t bot    # or -t task

# Or Ctrl-C if attached.
# The bot disconnects from the server automatically.
```

You can also type `!stop` in game chat while the bot is running freeform.

### Stop the server

```bash
tmux attach -t mc
# Then type in the tmux pane:
stop
# Server saves world and exits cleanly. Don't kill -9 it — you'll corrupt the world.
```

Or send it without attaching:

```bash
tmux send-keys -t mc "stop" Enter
```

### Check what's running

```bash
./scripts/status.sh
tmux ls
```

---

## Talking to the bot in game

**Yes, the bot responds to in-game chat.** When only one bot is running, it
responds to open chat from anyone. When multiple bots are running, open chat
is ignored (bots talk to each other instead) — use whispers:

```
/msg scout go find some iron ore
```

From your PrismLauncher client, just type in chat normally. The bot reads the
message, runs it through Claude, and responds in chat while taking action.
There is a short delay (one LLM call per response cycle).

Commands you can give in chat (the bot understands natural language, but these
Mindcraft-specific commands also work directly):

```
!inventory        — bot tells you what it's carrying
!stats            — health, food, position
!nearbyBlocks     — what blocks are around it
!entities         — nearby mobs/players
!stop             — interrupt current action
!modes            — list active behavior modes (cowardice, self_defense, etc.)
```

---

## Configuring the bot (profiles)

Bot profiles live in `profiles/` and are synced into the mindcraft clone by
`start-bot.sh`. Edit the files in `profiles/`, not in `mindcraft/profiles/`.

### Minimal working profile

```json
{
  "name": "scout",
  "model": "claude-sonnet-4-6"
}
```

That's all you need. Mindcraft's built-in system prompt handles everything else.
Do NOT add a `conversing` field unless you know exactly what you're doing —
it replaces the full system prompt including the command list, which causes
the bot to hallucinate non-existent commands.

### All profile fields

| Field | What it does | Default if omitted |
|---|---|---|
| `name` | Bot's in-game name. Must match exactly or bot talks to itself. | required |
| `model` | Model string (see below). | required |
| `code_model` | Separate model for writing action code. | same as `model` |
| `vision_model` | Model for image analysis (screenshot perception). | same as `model` |
| `embedding` | Embedding backend for example retrieval. `"openai"` or `"ollama"`. | built-in word-overlap |
| `conversing` | **Replaces** the full conversing system prompt. Dangerous — omit. | Mindcraft default |
| `coding` | Replaces the coding system prompt. | Mindcraft default |
| `saving_memory` | Replaces the memory-summarization prompt. | Mindcraft default |
| `modes` | Override which behavior modes are on by default. | all defaults on |
| `max_tokens` | Cap output tokens per response. | model default |
| `cooldown` | Seconds to wait between LLM calls. | 0 |
| `conversation_examples` | Path to few-shot convo examples file. | Mindcraft bundled |
| `coding_examples` | Path to few-shot coding examples file. | Mindcraft bundled |

### Giving the bot a "soul" (personality without breaking commands)

The `base_profile` in `mindcraft/settings.js` sets the underlying behavior
archetype: `"survival"`, `"assistant"`, `"creative"`, or `"god_mode"`. This is
the coarse soul file — it sets modes, risk tolerance, and default goals.

For deeper structured guidance (the equivalent of an ai-project-guide or
detailed persona doc), use the `conversing` field in your profile — but you
**must** include these template variables or the bot loses its command list and
hallucinates:

| Variable | What it injects |
|---|---|
| `$NAME` | Bot's name |
| `$SELF_PROMPT` | Current self-prompting goal, if active |
| `$MEMORY` | Summarized long-term memory |
| `$STATS` | Current health, position, time, biome |
| `$INVENTORY` | What the bot is carrying |
| `$COMMAND_DOCS` | **The full command list — must include or commands break** |
| `$EXAMPLES` | Few-shot examples (optional but helpful for weaker models) |

The minimal safe template:

```
You are $NAME, a Minecraft bot. [Your guidance here.]
$SELF_PROMPT
Summarized memory:'$MEMORY'
$STATS
$INVENTORY
$COMMAND_DOCS
$EXAMPLES
Conversation Begin:
```

See `profiles/architect.json` for a worked example — a creative-mode
architecture experimenter with explicit style constraints to keep a lesser
model on rails.

To run it (requires server in creative mode and a bot named "architect" or
rename the `name` field):

```bash
# Give bot creative mode on the server:
tmux send-keys -t mc "/gamemode creative architect" Enter
# Start bot:
./scripts/start-bot.sh architect
```

Then just tell it in chat: `build something in a brutalist style` or
`!goal("Build a new structure in a different architectural style, move 30 blocks, repeat.")`.

For bolder survival behavior, flip `"cowardice": false` and use
`"base_profile": "god_mode"` (invincibility + creative-style agency).

---

## API keys and model selection

Keys live in `mindcraft/keys.json` (gitignored, never committed).

```json
{
  "ANTHROPIC_API_KEY": "sk-ant-...",
  "OPENAI_API_KEY": "",
  ...
}
```

Only fill in the key(s) you're using. Set spend limits at
[console.anthropic.com](https://console.anthropic.com) → Settings → Limits.

### Model strings (profile `"model"` field)

| Provider | Example string | Key needed |
|---|---|---|
| Anthropic | `"claude-sonnet-4-6"` | `ANTHROPIC_API_KEY` |
| Anthropic cheap | `"claude-haiku-4-5-20251001"` | `ANTHROPIC_API_KEY` |
| OpenAI | `"gpt-5.4-mini"` | `OPENAI_API_KEY` |
| Ollama (local) | `"ollama/qwen2.5:32b"` | none |
| Ollama (LAN) | `"ollama/qwen2.5:32b"` + url field | none |
| vLLM | `"vllm/Qwen/Qwen2.5-32B-Instruct"` | none |

---

## Running a local model (e.g. Qwen 35B on hammerhead's 3090s)

Mindcraft has a native Ollama backend and a vLLM backend. Either works.

### Option A — Ollama (easiest)

Install Ollama on the machine running the GPU, pull the model, and point the
profile at it:

```bash
# On hammerhead (or LAN machine with 3090s):
ollama serve   # starts on 0.0.0.0:11434 by default
ollama pull qwen2.5:32b   # or qwen3:30b, etc.
```

Profile:

```json
{
  "name": "scout",
  "model": "ollama/qwen2.5:32b"
}
```

If Ollama is running on this same machine, that's it — Mindcraft defaults to
`http://127.0.0.1:11434`. If it's on another LAN machine (say the 3090 rig
is a separate box), override the URL in `mindcraft/settings.js`:

```js
// No per-profile URL field exists yet upstream — set globally:
"ollama_url": "http://192.168.1.x:11434",  // check if settings.js supports this
```

Or edit the `url` passed to the Ollama constructor in
`mindcraft/src/models/ollama.js` directly (one-line change, survives until
next `git pull`).

### Option B — vLLM (more control, better throughput)

```bash
# On 3090 rig:
vllm serve Qwen/Qwen2.5-32B-Instruct --host 0.0.0.0 --port 8000
```

Profile:

```json
{
  "name": "scout",
  "model": "vllm/Qwen/Qwen2.5-32B-Instruct"
}
```

Default endpoint is `http://0.0.0.0:8000/v1`. Override in
`mindcraft/src/models/vllm.js` if serving from a different host/port.

### Expected behavior vs Claude

A 35B Qwen run locally will be:
- **Much cheaper** — zero API cost once running, suitable for long unattended loops
- **Fast enough** — 3090s will generate tokens fast; Mindcraft's action loop is
  not latency-sensitive beyond ~2s/call
- **Somewhat worse at command grounding** — smaller models hallucinate
  Mindcraft's command syntax more often. Mitigate with `num_examples` in
  settings (more few-shot examples help) and potentially a fine-tuned variant
  (Mindcraft's `sweaterdog/andy-4` models are tuned specifically for this)
- **No embedding** without a separate embedding model (word-overlap fallback
  works fine for basic tasks)

For inner-loop cost reduction, a practical split is: local Qwen for routine
gather/craft tasks, Claude Sonnet for tasks where reasoning quality is the
variable under test.

---

## Server console commands (useful for experiments)

Run these by typing in the tmux `mc` session or via `tmux send-keys -t mc`:

```
/difficulty peaceful        # remove hostile mobs (for clean task runs)
/difficulty easy            # restore mobs
/gamemode creative scout    # give bot creative mode (for building experiments)
/give scout oak_log 64      # stuff items into bot inventory
/tp scout 0 64 0            # teleport bot
/data get entity scout Inventory   # read bot's inventory — world-state verification
/kill scout                 # kill and respawn bot (drops inventory)
```

---

## Verification: world state, not chat

The bot's chat is not ground truth. Verify outcomes with:

```bash
# Server console (in tmux mc session):
/data get entity scout Inventory

# Or a Mineflayer query script (to be built in phase 5):
node scripts/query-inventory.js scout
```

The task runner does this automatically for structured tasks — it's why
`Task successful` is trustworthy and the bot's own "I did it!" messages are not.
