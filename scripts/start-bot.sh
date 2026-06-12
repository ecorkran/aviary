#!/usr/bin/env bash
# start-bot.sh <profile-name> — sync our profile into the clone and start mindcraft.
# Bot POV viewer: http://localhost:3000 (increments per bot if enabled in settings).
set -euo pipefail
cd "$(dirname "$0")/.."

PROFILE="${1:?Usage: start-bot.sh <profile-name>   (e.g. scout)}"
SRC="profiles/${PROFILE}.json"
[ -f "$SRC" ] || { echo "No such profile: $SRC"; exit 1; }
[ -d mindcraft ] || { echo "Run ./scripts/20-setup-mindcraft.sh first."; exit 1; }

cp -v "$SRC" "mindcraft/profiles/${PROFILE}.json"

echo "Starting mindcraft with profile '${PROFILE}'..."
echo "(Ensure settings.js lists ./profiles/${PROFILE}.json in its profiles array.)"
cd mindcraft
exec node main.js --profiles "./profiles/${PROFILE}.json"
