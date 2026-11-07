#!/usr/bin/env bash
# Runs inside the container as a normal user (called by docker-smoke.sh). Env: SKIP, EXTRA_ARGS.
cd "$HOME/rigup" || exit 1
echo "=== RUN 1 ==="
# shellcheck disable=SC2086
./install.sh --yes --profile ai-server --skip "$SKIP" ${EXTRA_ARGS:-}
echo "=== RUN 1 exit=$? ==="

echo "=== VERIFY ==="
source lib/common.sh
refresh_path
for c in node npm pnpm uv claude codex opencode hermes gh wrangler cloudflared hf mosh tailscale rg; do
  if out=$("$c" --version 2>&1 | head -n1) && command -v "$c" >/dev/null; then echo "OK   $c: $out"; else echo "FAIL $c"; fi
done

echo "=== RUN 2 update ==="
./install.sh --update --yes
echo "=== RUN 2 exit=$? ==="
