#!/usr/bin/env bash
# @id        bun
# @name      Bun
# @category  Runtimes
# @desc      Bun JavaScript runtime (official installer)
# @requires  base-packages
# @default   off
is_installed() { has_cmd bun; }
install() { sh_run 'curl -fsSL https://bun.sh/install | bash'; }
update() { run bun upgrade; }
