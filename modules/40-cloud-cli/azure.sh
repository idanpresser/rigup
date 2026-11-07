#!/usr/bin/env bash
# @id        azure
# @name      Azure CLI
# @category  Cloud CLIs
# @desc      az via Microsoft's official script (apt repo)
# @requires  base-packages
# @default   off
is_installed() { has_cmd az; }
version() { az version 2>/dev/null | jq -r '."azure-cli"' 2>/dev/null; }
install() { sh_run 'curl -fsSL https://aka.ms/InstallAzureCLIDeb | sudo bash'; }
update() { apt_update_once; apt_install --only-upgrade azure-cli; }
