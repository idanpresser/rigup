# Ubuntu AI Workstation Installer — Architecture Plan

Target: Ubuntu 26.04 LTS (and 24.04), on desktop, headless server, and WSL.
Entry: `curl -fsSL https://raw.githubusercontent.com/<you>/ubuntu-ai-setup/main/bootstrap.sh | bash`

## 1. Layout

```
ubuntu-ai-setup/
├── bootstrap.sh          # curl|bash entry: apt install git, clone/pull repo to
│                         # ~/.local/share/ubuntu-ai-setup, exec install.sh </dev/tty
├── install.sh            # orchestrator: parse flags → detect → menu → resolve → run → summary
├── lib/
│   ├── common.sh         # log/info/warn/die, run (dry-run aware), retry, sudo keep-alive,
│   │                     # has_cmd, apt_install, add_apt_repo (deb822 + /etc/apt/keyrings),
│   │                     # rc_block (managed block in ~/.bashrc), path_add
│   ├── detect.sh         # exports HW_* / ENV_* facts (see §4)
│   ├── registry.sh       # scan modules/, parse @headers, evaluate @when, topo-sort @requires
│   └── menu.sh           # whiptail checklist (one screen per category or one long list)
├── modules/
│   ├── 00-core/          apt-update, base-packages (curl wget git build-essential gnupg
│   │                     ca-certificates unzip software-properties-common pciutils)
│   ├── 10-runtimes/      node-fnm (+pnpm, bun), python-uv, docker, go, rust
│   ├── 20-gpu/           nvidia-driver, cuda-toolkit, nvidia-container-toolkit, ollama
│   ├── 30-ai-agents/     claude-code, codex, gemini-cli, opencode, hermes-agent,
│   │                     cursor (desktop), antigravity (desktop)
│   ├── 40-cloud-cli/     gh, wrangler, cloudflared, cf, vercel, supabase, flyctl,
│   │                     railway, huggingface, aws, gcloud, azure
│   ├── 50-shell/         cli-basics (ripgrep fd bat eza fzf jq yq btop tmux zoxide direnv)
│   └── 90-config/        git-identity, ssh-key, ai-env, logins
├── profiles/             ai-desktop.conf, ai-server.conf, minimal.conf  (lists of module ids)
└── tests/                shellcheck + bats; Dockerfile.ubuntu2604 for headless dry/real runs
```

## 2. Module contract

Each module is one bash file: metadata in comment headers plus four functions.

```bash
#!/usr/bin/env bash
# @id        claude-code
# @name      Claude Code
# @category  AI agents
# @desc      Anthropic's agentic coding CLI (native installer)
# @requires  base-packages
# @default   on                      # on | off | auto (decided by @when)
# @when      always                  # e.g. desktop | gpu=nvidia | ram>=16 | !wsl
# @scope     user                    # user | system (system = needs sudo)

is_installed() { has_cmd claude; }
version()      { claude --version 2>/dev/null; }
install()      { curl -fsSL https://claude.ai/install.sh | bash; }
update()       { claude update; }
# optional: post_install()  — e.g. PATH hints, login prompt registration
```

Rules:
- Run as the normal user. `install.sh` refuses to run as root and calls `sudo` only where needed, keeping the sudo session alive in the background.
- Every module runs in its own subshell, so a failure is logged and the run continues. The summary lists ✔ installed / ↻ updated / ✖ failed / – skipped.
- Modules must be idempotent: `install.sh` calls `is_installed`, then picks `update` or `install`.
- No module writes secrets. Anything that needs input (git name, logins) goes in `90-config`, and `--yes` skips it.
- Shell rc changes go only through `rc_block <id> <content>`, which writes a delimited block that is rewritten in place. That means no duplicate PATH lines.

## 3. Orchestrator flow

1. Parse flags: `--yes`, `--profile <name>`, `--only a,b`, `--skip x`, `--dry-run`, `--update` (update everything installed), `--list`.
2. Preflight: check Ubuntu version, internet access, free disk space, and sudo. Warn on releases that aren't tested.
3. Run `detect.sh` to get the facts.
4. `registry.sh` builds the catalog: id, name, category, installed state, version, and a default ON/OFF from `@default`/`@when`, the profile, and detection. Modules whose `@when` can never apply are hidden (e.g. Cursor when headless).
5. `menu.sh` shows a whiptail checklist. Items are labeled like `[installed v2.1]` or `[recommended: NVIDIA detected]`.
6. Expand dependencies (checking `codex` pulls in `node-fnm`), then topo-sort. The phase order is 00 → 90.
7. Execute each module. After each one, re-source PATH (fnm env, `~/.local/bin`, `~/.cargo/bin`, `/usr/local/go/bin`).
8. Print the summary and log path (`~/.local/state/ubuntu-ai-setup/logs/<ts>.log`) and flag anything that needs a reboot or re-login (NVIDIA driver, docker group).

## 4. Hardware / environment detection → defaults

| Fact | How | Effect |
|---|---|---|
| `ENV_WSL` | `/proc/sys/kernel/osrelease` contains `microsoft` | hide nvidia-driver (Windows host provides it); use the WSL CUDA repo; check that systemd is enabled for docker |
| `ENV_DESKTOP` | `XDG_CURRENT_DESKTOP` set or `gnome-shell`/`ubuntu-desktop` installed | show Cursor, Antigravity |
| `HW_GPU` | `lspci -nn` for NVIDIA/AMD/Intel, plus `nvidia-smi` | NVIDIA → pre-check driver, CUDA, container toolkit |
| `HW_RAM_GB` | `/proc/meminfo` | ≥16 GB → pre-check Ollama; <8 GB → mark it "not recommended" |
| `HW_VRAM_GB` | `nvidia-smi --query-gpu=memory.total` | shown in the Ollama label as a model-size hint |
| `HW_ARCH` | `dpkg --print-architecture` | amd64/arm64 download URLs |
| `OS_CODENAME` | `/etc/os-release` | apt repo suite. Falls back to `noble` for vendors that haven't published a 26.04 suite yet, with a warning |

## 5. Install method per tool (prefer official sources)

| Tool | Method |
|---|---|
| Node | **fnm** → Node LTS. Corepack → pnpm. bun via its official script |
| Python | **uv** (astral installer) → `uv python install`. Global tools with `uv tool install` (ruff, jupyterlab optional) |
| Docker | Docker apt repo (docker-ce, buildx, compose plugin), add user to `docker` group |
| Go / Rust | go.dev tarball to `/usr/local/go`; rustup |
| NVIDIA | `ubuntu-drivers install` (not WSL); CUDA from NVIDIA's apt repo (network keyring); nvidia-container-toolkit repo |
| Ollama | official install script; systemd service |
| Claude Code | native installer (`claude.ai/install.sh`), updates itself |
| Codex, Gemini CLI | npm global (or standalone binaries where offered) |
| opencode | official install script |
| Hermes Agent | Nous Research's official install script |
| Cursor, Antigravity | official .deb / apt repo, desktop only |
| gh | GitHub CLI apt repo |
| cloudflared | Cloudflare apt repo |
| wrangler, vercel, railway, cf | npm global |
| supabase | GitHub release .deb (the npm global install isn't supported) |
| flyctl | official install script |
| Hugging Face | `uv tool install huggingface_hub[cli]` (`hf`) |
| AWS / gcloud / Azure | AWS v2 zip installer; Google Cloud apt repo; Microsoft apt repo |
| CLI basics | apt (`ripgrep fd-find bat eza fzf jq yq btop tmux zoxide direnv`) + symlinks `fdfind→fd`, `batcat→bat` |

**npm globals with fnm:** fnm keeps globals per Node version, so switching Node versions loses them. Fix: set `npm config set prefix ~/.local/npm-global` and add it to PATH through `rc_block`. Globals then survive Node upgrades.

## 6. Config modules (90-config)

- **git-identity**: prompts for name and email, sets `init.defaultBranch main`, `pull.rebase`, etc.
- **ssh-key**: `ssh-keygen -t ed25519` if no key exists. When `gh` is authenticated, runs `gh ssh-key add`.
- **ai-env**: creates `~/.config/ai-env/env` (chmod 600) with commented placeholders (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `HF_TOKEN`, `CLOUDFLARE_API_TOKEN`…) and sources it from the `rc_block`. Keys are never committed or logged.
- **logins**: walks through `gh auth login`, `wrangler login`, `claude` (first run), `codex login`, `hf auth login`, `vercel login`, `supabase login`, `fly auth login`, `gcloud auth login`, and the rest, but only for tools that are installed. Each login can be skipped and runs last.

## 7. Profiles

Plain text: one module id per line, `#` comments. They set which items start checked; detection can still hide modules that don't apply.
- `ai-desktop`: everything except big clouds
- `ai-server`: no desktop apps, no NVIDIA driver unless detected
- `minimal`: core + uv + node + claude-code + gh + cli-basics

## 8. Quality & testing

- `shellcheck` on everything, `set -Eeuo pipefail` in modules, and an `ERR` trap that logs the module, line, and command.
- `bats` tests for `registry.sh` (header parsing, toposort, `@when` evaluation) and `detect.sh` with mocked `/proc`.
- `tests/Dockerfile.ubuntu2604` runs `install.sh --yes --profile ai-server` in a container (GPU modules are skipped automatically).
- The full test runs in a Multipass/LXD VM, then again to confirm idempotency (the second run should only call `update`).
- GitHub Actions: shellcheck + bats + container run on each push.

## 9. Open items to confirm

- `npm install -g cf`: need to verify this is Cloudflare's package, since `cf` on npm may be an unrelated package. If it isn't Cloudflare's, wrangler already covers it.
- Hermes Agent: confirm that you mean Nous Research's `hermes-agent`.
- WSL + Docker: native Docker Engine inside WSL (default) or Docker Desktop integration?
- Repo name / GitHub owner for the bootstrap URL.
