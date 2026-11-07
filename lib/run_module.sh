#!/usr/bin/env bash
# Runs one module in a clean bash process so `set -e` really applies.
# usage: run_module.sh MODULE_FILE check|install|update|version
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=common.sh
source "$ROOT/lib/common.sh"
source "$ROOT/lib/detect.sh"
refresh_path
file=$1 mode=$2
trap 'err "failed: $(basename "$file") line $LINENO: $BASH_COMMAND"' ERR
# shellcheck disable=SC1090
source "$file"
case $mode in
  check)   is_installed ;;
  version) declare -F version >/dev/null && version || true ;;
  install) install; declare -F post_install >/dev/null && post_install || true ;;
  update)  if declare -F update >/dev/null; then update; else install; fi
           declare -F post_install >/dev/null && post_install || true ;;
  *) die "bad mode $mode" ;;
esac
