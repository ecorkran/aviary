#!/usr/bin/env bash
# 00-check-prereqs.sh — verify/install Java 21 + Node >= 18 on Debian/Ubuntu.
# AI-runnable; needs sudo only if installs are required.
set -euo pipefail

ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }

echo "== Java =="
if command -v java >/dev/null 2>&1 && java -version 2>&1 | grep -qE 'version "(2[1-9]|[3-9][0-9])'; then
  ok "java $(java -version 2>&1 | head -1)"
else
  warn "Java 21+ not found. Installing openjdk-21-jre-headless (needs sudo)..."
  sudo apt-get update -qq && sudo apt-get install -y openjdk-21-jre-headless
  ok "installed: $(java -version 2>&1 | head -1)"
fi

echo "== Node =="
if command -v node >/dev/null 2>&1 && [ "$(node -p 'process.versions.node.split(".")[0]')" -ge 18 ]; then
  ok "node $(node --version)"
else
  warn "Node >= 18 not found."
  warn "Install via your preferred method, e.g.:"
  warn "  sudo apt-get install -y nodejs npm        # if distro version is new enough"
  warn "  ...or nvm: https://github.com/nvm-sh/nvm  # preferred for version control"
  exit 1
fi

echo "== Misc =="
for c in curl git tmux; do
  if command -v "$c" >/dev/null 2>&1; then ok "$c"; else warn "$c missing (sudo apt-get install -y $c)"; fi
done

echo "All prereqs satisfied (or instructions printed above)."
