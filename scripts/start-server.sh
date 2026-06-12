#!/usr/bin/env bash
# start-server.sh — run the Paper server in the foreground.
# For persistent runs prefer the systemd unit (systemd/aviary-server.service)
# or: tmux new -s mc './scripts/start-server.sh'
set -euo pipefail
cd "$(dirname "$0")/../server"

MEM_MIN="${MEM_MIN:-2G}"
MEM_MAX="${MEM_MAX:-8G}"

exec java -Xms"$MEM_MIN" -Xmx"$MEM_MAX" \
  -XX:+UseG1GC -XX:MaxGCPauseMillis=130 \
  -jar paper.jar nogui
