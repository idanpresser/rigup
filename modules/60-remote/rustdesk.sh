#!/usr/bin/env bash
# @id        rustdesk
# @name      RustDesk
# @category  Remote
# @desc      Open-source remote desktop (.deb from GitHub). Best on X11; Wayland support is partial.
# @requires  base-packages
# @default   desktop
# @when      desktop,!wsl
is_installed() { dpkg -s rustdesk >/dev/null 2>&1; }
version() { dpkg-query -W -f='${Version}\n' rustdesk; }
install() {
  local re='x86_64\.deb$' url
  [[ $HW_ARCH == arm64 ]] && re='aarch64\.deb$'
  url=$(gh_latest_asset rustdesk/rustdesk "rustdesk-[0-9.]+-$re" | grep -v -e sciter -e unattended | head -n1)
  [[ -n $url ]] || die "could not find a RustDesk .deb for $HW_ARCH"
  install_deb_url "$url"
  [[ ${XDG_SESSION_TYPE:-} == wayland ]] && warn "Wayland session: for unattended access choose 'Ubuntu on Xorg' at the login screen."
  return 0
}
update() { install; }
