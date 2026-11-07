#!/usr/bin/env bash
# @id        flyctl
# @name      Fly.io (flyctl)
# @category  Cloud CLIs
# @desc      Fly.io CLI (official installer)
# @requires  base-packages
# @default   on
is_installed() { has_cmd flyctl || [[ -x $HOME/.fly/bin/flyctl ]]; }
version() { flyctl version 2>/dev/null | head -n1; }
install() {
  sh_run 'curl -fsSL https://fly.io/install.sh | sh'
  rc_block flyctl 'export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"'
}
update() { run flyctl version upgrade || install; }
