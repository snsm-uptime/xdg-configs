# dotfiles

Personal dotfiles managed by a modular Bash installer. Configs are **symlinked** from this repo into XDG-compliant locations — nothing is copied, so edits to live files are edits to the repo.

Machine-specific paths (git roots, SSH hosts, shell shortcuts) live in **`dotfiles.local.env`** at the repo root. See [`dotfiles.local.env.example`](dotfiles.local.env.example) for all supported keys.

---

## Table of contents

- [Requirements](#requirements)
- [Install](#install)
- [Use](#use)
- [Update](#update)
- [Uninstall](#uninstall)
- [Profiles and modules](#profiles-and-modules)
- [Local configuration](#local-configuration)
- [Install logs and troubleshooting](#install-logs-and-troubleshooting)
- [Adding a module](#adding-a-module)
- [Security](#security)

---

## Requirements

| Dependency | Minimum | Notes |
|------------|---------|-------|
| `bash` | 3.2+ | macOS ships 3.2; Linux distros ship 5.x |
| `git` | 2.13+ | Submodule support for nvim/LazyVim |
| `curl` | any | Used by `nvm`, `nvim`, and `cli` (eza fallback) |
| Homebrew | any | macOS only; skipped if missing |
| `apt-get` | any | Linux / WSL; used when available |
| `sudo` | — | Required for apt packages (`zsh`, `eza`, `libfuse2`, tmux deps) |

**Windows:** native PowerShell/cmd is **not supported**. Use **WSL** (treated as Linux).

Use a **Nerd Font** in your terminal for `eza --icons=always`.

---

## Install

### 1. Clone the repo

```bash
git clone --recurse-submodules https://github.com/sebastiansotom/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Always clone with `--recurse-submodules` so the nvim/LazyVim config is present.

### 2. Install system packages (Linux / WSL)

On a clean Ubuntu/Debian or WSL instance:

```bash
sudo apt update
sudo apt install -y git curl zsh
```

The installer can pull `eza`, `libfuse2`, `jq`, and `playerctl` via apt as well, but **sudo must be available** when `./install.sh` runs. In CI or non-interactive shells without passwordless sudo, run apt yourself first.

### 3. Run the installer

```bash
./install.sh
```

**First run** (interactive):

1. Prompts for machine paths → writes `dotfiles.local.env`
2. Generates `git/gitconfig-local` and `ssh/config.local`
3. Writes marker `~/.config/dotfiles/.setup-done` (outside the repo; never committed)
4. Runs all modules in profile order

**Subsequent runs** skip prompts when the marker exists. Re-run anytime to link new configs or install missing tools.

Preview without changes:

```bash
./install.sh --dry-run
```

### 4. Start a new shell

```bash
exec zsh -l
```

Or open a new terminal. This loads `~/.zshenv`, which sets `$ZDOTDIR`, `$XDG_*` paths, and sources `dotfiles.local.env`.

### macOS

```bash
# Install Homebrew first: https://brew.sh
git clone --recurse-submodules https://github.com/sebastiansotom/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh -l
```

### Install options

```text
./install.sh [OPTIONS]

  -p, --profile <name>     full | slim | minimal  (default: full)
  -m, --modules <list>     Comma-separated modules, e.g. git,zsh,tmux
  -n, --dry-run            Preview only; no changes
  -f, --force              Replace existing paths without .bak-* backups
      --skip-setup         Skip first-run prompts (use existing env)
      --setup-only         Regenerate git/ssh locals from dotfiles.local.env
      --non-interactive    Same as --skip-setup (for CI / scripts)
  -h, --help               Show help and profile list
```

**Examples:**

```bash
./install.sh --profile minimal
./install.sh --modules cli,zsh,fzf
./install.sh --non-interactive --profile full
./install.sh --setup-only          # after editing dotfiles.local.env
./install.sh --force --modules git # replace symlinks without backup
```

### Non-interactive / CI install

Copy or create env before installing:

```bash
cp dotfiles.local.env.example dotfiles.local.env
# edit dotfiles.local.env as needed
./install.sh --non-interactive --profile full
```

---

## Use

### Daily workflow

| Task | Command |
|------|---------|
| Edit a tracked config | Open the file under `~/.dotfiles/…` or follow the symlink target |
| Reload shell config | `omz reload` (after Oh My Zsh is installed) |
| Edit aliases | `ealias` (opens `zsh/alias.zsh`) |
| Edit git config | `egit`, `egitp`, `egitu` |
| List files with icons | `ls`, `ll`, `lt` (eza aliases) |
| Fuzzy find | `Ctrl-T` / `Ctrl-R` (after fzf module) |

Configs live in the repo; symlinks point from `$HOME` and `$XDG_CONFIG_HOME` into `~/.dotfiles`.

### Change machine-specific paths

1. Edit `~/.dotfiles/dotfiles.local.env`
2. Regenerate derived files:

   ```bash
   ./install.sh --setup-only
   ```

3. Reload shell: `exec zsh -l`

### Install or refresh a single module

```bash
./install.sh --modules zsh
./install.sh --modules cli,fzf --skip-setup
```

### Tmux plugins

After the `tmux` module installs TPM, start tmux and press **`Prefix + I`** to fetch plugins.

### Node versions (nvm)

nvm installs to `$XDG_CONFIG_HOME/nvm` and is loaded from `~/.zshenv`:

```bash
nvm install --lts
nvm use --lts
```

---

## Update

Pull latest dotfiles and re-run the installer:

```bash
cd ~/.dotfiles
./update.sh
```

`update.sh` does the following:

1. `git pull --ff-only`
2. GPG check on `HEAD` — aborts on bad signature (`B`); warns on unsigned/unknown (`N`, `E`, `U`)
3. `git submodule update --init --recursive`
4. Re-runs `./install.sh` with any forwarded arguments

**Examples:**

```bash
./update.sh                      # full profile
./update.sh --profile slim
./update.sh --modules git,zsh
./update.sh --dry-run
```

Existing symlinks that already point to the correct target are skipped. New or changed modules are applied automatically.

---

## Uninstall

The installer does **not** remove your data by default. Use one of the methods below.

### Option A — Per-run revert script (recommended after install)

Each install writes a manifest and revert script under `~/.config/dotfiles/install-logs/`:

```bash
# Paths are printed at install time, e.g.:
bash ~/.config/dotfiles/install-logs/revert-20260529-171000.sh
```

The revert script removes symlinks, binaries, and cloned directories recorded during **that run**. Review it before executing.

### Option B — Manual removal

**Symlinks** — remove links created by the installer (they point into `~/.dotfiles`):

```bash
rm -f ~/.zshenv ~/.ssh/config
rm -f ~/.config/git/{config,ignore,gitconfig-local,gitconfig-personal,gitconfig-uptime}
rm -f ~/.config/{gh/config.yml,npm/npmrc,tmux/tmux.conf,docker/config.json,fzf/theme.sh}
rm -f ~/.config/zsh/{.zshrc,.zprofile,.p10k.zsh,alias.zsh}
rm -f ~/.config/nvim
```

**Binaries** (user-local, no sudo):

```bash
rm -f ~/.local/bin/{eza,nvim}
```

**Cloned tools:**

```bash
rm -rf ~/.local/share/{fzf,zsh/oh-my-zsh,tmux/plugins}
rm -rf ~/.config/nvm
```

**Generated local config** (gitignored):

```bash
rm -f ~/.dotfiles/{dotfiles.local.env,git/gitconfig-local,ssh/config.local}
rm -f ~/.config/dotfiles/.setup-done
```

**Repo** — optional; only if you want to remove dotfiles entirely:

```bash
rm -rf ~/.dotfiles
```

### Backups

When a symlink target already existed, the installer backs it up as `<path>.bak-YYYYMMDDHHMMSS` (up to three kept per path). Restore manually:

```bash
mv ~/.zshrc.bak-20260529170900 ~/.zshrc   # example
```

`--force` skips backups and overwrites in place.

---

## Profiles and modules

### Profiles

| Profile | Modules | Best for |
|---------|---------|----------|
| `full` | git, ssh, gh, cli, fzf, nvm, nvim, npm, zsh, tmux, docker | Primary workstation |
| `slim` | ssh, gh, cli, fzf, zsh, tmux, git | Servers without Docker/nvim |
| `minimal` | git, cli, fzf, zsh, tmux | Working shell without nvim/nvm/docker |

Module order is fixed in `profiles/*.txt` so shell configs are linked **after** `cli` (zsh, eza) and `fzf`.

### Modules

| Module | What it does |
|--------|----------------|
| `git` | Symlinks `config`, `ignore`, identity includes; `gitconfig-local` from env |
| `ssh` | Symlinks `config` + generated `config.local`; sets `~/.ssh` permissions |
| `gh` | Symlinks `config.yml` (no tokens) |
| `cli` | Installs `zsh` and `eza` (apt/brew or GitHub binary); runs `chsh` (warns on failure) |
| `fzf` | Clones fzf to `$XDG_DATA_HOME/fzf`; links Tokyo Night theme |
| `nvm` | Installs nvm into `$XDG_CONFIG_HOME/nvm` |
| `nvim` | LazyVim submodule; Linux AppImage with GitHub digest verify; `libfuse2` on WSL |
| `npm` | Symlinks XDG `npmrc` |
| `zsh` | `.zshenv`, `.zshrc`, `.zprofile`, p10k; Oh My Zsh + Powerlevel10k |
| `tmux` | `tmux.conf`, TPM, optional theme dependencies |
| `docker` | `config.json` template (`credsStore` empty) |

---

## Local configuration

| File | Tracked? | Purpose |
|------|----------|---------|
| `dotfiles.local.env.example` | Yes | Documented keys and defaults |
| `dotfiles.local.env` | No | Your machine paths and SSH settings |
| `git/gitconfig-local` | No | Generated `includeIf` blocks |
| `ssh/config.local` | No | Generated SSH host entries |
| `~/.config/dotfiles/.setup-done` | No (outside repo) | Skips interactive setup on later installs |

### Environment variables

Defined in `dotfiles.local.env` and sourced by install scripts and `~/.zshenv`:

| Variable | Description |
|----------|-------------|
| `DOTFILES_GITHUB_ROOT` | Base path for `cdgh` / `cdpr` / `cdup` and git `includeIf` (`…/personal`, `…/uptime`) |
| `DOTFILES_SSH_SERVER_IP` | Server IP for SSH aliases |
| `DOTFILES_SSH_KEY_KVM` | SSH private key path |
| `DOTFILES_EDITOR_HOSTNAME` | Optional hostname for `EDITOR=nvim` |

---

## Install logs and troubleshooting

Every install (except `--dry-run`) writes logs to:

```text
~/.config/dotfiles/install-logs/
├── manifest-<timestamp>.tsv   # actions recorded (symlinks, files, dirs)
├── revert-<timestamp>.sh      # auto-generated rollback for that run
└── errors-<timestamp>.log     # failed modules (if any)
```

If a module fails, the installer **continues** with remaining modules and reports failures at the end.

### Common issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `sudo: a password is required` | Non-interactive install without sudo | Run `sudo apt install …` manually, then re-run `./install.sh` |
| `zsh: command not found` after install | `zsh` not installed | `sudo apt install zsh` then `exec zsh -l` |
| nvim AppImage won't run on WSL | Missing FUSE | `sudo apt install libfuse2` |
| `eza: command not found` in current shell | PATH not loaded | `source ~/.zshenv` or open a new login shell |
| First-run prompts every time | Missing setup marker | Run `./install.sh` without `--skip-setup` once |

---

## Adding a module

1. Create a directory and configs:

   ```bash
   mkdir -p ~/.dotfiles/myapp
   ```

2. Add `myapp/install.sh` using `link` and `pkg_install` from `lib/`:

   ```bash
   # myapp/install.sh
   link "$DOTFILES/myapp/config" "$XDG_CONFIG_HOME/myapp/config"
   ```

3. Add `myapp` to `profiles/full.txt` in the correct order.

4. Test and apply:

   ```bash
   ./install.sh --modules myapp --dry-run
   ./install.sh --modules myapp
   ```

---

## Security

- **No credentials in the repo.** Keys, `gh/hosts.yml`, `dotfiles.local.env`, and generated locals are gitignored.
- **Docker:** install aborts if tracked `config.json` contains an `"auth"` key.
- **nvim:** AppImage SHA-256 verified via the GitHub release API before install.
- **Oh My Zsh:** cloned with `git`, not `curl | sh`.
- **GPG on update:** `update.sh` aborts only on a bad signature (`B`); unsigned commits warn but continue.
