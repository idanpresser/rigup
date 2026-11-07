#!/usr/bin/env bash
# @id        ollama
# @name      Ollama
# @category  GPU
# @desc      Run local LLMs (official installer; uses CUDA/ROCm automatically). Needs 16GB+ RAM to be useful.
# @requires  base-packages
# @default   ram>=16
is_installed() { has_cmd ollama; }
version() { ollama --version 2>/dev/null; }
install() { sh_run 'curl -fsSL https://ollama.com/install.sh | sh'; }
update() { install; }
