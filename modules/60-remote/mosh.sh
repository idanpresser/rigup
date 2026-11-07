#!/usr/bin/env bash
# @id        mosh
# @name      mosh
# @category  Remote
# @desc      Roaming SSH that survives network changes and sleep (UDP 60000-61000)
# @requires  base-packages
# @default   headless
is_installed() { has_cmd mosh; }
install() { apt_install mosh; }
update() { apt_update_once; apt_install --only-upgrade mosh; }
