#!/usr/bin/env bash
# @id        base-packages
# @name      Base packages
# @category  Core
# @desc      curl wget git build-essential gnupg unzip jq pciutils whiptail ca-certificates
# @requires  apt-update
# @default   on
is_installed() { dpkg -s build-essential curl git jq unzip gnupg pciutils >/dev/null 2>&1; }
install() {
  apt_install curl wget git build-essential gnupg ca-certificates unzip zip jq pciutils \
    apt-transport-https whiptail lsb-release
}
