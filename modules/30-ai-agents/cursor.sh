#!/usr/bin/env bash
# @id        cursor
# @name      Cursor
# @category  AI agents
# @desc      Cursor AI editor (.deb from cursor.com; desktop only)
# @requires  base-packages
# @default   off
# @when      desktop,!wsl
is_installed() { dpkg -s cursor >/dev/null 2>&1; }
install() {
  local a=x64; [[ $HW_ARCH == arm64 ]] && a=arm64
  install_deb_url "https://api2.cursor.sh/updates/download/golden/linux-$a-deb/cursor/latest"
}
update() { install; }   # Cursor also self-updates; this re-fetches latest
