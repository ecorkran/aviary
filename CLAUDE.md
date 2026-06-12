# CLAUDE.md — aviary

Context for AI agents (Claude Code) operating in this repo on `hammerhead`.

## What this is
A Minecraft agent experiment lab. Headless Paper server + LLM bots (Mindcraft).
Humans connect as clients from other machines. Full plan: README.md.

## Ground rules
- `server/` and `mindcraft/` are runtime/upstream — gitignored. Never commit
  world data, jars, or `keys.json`. Never print key contents.
- The server runs `online-mode=false`. NEVER expose port 25565 beyond LAN.
  Do not modify firewall rules without explicit human confirmation.
- EULA acceptance (`EULA_ACCEPT=yes`) is a human decision. Ask; don't assume.
- MC version is pinned by what upstream Mindcraft supports. Before any
  version bump, check https://github.com/mindcraft-bots/mindcraft README.

## Common operations
| Goal | Command |
|---|---|
| Check prereqs | `./scripts/00-check-prereqs.sh` |
| (Re)install server | `EULA_ACCEPT=yes MC_VERSION=x.y.z ./scripts/10-setup-server.sh` |
| Run server (foreground) | `./scripts/start-server.sh` |
| Run server (persistent) | `systemctl --user start aviary-server` (after unit install) |
| Install/refresh mindcraft | `./scripts/20-setup-mindcraft.sh` |
| Start a bot | `./scripts/start-bot.sh <profile-name>` |
| Status overview | `./scripts/status.sh` |
| Server console log | `tail -f server/logs/latest.log` |
| Bot POV viewer | http://localhost:3000 (first bot; +1 per bot) |

## Mindcraft integration notes
- Our bot profiles live in `profiles/*.json` and are copied into the mindcraft
  clone by `20-setup-mindcraft.sh` and `start-bot.sh`. Edit OURS, not the copies.
- Profile `name` must exactly match the in-game bot name (else it talks to itself).
- Connection host/port live in `mindcraft/settings.js` — setup script patches
  to 127.0.0.1:25565; verify after upstream pulls (upstream default is 55916).
- Model strings in profiles follow upstream conventions — when in doubt, read
  `mindcraft/README.md` and example profiles (`andy.json`) in the clone.
- Structured tasks: `cd mindcraft && node main.js --task_path tasks/... --task_id ...`

## Verification = world state, not vibes
When checking whether a bot accomplished something, query the server, don't
trust the transcript: bot inventory and nearby blocks via a small Mineflayer
script, or server console commands (`/data get entity <bot> Inventory`).
Transcripts claim; world state proves.

## Debug heuristics (ordered)
1. Version mismatch (server MC version vs mindcraft-supported) — check first.
2. Bot connects then idles → model/key problem: check `keys.json`, profile
   model string, and console for API errors.
3. Bot spams chat at itself → profile name ≠ in-game name.
4. Bot acts dumb on simple tasks → check which model the profile actually
   selects before debugging prompts/logic.
5. Server up but client can't connect → firewall/binding, `server.properties`.
