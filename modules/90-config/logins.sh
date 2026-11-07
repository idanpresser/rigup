#!/usr/bin/env bash
# @id        logins
# @name      Guided logins
# @category  Config
# @desc      Walk through tailscale / gh / wrangler / claude / codex / hf / vercel / supabase / fly / railway logins (skippable)
# @default   off
# @interactive yes
is_installed() { false; }
_login() { # _login TOOL "login command..." "status check command"
  has_cmd "$1" || return 0
  if bash -c "$3" >/dev/null 2>&1; then ok "$1 already logged in"; return 0; fi
  local a; a=$(ask "Log in to $1 now? (y/N)" n)
  [[ $a =~ ^[Yy] ]] && { bash -c "$2" || warn "$1 login did not complete"; }
  return 0
}
install() {
  can_prompt || { warn "needs a terminal"; return 0; }
  _login gh        "gh auth login"            "gh auth status"
  _login wrangler  "wrangler login"           "wrangler whoami"
  _login cf        "cf login"                 "cf whoami"
  _login claude    "claude"                   "test -f ~/.claude/.credentials.json -o -f ~/.claude.json"
  _login codex     "codex login"              "codex login status"
  _login hf        "hf auth login"            "hf auth whoami"
  _login vercel    "vercel login"             "vercel whoami"
  _login supabase  "supabase login"           "test -n \"\$SUPABASE_ACCESS_TOKEN\""
  _login flyctl    "flyctl auth login"        "flyctl auth whoami"
  _login railway   "railway login"            "railway whoami"
  _login gcloud    "gcloud auth login"        "gcloud auth list --filter=status:ACTIVE --format='value(account)' | grep -q ."
  _login az        "az login"                 "az account show"
  _login aws       "aws configure"            "aws sts get-caller-identity"
  _login tailscale "sudo tailscale up"       "tailscale status"
  _login ollama    "true"                     "true"
}
update() { install; }
