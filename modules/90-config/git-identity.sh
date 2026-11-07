#!/usr/bin/env bash
# @id        git-identity
# @name      Git identity & defaults
# @category  Config
# @desc      Set user.name / user.email, default branch main, pull.rebase
# @requires  base-packages
# @default   on
# @interactive yes
is_installed() { [[ -n $(git config --global user.email 2>/dev/null) ]]; }
install() {
  local n e
  n=$(ask "Git name" "$(git config --global user.name || true)")
  e=$(ask "Git email" "$(git config --global user.email || true)")
  [[ -n $n ]] && run git config --global user.name "$n"
  [[ -n $e ]] && run git config --global user.email "$e"
  run git config --global init.defaultBranch main
  run git config --global pull.rebase true
  run git config --global push.autoSetupRemote true
}
update() { run git config --global init.defaultBranch main; }   # never re-prompt
