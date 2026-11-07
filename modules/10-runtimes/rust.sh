#!/usr/bin/env bash
# @id        rust
# @name      Rust (rustup)
# @category  Runtimes
# @desc      rustup + stable toolchain
# @requires  base-packages
# @default   off
is_installed() { has_cmd rustup || [[ -x $HOME/.cargo/bin/rustup ]]; }
install() { sh_run "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"
  rc_block rust '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"'; }
update() { run rustup update; }
