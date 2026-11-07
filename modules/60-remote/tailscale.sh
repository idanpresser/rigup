#!/usr/bin/env bash
# @id        tailscale
# @name      Tailscale
# @category  Remote
# @desc      Private mesh VPN: reach this PC from anywhere without opening ports (run 'sudo tailscale up' to join)
# @requires  base-packages
# @default   on
is_installed() { has_cmd tailscale; }
version() { tailscale version | head -n1; }
install() { sh_run 'curl -fsSL https://tailscale.com/install.sh | sh'; }
update() { apt_update_once; apt_install --only-upgrade tailscale; }
