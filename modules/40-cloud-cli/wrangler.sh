#!/usr/bin/env bash
# @id        wrangler
# @name      Cloudflare Wrangler
# @category  Cloud CLIs
# @desc      Workers/Pages CLI (npm wrangler)
# @requires  node-fnm
# @default   on
is_installed() { has_cmd wrangler; }
version() { wrangler --version 2>/dev/null | head -n1; }
install() { npm_global wrangler; }
update() { npm_global wrangler@latest; }
