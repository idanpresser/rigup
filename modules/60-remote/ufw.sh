#!/usr/bin/env bash
# @id        ufw
# @name      Firewall (ufw)
# @category  Remote
# @desc      Deny incoming by default; allow SSH (and Tailscale) first so you can't lock yourself out
# @requires  base-packages
# @default   off
# @when      !wsl
is_installed() { sudo -n ufw status 2>/dev/null | grep -q 'Status: active'; }
install() {
  apt_install ufw
  run sudo ufw default deny incoming
  run sudo ufw default allow outgoing
  run sudo ufw allow OpenSSH
  has_cmd tailscale && run sudo ufw allow in on tailscale0
  has_cmd mosh && run sudo ufw allow 60000:61000/udp
  run sudo ufw --force enable
}
update() { install; }
