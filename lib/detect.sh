#!/usr/bin/env bash
# Exports facts about this machine. Source it, then read ENV_* / HW_* / OS_*.

OS_VERSION=$(. /etc/os-release && echo "${VERSION_ID:-unknown}")
OS_CODENAME=$(. /etc/os-release && echo "${VERSION_CODENAME:-unknown}")
OS_ID=$(. /etc/os-release && echo "${ID:-unknown}")
HW_ARCH=$(dpkg --print-architecture 2>/dev/null || echo amd64)

ENV_WSL=0; grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null && ENV_WSL=1

ENV_DESKTOP=0
if [[ -n "${XDG_CURRENT_DESKTOP:-}" || -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]] \
   || dpkg -s ubuntu-desktop >/dev/null 2>&1 || dpkg -s ubuntu-desktop-minimal >/dev/null 2>&1; then
  ENV_DESKTOP=1
fi
[[ $ENV_WSL == 1 && -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] && ENV_DESKTOP=0   # WSL without WSLg

HW_RAM_GB=$(awk '/MemTotal/ {printf "%d", $2/1024/1024 + 0.5}' /proc/meminfo)

HW_GPU=none; HW_VRAM_GB=0
_pci=$(lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display' || true)
if   grep -qi nvidia <<<"$_pci" || has_cmd nvidia-smi; then HW_GPU=nvidia
elif grep -qiE 'amd|ati' <<<"$_pci"; then HW_GPU=amd
elif grep -qi intel <<<"$_pci"; then HW_GPU=intel
fi
# WSL exposes the Windows GPU through /usr/lib/wsl without lspci hits
[[ $ENV_WSL == 1 && -e /usr/lib/wsl/lib/nvidia-smi ]] && HW_GPU=nvidia
if [[ $HW_GPU == nvidia ]]; then
  _smi=$(command -v nvidia-smi || ls /usr/lib/wsl/lib/nvidia-smi 2>/dev/null || true)
  if [[ -n $_smi ]]; then
    _mib=$("$_smi" --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1 || true)
    [[ $_mib =~ ^[0-9]+$ ]] && HW_VRAM_GB=$(( (_mib + 512) / 1024 ))
  fi
fi

export OS_VERSION OS_CODENAME OS_ID HW_ARCH ENV_WSL ENV_DESKTOP HW_RAM_GB HW_GPU HW_VRAM_GB

detect_summary() {
  local kind=server; [[ $ENV_DESKTOP == 1 ]] && kind=desktop; [[ $ENV_WSL == 1 ]] && kind="wsl/$kind"
  echo "Ubuntu $OS_VERSION ($OS_CODENAME) $HW_ARCH | $kind | RAM ${HW_RAM_GB}GB | GPU $HW_GPU${HW_VRAM_GB:+ ${HW_VRAM_GB}GB VRAM}"
}
