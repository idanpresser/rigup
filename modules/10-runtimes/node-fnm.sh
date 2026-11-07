#!/usr/bin/env bash
# @id        node-fnm
# @name      Node.js (fnm)
# @category  Runtimes
# @desc      fnm version manager + Node LTS, npm globals in ~/.local/npm-global (survive Node upgrades)
# @requires  base-packages
# @default   on
is_installed() { [[ -x $HOME/.local/share/fnm/fnm ]] || has_cmd fnm; }
version() { node --version 2>/dev/null; }
install() {
  sh_run 'curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell'
  refresh_path
  rc_block fnm 'export PATH="$HOME/.local/share/fnm:$HOME/.local/npm-global/bin:$PATH"
eval "$(fnm env --use-on-cd)"'
  run fnm install --lts
  run fnm default lts-latest
  has_cmd fnm && eval "$(fnm env)"
  mkdir -p "$HOME/.local/npm-global"
  run npm config set prefix "$HOME/.local/npm-global"
  refresh_path
}
update() {
  run fnm install --lts
  run fnm default lts-latest
  has_cmd fnm && eval "$(fnm env)"
  run npm config set prefix "$HOME/.local/npm-global"
  run npm install -g npm@latest
}
