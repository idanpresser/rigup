#!/usr/bin/env bash
# @id        python-uv
# @name      Python (uv)
# @category  Runtimes
# @desc      uv + latest Python; project envs and tools via uv (system python untouched)
# @requires  base-packages
# @default   on
is_installed() { has_cmd uv; }
version() { uv --version; }
install() {
  sh_run 'curl -LsSf https://astral.sh/uv/install.sh | sh'
  refresh_path
  run uv python install
  run uv tool update-shell || true
}
update() { run uv self update || true; run uv python upgrade || true; run uv tool upgrade --all || true; }
