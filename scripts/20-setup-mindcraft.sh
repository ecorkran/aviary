#!/usr/bin/env bash
# 20-setup-mindcraft.sh — clone/update upstream Mindcraft into ./mindcraft/,
# install deps, patch connection settings to our server, sync our profiles.
# HITL afterward: put API key(s) into mindcraft/keys.json (never committed).
set -euo pipefail
cd "$(dirname "$0")/.."

REPO="https://github.com/mindcraft-bots/mindcraft.git"

if [ -d mindcraft/.git ]; then
  echo "Updating existing mindcraft clone..."
  git -C mindcraft pull --ff-only
else
  echo "Cloning mindcraft..."
  git clone "$REPO" mindcraft
fi

echo "Installing node deps..."
( cd mindcraft && npm install )

# --- Patch settings.js: point at our dedicated server (upstream default is a
# --- LAN world on 55916). sed is fragile against upstream refactors; verify.
SETTINGS=mindcraft/settings.js
if grep -q '"port": *55916' "$SETTINGS" 2>/dev/null; then
  sed -i 's/"port": *55916/"port": 25565/' "$SETTINGS"
  echo "Patched settings.js port -> 25565."
elif grep -q '"port": *25565' "$SETTINGS" 2>/dev/null; then
  echo "settings.js already on 25565."
else
  echo "WARNING: couldn't auto-patch port in settings.js (upstream format changed?)."
  echo "         Manually set host 127.0.0.1, port 25565."
fi

# --- keys.json scaffold (HITL fills in real keys) ---
if [ ! -f mindcraft/keys.json ] && [ -f mindcraft/keys.example.json ]; then
  cp mindcraft/keys.example.json mindcraft/keys.json
  echo "Created mindcraft/keys.json from example — ADD YOUR API KEY(S) (HITL)."
fi

# --- Sync our profiles into the clone ---
cp -v profiles/*.json mindcraft/profiles/ 2>/dev/null || true

echo
echo "Done. Next (HITL): edit mindcraft/keys.json, then:"
echo "  ./scripts/start-bot.sh scout"
