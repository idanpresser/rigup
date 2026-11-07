#!/usr/bin/env bash
# @id        docker
# @name      Docker Engine
# @category  Runtimes
# @desc      docker-ce + compose + buildx from Docker's apt repo, adds you to the docker group
# @requires  base-packages
# @default   on
# @when      !wsl
is_installed() { has_cmd docker; }
version() { docker --version; }
install() {
  local suite arch; arch=$(dpkg --print-architecture)
  suite=$(repo_suite https://download.docker.com/linux/ubuntu/dists noble)
  add_apt_repo docker https://download.docker.com/linux/ubuntu/gpg \
    "deb [arch=$arch SIGNED] https://download.docker.com/linux/ubuntu $suite stable"
  apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  run sudo systemctl enable --now docker
  if ! id -nG "$USER" | grep -qw docker; then run sudo usermod -aG docker "$USER"; need_relogin docker-group; fi
}
update() { apt_update_once; apt_install --only-upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; }
