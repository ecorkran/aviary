#!/usr/bin/env bash
# status.sh — quick health overview: server process, port, bots, viewer.
set -uo pipefail
cd "$(dirname "$0")/.."

echo "== Server process =="
pgrep -af 'paper.jar' || echo "  (not running)"

echo "== Port 25565 =="
ss -tlnp 2>/dev/null | grep 25565 || echo "  (not listening)"

echo "== Bot processes (mindcraft) =="
pgrep -af 'main.js' || echo "  (none)"

echo "== Viewer ports (3000-3005) =="
ss -tlnp 2>/dev/null | grep -E ':300[0-5]' || echo "  (none)"

echo "== Recent server log =="
tail -n 5 server/logs/latest.log 2>/dev/null || echo "  (no log yet)"
