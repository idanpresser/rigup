#!/usr/bin/env bash
# Shared helpers. Sourced by install.sh and by every module runner.

STATE_DIR="${STATE_DIR:-$HOME/.local/state/rigup}"
mkdir -p "$STATE_DIR/logs"
LOG_FILE="${LOG_FILE:-$STATE_DIR/logs/$(date +%Y%m%d-%H%M%S).log}"
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"

if [[ -t 1 ]]; then
  C_RED=$'\e[31m'; C_GRN=$'\e[32m'; C_YEL=$'\e[33m'; C_BLU=$'\e[34m'; C_DIM=$'\e[2m'; C_OFF=$'\e[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_BLU=""; C_DIM=""; C_OFF=""
fi

info() { printf '%s==>%s %s\n' "$C_BLU" "$C_OFF" "$*"; }
ok()   { printf '%s ✔%s %s\n' "$C_GRN" "$C_OFF" "$*"; }
warn() { printf '%s !%s %s\n' "$C_YEL" "$C_OFF" "$*" >&2; }
err()  { printf '%s ✖%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; }
die()  { err "$*"; exit 1; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# run CMD... : echo-only in dry-run mode
run() {
  if [[ "$DRY_RUN" == 1 ]]; then printf '%s[dry-run]%s %s\n' "$C_DIM" "$C_OFF" "$*"; return 0; fi
  "$@"
}

# sh_run 'pipeline string' : same as run, for pipelines (curl | bash)
sh_run() {
  if [[ "$DRY_RUN" == 1 ]]; then printf '%s[dry-run]%s %s\n' "$C_DIM" "$C_OFF" "$1"; return 0; fi
  bash -c "$1"
}

retry() { # retry N cmd...
  local n=$1 i; shift
  for ((i = 1; i <= n; i++)); do "$@" && return 0; warn "attempt $i/$n failed: $*"; sleep $((i * 2)); done
  return 1
}

url_exists() { curl -fsIL -m 15 -o /dev/null "$1"; }

ask() { # ask "prompt" [default] -> echoes answer (default when --yes / no tty)
  local prompt=$1 def=${2:-} ans
  if [[ "$ASSUME_YES" == 1 || ! -t 0 ]]; then echo "$def"; return; fi
  read -r -p "$prompt${def:+ [$def]}: " ans </dev/tty
  echo "${ans:-$def}"
}

can_prompt() { [[ "$ASSUME_YES" != 1 && -t 0 ]]; }

apt_update_once() {
  [[ -f "$STATE_DIR/.apt-updated-$$" ]] && return 0
  run sudo apt-get update -y && touch "$STATE_DIR/.apt-updated-$$"
}
apt_install() { run sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"; }

# add_apt_repo NAME KEY_URL "deb line without signed-by (use SIGNED in place of [signed-by=...])"
# Example: add_apt_repo gh https://.../key.gpg 'deb [arch=amd64 SIGNED] https://cli.github.com/packages stable main'
add_apt_repo() {
  local name=$1 key_url=$2 line=$3 keyring="/etc/apt/keyrings/$1.gpg"
  line=${line//SIGNED/signed-by=$keyring}
  [[ "$DRY_RUN" == 1 ]] && { echo "[dry-run] add apt repo $name"; return 0; }
  sudo install -d -m 0755 /etc/apt/keyrings
  curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$keyring"
  sudo chmod a+r "$keyring"
  echo "$line" | sudo tee "/etc/apt/sources.list.d/$name.list" >/dev/null
  sudo apt-get update -y
}

# repo_suite BASE_DISTS_URL FALLBACK : echo OS codename if vendor publishes it, else fallback
repo_suite() {
  if url_exists "$1/$OS_CODENAME/Release" || url_exists "$1/$OS_CODENAME/InRelease"; then echo "$OS_CODENAME"
  else warn "no '$OS_CODENAME' suite at $1, falling back to '$2'"; echo "$2"; fi
}

# rc_block ID CONTENT : managed block in ~/.bashrc (and ~/.zshrc if present), rewritten in place
rc_block() {
  local id=$1 content=$2 f begin="# >>> rigup:$1 >>>" end="# <<< rigup:$1 <<<"
  [[ "$DRY_RUN" == 1 ]] && { echo "[dry-run] rc block $id"; return 0; }
  for f in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ "$f" == "$HOME/.zshrc" && ! -f $f ]] && continue
    touch "$f"
    if grep -qF "$begin" "$f"; then
      awk -v b="$begin" -v e="$end" '$0==b{skip=1} !skip{print} $0==e{skip=0}' "$f" >"$f.tmp" && mv "$f.tmp" "$f"
    fi
    printf '%s\n%s\n%s\n' "$begin" "$content" "$end" >>"$f"
  done
}

# Make freshly installed tools visible to later modules in this run.
refresh_path() {
  local d
  for d in "$HOME/.local/bin" "$HOME/.local/npm-global/bin" "$HOME/.cargo/bin" "$HOME/.bun/bin" \
           "$HOME/.local/share/fnm" "$HOME/.opencode/bin" "$HOME/.fly/bin" "$HOME/.claude/bin" /usr/local/go/bin; do
    [[ -d $d && ":$PATH:" != *":$d:"* ]] && PATH="$d:$PATH"
  done
  export PATH
  if has_cmd fnm; then eval "$(fnm env 2>/dev/null)" || true; fi
}

need_reboot() { echo "$1" >>"$STATE_DIR/reboot-needed"; }
need_relogin() { echo "$1" >>"$STATE_DIR/relogin-needed"; }

# npm_global PKG... : install/upgrade global npm packages into the stable prefix
npm_global() { has_cmd npm || { err "npm not found (enable the node-fnm module)"; return 1; }; run npm install -g "$@"; }

# gh_latest_asset OWNER/REPO REGEX : print download URL of first matching release asset
gh_latest_asset() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" | grep -oE '"browser_download_url": *"[^"]+"' \
    | cut -d'"' -f4 | grep -E "$2" | head -n1
}

# install_deb_url URL : download and install a .deb
install_deb_url() {
  local tmp; tmp=$(mktemp -d)
  run curl -fsSL -o "$tmp/pkg.deb" "$1"
  run sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmp/pkg.deb"
  rm -rf "$tmp"
}
