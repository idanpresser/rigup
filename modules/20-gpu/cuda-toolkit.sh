#!/usr/bin/env bash
# @id        cuda-toolkit
# @name      CUDA toolkit
# @category  GPU
# @desc      NVIDIA CUDA toolkit from NVIDIA's apt repo (WSL-aware; driver not included)
# @requires  base-packages
# @default   gpu=nvidia
# @when      gpu=nvidia
is_installed() { dpkg -s cuda-toolkit >/dev/null 2>&1 || [[ -x /usr/local/cuda/bin/nvcc ]]; }
install() {
  local arch=x86_64 distro base keyring
  [[ $HW_ARCH == arm64 ]] && arch=sbsa
  if [[ $ENV_WSL == 1 ]]; then distro=wsl-ubuntu; arch=x86_64
  else distro="ubuntu${OS_VERSION//./}"; fi
  base="https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch"
  if ! url_exists "$base/cuda-keyring_1.1-1_all.deb"; then
    warn "no CUDA repo for $distro, trying ubuntu2404"; base="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/$arch"
  fi
  keyring=$(mktemp -d)/k.deb
  run curl -fsSL -o "$keyring" "$base/cuda-keyring_1.1-1_all.deb"
  run sudo dpkg -i "$keyring"
  run sudo apt-get update -y
  apt_install cuda-toolkit
  rc_block cuda 'export PATH="/usr/local/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"'
}
update() { apt_update_once; apt_install --only-upgrade cuda-toolkit; }
