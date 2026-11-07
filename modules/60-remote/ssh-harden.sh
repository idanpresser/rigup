#!/usr/bin/env bash
# @id        ssh-harden
# @name      SSH key-only login
# @category  Remote
# @desc      Disable password logins and root login (only if ~/.ssh/authorized_keys has a key, so you can't lock yourself out)
# @requires  openssh-server
# @default   off
is_installed() { [[ -f /etc/ssh/sshd_config.d/50-rigup.conf ]]; }
install() {
  if [[ ! -s $HOME/.ssh/authorized_keys ]]; then
    warn "~/.ssh/authorized_keys is empty: refusing to disable passwords. Add your public key first (ssh-copy-id), then re-run."
    return 0
  fi
  local conf=/etc/ssh/sshd_config.d/50-rigup.conf
  [[ "$DRY_RUN" == 1 ]] && { echo "[dry-run] write $conf"; return 0; }
  printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin no\n' | sudo tee "$conf" >/dev/null
  if sudo sshd -t; then sudo systemctl reload ssh; ok "password logins disabled"
  else sudo rm -f "$conf"; die "sshd config test failed, change reverted"; fi
}
update() { install; }
