#!/usr/bin/env bash
# @id        openssh-server
# @name      OpenSSH server
# @category  Remote
# @desc      sshd so you can log in remotely (needs systemd on WSL)
# @requires  base-packages
# @default   headless
is_installed() { dpkg -s openssh-server >/dev/null 2>&1 && systemctl is-active --quiet ssh 2>/dev/null; }
install() {
  apt_install openssh-server
  run sudo systemctl enable --now ssh || warn "could not start ssh (is systemd enabled?)"
}
update() { apt_update_once; apt_install --only-upgrade openssh-server; }
