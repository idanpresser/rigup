#!/usr/bin/env bash
# @id        gcloud
# @name      Google Cloud CLI
# @category  Cloud CLIs
# @desc      gcloud from Google's apt repo
# @requires  base-packages
# @default   off
is_installed() { has_cmd gcloud; }
version() { gcloud --version | head -n1; }
install() {
  add_apt_repo google-cloud-sdk https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    'deb [SIGNED] https://packages.cloud.google.com/apt cloud-sdk main'
  apt_install google-cloud-cli
}
update() { apt_update_once; apt_install --only-upgrade google-cloud-cli; }
