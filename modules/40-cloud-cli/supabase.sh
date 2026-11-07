#!/usr/bin/env bash
# @id        supabase
# @name      Supabase CLI
# @category  Cloud CLIs
# @desc      Supabase CLI (.deb from the latest GitHub release; npm -g is unsupported upstream)
# @requires  base-packages
# @default   on
is_installed() { has_cmd supabase; }
version() { supabase --version; }
install() {
  local url; url=$(gh_latest_asset supabase/cli "linux_${HW_ARCH}\\.deb$")
  [[ -n $url ]] || die "could not find supabase .deb asset"
  install_deb_url "$url"
}
update() { install; }
