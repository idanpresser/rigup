#!/usr/bin/env bash
# @id        claude-code
# @name      Claude Code
# @category  AI agents
# @desc      Anthropic's agentic coding CLI (native installer, self-updating)
# @requires  base-packages
# @default   on
is_installed() { has_cmd claude; }
version() { claude --version 2>/dev/null; }
install() { sh_run 'curl -fsSL https://claude.ai/install.sh | bash'; }
update() { run claude update || install; }
