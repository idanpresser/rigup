#!/usr/bin/env bash
# @id        antigravity
# @name      Google Antigravity
# @category  AI agents
# @desc      Google's agentic IDE from Google's apt repo (desktop only)
# @requires  base-packages
# @default   desktop
# @when      desktop,!wsl
is_installed() { dpkg -s antigravity >/dev/null 2>&1; }
install() {
  add_apt_repo antigravity https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg \
    'deb [SIGNED] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main'
  apt_install antigravity
}
update() { apt_update_once; apt_install --only-upgrade antigravity; }
