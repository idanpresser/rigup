#!/usr/bin/env bash
# @id        huggingface
# @name      Hugging Face CLI
# @category  Cloud CLIs
# @desc      `hf` CLI via uv tool
# @requires  python-uv
# @default   on
is_installed() { has_cmd hf; }
install() { run uv tool install 'huggingface_hub[cli]'; }
update() { run uv tool upgrade huggingface_hub; }
