#!/usr/bin/env bash
# whiptail checklist. Reads registry + PRESELECT (array of ids from profile/--only) and sets SELECTED.

# menu_select : fills global SELECTED array
menu_select() {
  local id label state rows=() lines cols h w n=0 out rc cat last=""
  for id in "${MOD_IDS[@]}"; do
    mod_visible "$id" || continue
    state=OFF
    if [[ ${#PRESELECT[@]} -gt 0 ]]; then
      [[ " ${PRESELECT[*]} " == *" $id "* ]] && state=ON
    else
      default_checked "$id" && state=ON
    fi
    local tag=""
    run_module "$id" check >/dev/null 2>&1 && tag=" [installed]"
    label="${MOD_CAT[$id]} · ${MOD_NAME[$id]}${tag} — ${MOD_DESC[$id]}"
    rows+=("$id" "$label" "$state"); n=$((n + 1))
  done
  read -r lines cols < <(stty size 2>/dev/null || echo "24 80")
  h=$((lines - 4)); w=$((cols - 6)); (( h > 40 )) && h=40; (( w > 150 )) && w=150
  out=$(whiptail --title "Ubuntu AI workstation setup" \
        --backtitle "$(detect_summary)" \
        --checklist "SPACE toggles, TAB switches to buttons, ENTER confirms.\nInstalled items are updated when selected." \
        "$h" "$w" $((h - 8)) "${rows[@]}" 3>&1 1>&2 2>&3) && rc=0 || rc=$?
  [[ $rc -ne 0 ]] && return 1
  eval "SELECTED=($out)"
}
