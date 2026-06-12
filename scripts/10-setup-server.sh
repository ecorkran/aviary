#!/usr/bin/env bash
# 10-setup-server.sh — download Paper for MC_VERSION into ./server/, accept EULA
# (human decision, via env var), install server.properties from template.
#
# Usage:  EULA_ACCEPT=yes MC_VERSION=1.21.1 ./scripts/10-setup-server.sh
#
# IMPORTANT: MC_VERSION must match what upstream Mindcraft supports.
# Check https://github.com/mindcraft-bots/mindcraft before choosing.
set -euo pipefail
cd "$(dirname "$0")/.."

MC_VERSION="${MC_VERSION:?Set MC_VERSION (must match mindcraft-supported version)}"
SERVER_DIR="server"
API="https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}"

mkdir -p "$SERVER_DIR"

# --- EULA: a human agrees to this, once. ---
if [ "${EULA_ACCEPT:-no}" != "yes" ]; then
  echo "ERROR: Running a Minecraft server requires accepting the Minecraft EULA"
  echo "       (https://aka.ms/MinecraftEULA). A human must set EULA_ACCEPT=yes."
  exit 1
fi
echo "eula=true" > "$SERVER_DIR/eula.txt"

# --- Fetch latest Paper build for this version ---
echo "Querying Paper builds for ${MC_VERSION}..."
BUILD="$(curl -fsSL "$API" | node -p 'JSON.parse(require("fs").readFileSync(0)).builds.at(-1)')"
JAR="paper-${MC_VERSION}-${BUILD}.jar"
if [ ! -f "$SERVER_DIR/$JAR" ]; then
  echo "Downloading $JAR ..."
  curl -fSL -o "$SERVER_DIR/$JAR" "$API/builds/${BUILD}/downloads/${JAR}"
else
  echo "$JAR already present."
fi
ln -sf "$JAR" "$SERVER_DIR/paper.jar"

# --- server.properties from template (don't clobber an existing one) ---
if [ ! -f "$SERVER_DIR/server.properties" ]; then
  cp config/server.properties.template "$SERVER_DIR/server.properties"
  echo "Installed server.properties from template."
else
  echo "server.properties exists — leaving it alone."
fi

echo
echo "Done. Next:"
echo "  ./scripts/start-server.sh        (foreground / tmux)"
echo "  REMINDER (HITL): confirm port 25565 is LAN-only in your firewall."
