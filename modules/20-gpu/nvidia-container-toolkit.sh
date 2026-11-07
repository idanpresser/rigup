#!/usr/bin/env bash
# @id        nvidia-container-toolkit
# @name      NVIDIA Container Toolkit
# @category  GPU
# @desc      Lets Docker containers use the GPU (--gpus all)
# @requires  docker
# @default   gpu=nvidia
# @when      gpu=nvidia,!wsl
is_installed() { dpkg -s nvidia-container-toolkit >/dev/null 2>&1; }
install() {
  [[ "$DRY_RUN" != 1 ]] && {
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor --yes -o /etc/apt/keyrings/nvidia-container-toolkit.gpg
    curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
      | sed 's#deb https://#deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://#g' \
      | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
    sudo apt-get update -y
  }
  apt_install nvidia-container-toolkit
  run sudo nvidia-ctk runtime configure --runtime=docker
  run sudo systemctl restart docker
}
update() { apt_update_once; apt_install --only-upgrade nvidia-container-toolkit; }
