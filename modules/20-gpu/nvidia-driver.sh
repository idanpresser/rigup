#!/usr/bin/env bash
# @id        nvidia-driver
# @name      NVIDIA driver
# @category  GPU
# @desc      Recommended proprietary driver via ubuntu-drivers (reboot required)
# @requires  base-packages
# @default   gpu=nvidia
# @when      gpu=nvidia,!wsl
is_installed() { has_cmd nvidia-smi && nvidia-smi >/dev/null 2>&1; }
install() { apt_install ubuntu-drivers-common; run sudo ubuntu-drivers install; need_reboot nvidia-driver; }
update() { apt_update_once; run sudo ubuntu-drivers install || true; }
