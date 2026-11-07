#!/usr/bin/env bash
# @id        vercel
# @name      Vercel CLI
# @category  Cloud CLIs
# @desc      Vercel deploy CLI (npm vercel)
# @requires  node-fnm
# @default   on
is_installed() { has_cmd vercel; }
install() { npm_global vercel; }
update() { npm_global vercel@latest; }
