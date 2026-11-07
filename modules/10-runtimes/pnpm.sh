#!/usr/bin/env bash
# @id        pnpm
# @name      pnpm
# @category  Runtimes
# @desc      pnpm package manager via npm
# @requires  node-fnm
# @default   on
is_installed() { has_cmd pnpm; }
install() { npm_global pnpm; }
update() { npm_global pnpm@latest; }
