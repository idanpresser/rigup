# rigup

Set up a fresh Ubuntu machine for AI work from one checklist.
Pick what you want, and rigup installs it: runtimes, coding agents, cloud CLIs, GPU tooling, shell tools and first-time config.

Works on Ubuntu 26.04 / 24.04, on desktops, headless servers and WSL.

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/idanpresser/rigup/main/bootstrap.sh | bash
```

This installs `git`, `curl` and `whiptail` if missing, clones the repo to `~/.local/share/rigup`, and opens the checklist.

Or from a checkout:

```bash
git clone https://github.com/idanpresser/rigup.git && cd rigup
./install.sh
```

## What you get

| Category | Modules |
|---|---|
| Core | apt update/upgrade, base packages |
| Runtimes | Node (fnm), pnpm, Bun, Python (uv), Docker, Go, Rust |
| GPU / local LLMs | NVIDIA driver, CUDA toolkit, NVIDIA Container Toolkit, Ollama |
| AI agents | Claude Code, Codex CLI, Gemini CLI, opencode, Hermes Agent, Cursor, Google Antigravity |
| Cloud CLIs | gh, wrangler, cf, cloudflared, Vercel, Railway, Supabase, Fly.io, Hugging Face, AWS, gcloud, Azure |
| Shell | ripgrep, fd, bat, eza, fzf, jq, yq, btop, tmux, zoxide, direnv |
| Remote | OpenSSH server, key-only SSH hardening, mosh, Tailscale, RustDesk, ufw firewall |
| Config | git identity, SSH key (uploaded to GitHub), API-key env file, guided logins |

Run `./install.sh --list` to see every module on your machine.

## Hardware-aware defaults

rigup detects the GPU, RAM, VRAM, desktop vs server and WSL, then adjusts the menu:

- NVIDIA GPU: driver, CUDA and container toolkit are pre-checked.
- 16GB+ RAM: Ollama is pre-checked.
- Server or WSL without a GUI: Cursor and Antigravity are hidden.
- Servers: OpenSSH, mosh and Tailscale are pre-checked. Desktops get RustDesk.
- WSL: the NVIDIA driver is hidden, because Windows provides it.

You can override any default in the menu.

## Usage

```bash
./install.sh                              # interactive checklist
./install.sh --profile ai-server --yes    # unattended, from a profile
./install.sh --only claude-code,gh        # exactly these (dependencies are added)
./install.sh --skip docker,rust           # remove items from the selection
./install.sh --update                     # update everything already installed
./install.sh --dry-run                    # print what would run, change nothing
./install.sh --list                       # modules, visibility, defaults, installed state
```

Profiles live in `profiles/`: `ai-desktop`, `ai-server`, `minimal`. They are plain lists of module ids.

Re-running is safe. Installed modules are updated instead of reinstalled, and a failure in one module doesn't stop the others. A summary and a log file (`~/.local/state/rigup/logs/`) show what happened. The installer also tells you if a reboot or re-login is needed.

`--yes` skips the steps that need input (git identity, SSH key, logins).

## How it works

```
bootstrap.sh     curl|bash entry point
install.sh       flags -> detect -> menu -> dependency order -> run -> summary
lib/             common helpers, hardware detection, module registry, menu
modules/NN-cat/  one file per tool
profiles/        preset selections
```

Each module is one bash file with a metadata header and a few functions:

```bash
#!/usr/bin/env bash
# @id        claude-code
# @name      Claude Code
# @category  AI agents
# @desc      Anthropic's agentic coding CLI
# @requires  base-packages
# @default   on                 # on | off | a condition such as gpu=nvidia or ram>=16
# @when      always             # hide the module unless this holds
# @interactive no               # yes = needs a terminal, skipped with --yes

is_installed() { has_cmd claude; }
install()      { sh_run 'curl -fsSL https://claude.ai/install.sh | bash'; }
update()       { run claude update || install; }   # optional, falls back to install
version()      { claude --version; }               # optional
```

Conditions for `@when` and `@default` (comma means AND):
`always`, `desktop`, `headless`, `wsl`, `!wsl`, `gpu=nvidia|amd|intel|any`, `ram>=N`, `vram>=N`, `arch=amd64`.

Helpers such as `run`, `sh_run`, `apt_install`, `add_apt_repo`, `rc_block`, `npm_global` and `install_deb_url` are in `lib/common.sh`. Use `run` for anything that changes the system so `--dry-run` stays safe. Edit your shell config only through `rc_block`, which keeps a managed block and never duplicates lines.

To add a tool, drop a file into the right `modules/` folder. No other registration is needed.

## Notes

- Run as your normal user, not root. `sudo` is used only where needed.
- Remote access: `ssh-harden` only disables passwords if `~/.ssh/authorized_keys` already has a key, and `ufw` allows SSH before enabling. Join Tailscale with `sudo tailscale up` (or the logins module).
- API keys go in `~/.config/ai-env/env` (mode 600), never in the repo.
- npm globals install to `~/.local/npm-global`, so they survive Node upgrades.
- Vendors that haven't published an Ubuntu 26.04 package source yet fall back to the 24.04 one, with a warning.
- Status: dry-run tested. Try it in a VM before using it on a machine you care about.

## License

Apache-2.0, see [LICENSE](LICENSE).
