#!/usr/bin/env bash
# @id        codex
# @name      OpenAI Codex CLI
# @category  AI agents
# @desc      OpenAI's coding agent (npm @openai/codex)
# @requires  node-fnm
# @default   on
is_installed() { has_cmd codex; }
version() { codex --version 2>/dev/null; }
install() { npm_global @openai/codex; }
update() { npm_global @openai/codex@latest; }
