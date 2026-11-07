#!/usr/bin/env bash
# @id        apt-update
# @name      apt update + upgrade
# @category  Core
# @desc      Refresh package lists and upgrade installed packages
# @default   on
is_installed() { false; }   # always runs
install() { run sudo apt-get update -y; run sudo env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; }
