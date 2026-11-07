#!/usr/bin/env bash
# @id        railway
# @name      Railway CLI
# @category  Cloud CLIs
# @desc      Railway deploy CLI (npm @railway/cli)
# @requires  node-fnm
# @default   on
is_installed() { has_cmd railway; }
install() { npm_global @railway/cli; }
update() { npm_global @railway/cli@latest; }
