#!/usr/bin/env bash
# curl -fsSL https://raw.githubusercontent.com/idanpresser/rigup/main/bootstrap.sh | bash
# Env overrides: UAS_REPO (git url), UAS_DIR (checkout dir). Extra args are passed to install.sh:
#   curl -fsSL .../bootstrap.sh | bash -s -- --profile ai-server --yes
set -euo pipefail
REPO="${UAS_REPO:-https://github.com/idanpresser/rigup.git}"
DIR="${UAS_DIR:-$HOME/.local/share/rigup}"

[[ $EUID -eq 0 ]] && { echo "Run as your normal user, not root." >&2; exit 1; }
if ! command -v git >/dev/null || ! command -v curl >/dev/null || ! command -v whiptail >/dev/null; then
  sudo apt-get update -y && sudo apt-get install -y git curl whiptail ca-certificates
fi
if [[ -d $DIR/.git ]]; then git -C "$DIR" pull --ff-only; else git clone --depth 1 "$REPO" "$DIR"; fi
# stdin is the pipe when run via curl|bash; hand the terminal back to the installer
if [[ -r /dev/tty ]]; then exec "$DIR/install.sh" "$@" </dev/tty; else exec "$DIR/install.sh" "$@"; fi
