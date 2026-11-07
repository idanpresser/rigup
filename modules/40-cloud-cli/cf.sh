#!/usr/bin/env bash
# @id        cf
# @name      Cloudflare cf CLI
# @category  Cloud CLIs
# @desc      Cloudflare's unified `cf` CLI (npm cf, currently beta)
# @requires  node-fnm
# @default   on
is_installed() { has_cmd cf; }
install() { npm_global cf; }
update() { npm_global cf@latest; }
