#!/usr/bin/env bash
# @id        ai-env
# @name      API key env file
# @category  Config
# @desc      ~/.config/ai-env/env (chmod 600) with key placeholders, sourced from your shell
# @default   on
is_installed() { [[ -f $HOME/.config/ai-env/env ]]; }
install() {
  local f="$HOME/.config/ai-env/env"
  [[ "$DRY_RUN" == 1 ]] || {
    mkdir -p "$(dirname "$f")"
    cat >"$f" <<'ENVF'
# API keys and tokens. Uncomment and fill in. Never commit this file.
# export ANTHROPIC_API_KEY=""
# export OPENAI_API_KEY=""
# export GEMINI_API_KEY=""
# export OPENROUTER_API_KEY=""
# export HF_TOKEN=""
# export CLOUDFLARE_API_TOKEN=""
# export CLOUDFLARE_ACCOUNT_ID=""
# export GITHUB_TOKEN=""
# export VERCEL_TOKEN=""
# export SUPABASE_ACCESS_TOKEN=""
# export FLY_API_TOKEN=""
# export RAILWAY_TOKEN=""
ENVF
    chmod 600 "$f"
  }
  post_install
}
post_install() { rc_block ai-env '[ -f "$HOME/.config/ai-env/env" ] && . "$HOME/.config/ai-env/env"'; }
update() { post_install; }   # never overwrite your keys
