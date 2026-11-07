#!/usr/bin/env bash
# @id        gemini-cli
# @name      Gemini CLI
# @category  AI agents
# @desc      Google's Gemini coding CLI (npm @google/gemini-cli)
# @requires  node-fnm
# @default   on
is_installed() { has_cmd gemini; }
version() { gemini --version 2>/dev/null; }
install() { npm_global @google/gemini-cli; }
update() { npm_global @google/gemini-cli@latest; }
