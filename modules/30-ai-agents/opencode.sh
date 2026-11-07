#!/usr/bin/env bash
# @id        opencode
# @name      opencode
# @category  AI agents
# @desc      Open-source terminal coding agent (official installer)
# @requires  base-packages
# @default   on
is_installed() { has_cmd opencode; }
version() { opencode --version 2>/dev/null; }
install() { sh_run 'curl -fsSL https://opencode.ai/install | bash'; }
update() { run opencode upgrade || install; }
