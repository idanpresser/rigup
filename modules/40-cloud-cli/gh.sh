#!/usr/bin/env bash
# @id        gh
# @name      GitHub CLI
# @category  Cloud CLIs
# @desc      gh from GitHub's official apt repo
# @requires  base-packages
# @default   on
is_installed() { has_cmd gh; }
version() { gh --version | head -n1; }
install() {
  add_apt_repo githubcli https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    "deb [arch=$(dpkg --print-architecture) SIGNED] https://cli.github.com/packages stable main"
  apt_install gh
}
update() { apt_update_once; apt_install --only-upgrade gh; }
