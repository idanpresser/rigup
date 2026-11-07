#!/usr/bin/env bash
# Ubuntu AI workstation installer — interactive checklist of modules.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT

usage() {
  cat <<USAGE
Usage: ./install.sh [options]
  --profile NAME   preselect modules from profiles/NAME.conf (ai-desktop, ai-server, minimal)
  --only a,b,c     install exactly these module ids (dependencies are added)
  --skip a,b       remove these ids from the selection
  --yes, -y        no menu, no prompts: install the profile / recommended defaults
  --update         update every module that is already installed (implies --yes)
  --dry-run        print what would run, change nothing
  --list           list modules, visibility and installed state, then exit
  -h, --help       this help
USAGE
}

PROFILE=""; ONLY=""; SKIP=""; DO_LIST=0; DO_UPDATE=0
export ASSUME_YES=0 DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) PROFILE=$2; shift 2 ;;
    --only)    ONLY=$2; shift 2 ;;
    --skip)    SKIP=$2; shift 2 ;;
    --yes|-y)  ASSUME_YES=1; shift ;;
    --update)  DO_UPDATE=1; ASSUME_YES=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --list)    DO_LIST=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage; exit 2 ;;
  esac
done

# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
[[ $EUID -eq 0 ]] && die "Run as your normal user, not root. sudo is used only where needed."
[[ -r /etc/os-release ]] && . /etc/os-release
[[ ${ID:-} == ubuntu ]] || warn "This installer targets Ubuntu (found: ${ID:-unknown})."
export LOG_FILE
source "$ROOT/lib/detect.sh"
source "$ROOT/lib/registry.sh"
source "$ROOT/lib/menu.sh"
refresh_path
registry_load

if [[ $DO_LIST == 1 ]]; then
  detect_summary
  printf '%-22s %-14s %-8s %-10s %s\n' ID CATEGORY SHOWN DEFAULT INSTALLED
  for id in "${MOD_IDS[@]}"; do
    v=no; mod_visible "$id" && v=yes
    d=off; default_checked "$id" && d=on
    i=no; run_module "$id" check >/dev/null 2>&1 && i=yes
    printf '%-22s %-14s %-8s %-10s %s\n' "$id" "${MOD_CAT[$id]}" "$v" "$d" "$i"
  done
  exit 0
fi

info "$(detect_summary)"
info "Log: $LOG_FILE"

# --- build the preselection ---------------------------------------------------
PRESELECT=(); SELECTED=()
csv() { local IFS=,; read -ra _o <<<"$1"; printf '%s\n' "${_o[@]}"; }
if [[ -n $PROFILE ]]; then
  pf="$ROOT/profiles/$PROFILE.conf"; [[ -f $pf ]] || die "no such profile: $PROFILE"
  mapfile -t PRESELECT < <(sed 's/#.*//; s/[[:space:]]//g; /^$/d' "$pf")
fi
[[ -n $ONLY ]] && mapfile -t PRESELECT < <(csv "$ONLY")

if [[ $DO_UPDATE == 1 ]]; then
  for id in "${MOD_IDS[@]}"; do run_module "$id" check >/dev/null 2>&1 && SELECTED+=("$id"); done
elif [[ $ASSUME_YES == 1 || -n $ONLY ]]; then
  if [[ ${#PRESELECT[@]} -gt 0 ]]; then
    for id in "${PRESELECT[@]}"; do mod_visible "$id" && SELECTED+=("$id") || warn "$id not applicable here, skipped"; done
  else
    for id in "${MOD_IDS[@]}"; do mod_visible "$id" && default_checked "$id" && SELECTED+=("$id") || true; done
  fi
else
  has_cmd whiptail || { sudo apt-get install -y whiptail; }
  menu_select || { echo "Cancelled."; exit 0; }
fi

if [[ -n $SKIP ]]; then
  mapfile -t _skip < <(csv "$SKIP")
  _keep=(); for id in "${SELECTED[@]}"; do [[ " ${_skip[*]} " == *" $id "* ]] || _keep+=("$id"); done
  SELECTED=("${_keep[@]}")
fi
[[ ${#SELECTED[@]} -eq 0 ]] && { echo "Nothing selected."; exit 0; }

mapfile -t ORDER < <(resolve_order "${SELECTED[@]}")
# stable phase ordering: keep dependency order but sort independent ones by catalog position
info "Plan: ${ORDER[*]}"
if [[ $ASSUME_YES != 1 && $DRY_RUN != 1 ]]; then
  read -r -p "Proceed? [Y/n] " a </dev/tty; [[ ${a:-y} =~ ^[Yy] ]] || exit 0
fi

# --- sudo keep-alive ---------------------------------------------------------------
if [[ $DRY_RUN != 1 ]]; then
  sudo -v
  ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
  KEEPALIVE=$!
  trap 'kill $KEEPALIVE 2>/dev/null || true' EXIT
fi
rm -f "$STATE_DIR/reboot-needed" "$STATE_DIR/relogin-needed"

# --- execute ----------------------------------------------------------------
declare -A RESULT
set +e
for id in "${ORDER[@]}"; do
  mode=install; run_module "$id" check >/dev/null 2>&1 && mode=update
  info "${MOD_NAME[$id]} ($mode)"
  if [[ ${MOD_INTERACTIVE[$id]} == yes && $ASSUME_YES == 1 ]]; then
    RESULT[$id]="skipped (interactive)"; warn "skipped: needs interaction, run without --yes"; continue
  fi
  if [[ ${MOD_INTERACTIVE[$id]} == yes ]]; then
    echo "--- $id ($mode) interactive ---" >>"$LOG_FILE"
    run_module "$id" "$mode"; rc=$?
  else
    run_module "$id" "$mode" 2>&1 | tee -a "$LOG_FILE"; rc=${PIPESTATUS[0]}
  fi
  if [[ $rc -eq 0 ]]; then
    case $mode in install) RESULT[$id]="installed" ;; *) RESULT[$id]="updated" ;; esac
  else
    RESULT[$id]="FAILED"
  fi
  refresh_path
done
set -e

# --- summary ----------------------------------------------------------------------
echo; info "Summary"
fails=0
for id in "${ORDER[@]}"; do
  r=${RESULT[$id]:-?}
  case $r in
    installed|updated) printf '  %s✔%s %-22s %s\n' "$C_GRN" "$C_OFF" "$id" "$r" ;;
    FAILED) printf '  %s✖%s %-22s %s\n' "$C_RED" "$C_OFF" "$id" "$r"; fails=$((fails + 1)) ;;
    *) printf '  – %-22s %s\n' "$id" "$r" ;;
  esac
done
echo; echo "Log: $LOG_FILE"
[[ -s $STATE_DIR/reboot-needed ]] && warn "Reboot required: $(sort -u "$STATE_DIR/reboot-needed" | paste -sd, -)"
[[ -s $STATE_DIR/relogin-needed ]] && warn "Log out/in (or run 'newgrp docker') for: $(sort -u "$STATE_DIR/relogin-needed" | paste -sd, -)"
echo "Open a new shell (or: source ~/.bashrc) to pick up PATH changes."
exit $(( fails > 0 ))
