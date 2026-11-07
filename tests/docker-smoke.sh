#!/usr/bin/env bash
# Smoke test: run rigup for real inside a clean Ubuntu container (headless profile), verify the tools run,
# then re-run with --update to check idempotency. Needs docker access (sudo or docker group).
# usage: [SKIP=a,b] [EXTRA_ARGS=...] tests/docker-smoke.sh [image]
# Docker, GPU, sshd and other systemd-dependent modules are skipped by default (no systemd in containers).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${1:-ubuntu:26.04}"
SKIP="${SKIP:-docker,nvidia-driver,cuda-toolkit,nvidia-container-toolkit,openssh-server,ssh-harden,ufw,ollama,git-identity,ssh-key}"
mkdir -p "$ROOT/tests/tmp"
docker run --rm -v "$ROOT":/src:ro -e SKIP="$SKIP" -e EXTRA_ARGS="${EXTRA_ARGS:-}" "$IMAGE" bash -euo pipefail -c '
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq && apt-get install -y -qq sudo curl ca-certificates git >/dev/null
  useradd -m -s /bin/bash tester && echo "tester ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/tester
  su tester -c "cp -r /src ~/rigup" && su tester -c "SKIP=\"$SKIP\" EXTRA_ARGS=\"$EXTRA_ARGS\" bash ~/rigup/tests/container-inner.sh"
' 2>&1 | tee "$ROOT/tests/tmp/smoke.log"
