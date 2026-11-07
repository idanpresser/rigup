#!/usr/bin/env bash
# @id        golang
# @name      Go
# @category  Runtimes
# @desc      Latest Go toolchain from go.dev into /usr/local/go
# @requires  base-packages
# @default   off
is_installed() { [[ -x /usr/local/go/bin/go ]] || has_cmd go; }
version() { /usr/local/go/bin/go version 2>/dev/null || go version; }
install() {
  local v arch; arch=$(dpkg --print-architecture)
  v=$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)
  [[ $v == go* ]] || die "could not determine latest Go version"
  if [[ -x /usr/local/go/bin/go && $(/usr/local/go/bin/go version) == *" $v "* ]]; then ok "Go $v already current"; else
    local tmp; tmp=$(mktemp -d)
    run curl -fsSL -o "$tmp/go.tgz" "https://go.dev/dl/$v.linux-$arch.tar.gz"
    run sudo rm -rf /usr/local/go
    run sudo tar -C /usr/local -xzf "$tmp/go.tgz"; rm -rf "$tmp"
  fi
  rc_block go 'export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"'
}
update() { install; }
