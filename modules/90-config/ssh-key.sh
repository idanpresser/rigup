#!/usr/bin/env bash
# @id        ssh-key
# @name      SSH key (ed25519)
# @category  Config
# @desc      Generate ~/.ssh/id_ed25519 if missing; upload to GitHub if gh is logged in
# @requires  base-packages
# @default   on
# @interactive yes
is_installed() { [[ -f $HOME/.ssh/id_ed25519.pub ]]; }
install() {
  local email; email=$(git config --global user.email || echo "$USER@$(hostname)")
  mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
  run ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
  post_install
}
post_install() {
  if has_cmd gh && gh auth status >/dev/null 2>&1; then
    run gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(hostname)-$(date +%Y%m%d)" || true
  else
    warn "gh not logged in: after 'gh auth login' run: gh ssh-key add ~/.ssh/id_ed25519.pub"
  fi
}
update() { :; }
