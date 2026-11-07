#!/usr/bin/env bash
# @id        hermes-agent
# @name      Hermes Agent
# @category  AI agents
# @desc      Nous Research's Hermes agent (official install script)
# @requires  base-packages
# @default   on
is_installed() { has_cmd hermes; }
version() { hermes --version 2>/dev/null; }
install() { sh_run 'curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash'; }
update() { run hermes update || install; }
