#!/usr/bin/env bash
# @id        aws
# @name      AWS CLI v2
# @category  Cloud CLIs
# @desc      Official AWS CLI v2 bundle
# @requires  base-packages
# @default   off
is_installed() { has_cmd aws; }
version() { aws --version; }
install() {
  local a=x86_64; [[ $HW_ARCH == arm64 ]] && a=aarch64
  local tmp; tmp=$(mktemp -d)
  run curl -fsSL -o "$tmp/aws.zip" "https://awscli.amazonaws.com/awscli-exe-linux-$a.zip"
  run unzip -q "$tmp/aws.zip" -d "$tmp"
  run sudo "$tmp/aws/install" --update
  rm -rf "$tmp"
}
update() { install; }
