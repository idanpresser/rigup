#!/usr/bin/env bash
# @id        cloudflared
# @name      cloudflared
# @category  Cloud CLIs
# @desc      Cloudflare Tunnel client (Cloudflare apt repo)
# @requires  base-packages
# @default   on
is_installed() { has_cmd cloudflared; }
version() { cloudflared --version; }
install() {
  # Cloudflare publishes a single 'any' suite that works on every Ubuntu release
  add_apt_repo cloudflared https://pkg.cloudflare.com/cloudflare-main.gpg \
    'deb [SIGNED] https://pkg.cloudflare.com/cloudflared any main'
  apt_install cloudflared
}
update() { apt_update_once; apt_install --only-upgrade cloudflared; }
