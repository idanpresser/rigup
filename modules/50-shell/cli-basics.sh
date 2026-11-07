#!/usr/bin/env bash
# @id        cli-basics
# @name      Modern CLI basics
# @category  Shell
# @desc      ripgrep fd bat eza fzf jq yq btop tmux zoxide direnv
# @requires  base-packages
# @default   on
is_installed() { dpkg -s ripgrep fd-find bat fzf tmux zoxide direnv btop >/dev/null 2>&1; }
install() {
  apt_install ripgrep fd-find bat fzf jq tmux zoxide direnv btop
  apt_install eza || warn "eza not in apt for this release, skipping"
  apt_install yq || warn "yq not in apt for this release, skipping"
  mkdir -p "$HOME/.local/bin"
  [[ -x /usr/bin/fdfind ]] && run ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
  [[ -x /usr/bin/batcat ]] && run ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
  rc_block cli-basics 'export PATH="$HOME/.local/bin:$PATH"
command -v zoxide >/dev/null && eval "$(zoxide init bash 2>/dev/null || true)"
command -v direnv >/dev/null && eval "$(direnv hook bash 2>/dev/null || true)"'
}
update() { apt_update_once; install; }
