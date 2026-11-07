#!/usr/bin/env bash
# Scans modules/, parses '# @key value' headers, evaluates @when, orders by @requires.

declare -a MOD_IDS=()
declare -A MOD_FILE MOD_NAME MOD_CAT MOD_DESC MOD_REQ MOD_DEFAULT MOD_WHEN MOD_INTERACTIVE

# cond_true "a,b,c" : every comma-separated term must hold
cond_true() {
  local expr=${1:-always} t
  IFS=',' read -ra terms <<<"$expr"
  for t in "${terms[@]}"; do
    t=${t// /}
    case $t in
      always|"") ;;
      desktop)   [[ $ENV_DESKTOP == 1 ]] || return 1 ;;
      headless)  [[ $ENV_DESKTOP == 0 ]] || return 1 ;;
      wsl)       [[ $ENV_WSL == 1 ]] || return 1 ;;
      '!wsl')    [[ $ENV_WSL == 0 ]] || return 1 ;;
      gpu=any)   [[ $HW_GPU != none ]] || return 1 ;;
      gpu=*)     [[ $HW_GPU == "${t#gpu=}" ]] || return 1 ;;
      arch=*)    [[ $HW_ARCH == "${t#arch=}" ]] || return 1 ;;
      ram'>='*)  (( HW_RAM_GB >= ${t#ram>=} )) || return 1 ;;
      vram'>='*) (( HW_VRAM_GB >= ${t#vram>=} )) || return 1 ;;
      *) warn "unknown condition '$t'"; return 1 ;;
    esac
  done
}

_hdr() { sed -n "s/^# @$2[[:space:]]\{1,\}//p" "$1" | head -n1 | sed 's/[[:space:]]*#.*$//; s/[[:space:]]*$//'; }

registry_load() {
  local f id
  MOD_IDS=()
  while IFS= read -r f; do
    id=$(_hdr "$f" id); [[ -z $id ]] && { warn "skipping $f: no @id"; continue; }
    MOD_IDS+=("$id")
    MOD_FILE[$id]=$f
    MOD_NAME[$id]=$(_hdr "$f" name)
    MOD_CAT[$id]=$(_hdr "$f" category)
    MOD_DESC[$id]=$(sed -n 's/^# @desc[[:space:]]\{1,\}//p' "$f" | head -n1)
    MOD_REQ[$id]=$(_hdr "$f" requires)
    MOD_DEFAULT[$id]=$(_hdr "$f" default); MOD_DEFAULT[$id]=${MOD_DEFAULT[$id]:-off}
    MOD_WHEN[$id]=$(_hdr "$f" when);       MOD_WHEN[$id]=${MOD_WHEN[$id]:-always}
    MOD_INTERACTIVE[$id]=$(_hdr "$f" interactive); MOD_INTERACTIVE[$id]=${MOD_INTERACTIVE[$id]:-no}
  done < <(find "$ROOT/modules" -name '*.sh' | sort)
}

mod_visible() { cond_true "${MOD_WHEN[$1]}"; }

# default_checked ID : on | off | <condition> (checked when the condition holds)
default_checked() {
  local d=${MOD_DEFAULT[$1]}
  case $d in on) return 0 ;; off) return 1 ;; *) cond_true "$d" ;; esac
}

# run_module ID MODE : MODE = check | install | update | version
run_module() { bash "$ROOT/lib/run_module.sh" "${MOD_FILE[$1]}" "$2"; }

# resolve_order ID... : adds missing dependencies, prints ids in dependency-first order
resolve_order() {
  local -A seen=(); local -a out=(); local id
  _visit() {
    local i=$1 r
    [[ -n ${seen[$i]:-} ]] && return
    seen[$i]=1
    [[ -z ${MOD_FILE[$i]:-} ]] && { warn "unknown module '$i'"; return; }
    for r in ${MOD_REQ[$i]//,/ }; do _visit "$r"; done
    out+=("$i")
  }
  for id in "$@"; do _visit "$id"; done
  printf '%s\n' "${out[@]}"
}
