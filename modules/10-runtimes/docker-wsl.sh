#!/usr/bin/env bash
# @id        docker-wsl
# @name      Docker Engine (inside WSL)
# @category  Runtimes
# @desc      Native Docker Engine in WSL (needs systemd=true in /etc/wsl.conf). Skip if you use Docker Desktop.
# @requires  base-packages
# @default   off
# @when      wsl
is_installed() { has_cmd docker; }
install() {
  grep -qs 'systemd *= *true' /etc/wsl.conf || warn "Enable systemd: add [boot] systemd=true to /etc/wsl.conf, then 'wsl --shutdown'"
  local suite arch; arch=$(dpkg --print-architecture)
  suite=$(repo_suite https://download.docker.com/linux/ubuntu/dists noble)
  add_apt_repo docker https://download.docker.com/linux/ubuntu/gpg \
    "deb [arch=$arch SIGNED] https://download.docker.com/linux/ubuntu $suite stable"
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  run sudo systemctl enable --now docker || warn "could not start docker (systemd off?)"
  id -nG "$USER" | grep -qw docker || { run sudo usermod -aG docker "$USER"; need_relogin docker-group; }
}
update() { apt_update_once; apt_install --only-upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; }
