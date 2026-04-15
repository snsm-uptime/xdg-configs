# dotfiles

Personal dotfiles managed by a modular Bash installer. Configs are symlinked from this repo into their XDG-compliant locations — nothing is copied, so edits to the live files are edits to the repo.

---

## Requirements

| Dependency | Minimum version | Notes |
|------------|----------------|-------|
| `bash`     | 3.2+           | Ships with macOS; Linux distros ship 5.x |
| `git`      | 2.13+          | Required for XDG-aware `git config` and submodule support |
| `curl`     | any            | Used only for the `nvm` module |
| Homebrew   | any            | macOS only; skipped if not present |
| `apt-get`  | any            | Linux only; skipped if not present |

---

## Getting started

```bash
# 1. Clone (with submodules — nvim config lives in one)
git clone --recurse-submodules https://github.com/sebastiansotom/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Install everything (full profile)
./install.sh

# 3. Reload your shell
source ~/.zshenv
```

> **New shell, new session.** After install, open a new terminal tab or run `exec zsh` — the new `$ZDOTDIR` path won't take effect until the shell re-reads `~/.zshenv`.

---

## Profiles

Profiles are plain text files in `profiles/`. Each line is a module name. Comments (`#`) and blank lines are ignored.

| Profile   | Modules included                              | Best for |
|-----------|-----------------------------------------------|----------|
| `full`    | git, tmux, zsh, nvim, nvm, ssh, docker, gh    | Primary workstation |
| `slim`    | git, tmux, zsh, ssh, gh                       | Servers without Docker/nvim |
| `minimal` | git, tmux                                     | Ephemeral containers, CI |

```bash
./install.sh --profile slim
./install.sh --profile minimal
```

---

## Modules

| Module   | What it installs / configures | Target path |
|----------|-------------------------------|-------------|
| `git`    | `config`, `ignore`, identity includes | `$XDG_CONFIG_HOME/git/` |
| `zsh`    | `.zshenv`, `.zshrc`, `.zprofile`, `.p10k.zsh`, `alias.zsh`; installs Oh My Zsh + Powerlevel10k | `$HOME/.zshenv`, `$XDG_CONFIG_HOME/zsh/` |
| `tmux`   | `tmux.conf`; installs TPM (Tmux Plugin Manager) | `$XDG_CONFIG_HOME/tmux/` |
| `nvim`   | `config/` directory (LazyVim starter, git submodule); installs `nvim` binary if missing | `$XDG_CONFIG_HOME/nvim` |
| `ssh`    | `config`; sets `~/.ssh` to `700`, config to `600` | `$HOME/.ssh/config` |
| `docker` | `config.json` (credential store config only — never auth tokens) | `$XDG_CONFIG_HOME/docker/config.json` |
| `gh`     | `config.yml` (GitHub CLI preferences, no tokens) | `$XDG_CONFIG_HOME/gh/config.yml` |
| `nvm`    | nvm into `$XDG_DATA_HOME/nvm` via its install script | `$XDG_DATA_HOME/nvm/` |

### XDG directory layout

```
$HOME/
├── .zshenv                          ← sets ZDOTDIR, sourced first by zsh
├── .ssh/
│   └── config → dotfiles/ssh/config
└── .config/                         ← $XDG_CONFIG_HOME
    ├── git/
    │   ├── config → dotfiles/git/config
    │   ├── ignore → dotfiles/git/ignore
    │   ├── gitconfig-personal → dotfiles/git/gitconfig-personal
    │   └── gitconfig-uptime   → dotfiles/git/gitconfig-uptime
    ├── zsh/
    │   ├── .zshrc   → dotfiles/zsh/.zshrc
    │   ├── .zprofile → dotfiles/zsh/.zprofile
    │   ├── .p10k.zsh → dotfiles/zsh/.p10k.zsh
    │   └── alias.zsh → dotfiles/zsh/alias.zsh
    ├── tmux/
    │   └── tmux.conf → dotfiles/tmux/tmux.conf
    ├── nvim/  → dotfiles/nvim/config  (git submodule: LazyVim/starter)
    ├── docker/
    │   └── config.json → dotfiles/docker/config.json
    └── gh/
        └── config.yml → dotfiles/gh/config.yml
```

---

## Usage

```
./install.sh [OPTIONS]

Options:
  -p, --profile <name>   Profile to install: full | slim | minimal  (default: full)
  -m, --modules <list>   Comma-separated list of specific modules
  -n, --dry-run          Print what would happen without making any changes
  -f, --force            Replace existing symlinks without prompting
  -h, --help             Show help and list available profiles
```

### Examples

```bash
# Preview what full install would do — no changes made
./install.sh --dry-run

# Install only git and tmux
./install.sh --modules git,tmux

# Force-replace existing symlinks (useful after a path change)
./install.sh --force

# Dry-run a specific profile
./install.sh --profile slim --dry-run
```

---

## Updating

```bash
./update.sh
```

`update.sh` does two things in order:

1. `git pull --ff-only` — fast-forward only, never creates a merge commit
2. Re-runs `./install.sh` with any arguments you pass through

```bash
# Update and re-link only the zsh module
./update.sh --modules zsh

# Update with dry-run to preview re-link changes
./update.sh --dry-run
```

> **GPG note.** If commits in this repo are GPG-signed, `update.sh` will verify the signature after pulling. A bad or tampered signature causes an immediate abort. Unsigned commits produce a warning but proceed.

---

## Uninstalling

There is no automated uninstall script. Symlinks are cheap to remove manually.

### Remove a single module

```bash
# Example: remove tmux config
rm ~/.config/tmux/tmux.conf

# Restore the backup if you want the original file back
mv ~/.config/tmux/tmux.conf.bak-<timestamp> ~/.config/tmux/tmux.conf
```

### Remove all symlinks at once

```bash
# Find every symlink inside $XDG_CONFIG_HOME that points into this repo
grep -rl "$(pwd)" ~/.config --include="*" | xargs -I{} sh -c '[ -L "{}" ] && rm "{}"'
```

### Remove installed tools (optional)

| Tool | Command |
|------|---------|
| Oh My Zsh | `rm -rf "$XDG_DATA_HOME/zsh/oh-my-zsh"` |
| Powerlevel10k | `rm -rf "$XDG_DATA_HOME/zsh/oh-my-zsh/custom/themes/powerlevel10k"` |
| TPM | `rm -rf "$XDG_DATA_HOME/tmux/plugins"` |
| nvm | `rm -rf "$XDG_DATA_HOME/nvm"` |
| nvim (AppImage) | `rm ~/.local/bin/nvim` |

---

## Adding a new module

1. Create the module directory and drop your config files in:

   ```bash
   mkdir dotfiles/myapp
   cp ~/.config/myapp/config dotfiles/myapp/config
   ```

2. Create `dotfiles/myapp/install.sh`:

   ```bash
   #!/usr/bin/env bash
   # myapp/install.sh

   mkdir -p "$XDG_CONFIG_HOME/myapp"
   link "$DOTFILES/myapp/config" "$XDG_CONFIG_HOME/myapp/config"
   ```

3. Add the module to the profiles you want it in:

   ```bash
   echo "myapp" >> profiles/full.txt
   ```

4. Install and verify:

   ```bash
   ./install.sh --modules myapp --dry-run   # preview
   ./install.sh --modules myapp             # apply
   ```

### Module authoring reference

| Helper | Signature | Description |
|--------|-----------|-------------|
| `link` | `link <src> <tgt>` | Symlinks `src` → `tgt`; backs up any existing file to `<tgt>.bak-YYYYMMDDHHMMSS` (keeps 3 most recent) |
| `pkg_install` | `pkg_install <pkg> [version]` | Installs via `brew` on macOS, `apt-get` on Linux; version is optional |
| `brew_install` | `brew_install <pkg> [version]` | macOS only; resolves to `brew install pkg@version` when version is set |
| `apt_install` | `apt_install <pkg> [version]` | Linux only; resolves to `apt-get install -y pkg=version` when version is set |
| `is_macos` | `is_macos && ...` | Returns 0 on macOS |
| `is_linux` | `is_linux && ...` | Returns 0 on Linux |
| `has` | `has <cmd>` | Returns 0 if `<cmd>` is on `$PATH` |
| `log_ok` | `log_ok "msg"` | Green checkmark line |
| `log_warn` | `log_warn "msg"` | Yellow warning line |
| `log_error` | `log_error "msg"` | Red error line (goes to stderr) |
| `log_info` | `log_info "msg"` | Dimmed info line |
| `log_skip` | `log_skip "msg"` | Dimmed skip line |
| `log_dry` | `log_dry "msg"` | Yellow dry-run line |

Environment variables available in every module script:

| Variable | Value |
|----------|-------|
| `$DOTFILES` | Absolute path to the repo root |
| `$DRY_RUN` | `true` or `false` |
| `$FORCE` | `true` or `false` |
| `$XDG_CONFIG_HOME` | `~/.config` (unless overridden) |
| `$XDG_DATA_HOME` | `~/.local/share` (unless overridden) |
| `$XDG_CACHE_HOME` | `~/.cache` (unless overridden) |
| `$XDG_STATE_HOME` | `~/.local/state` (unless overridden) |
| `$OS` | `macos` or `linux` |
| `$ARCH` | `x86_64` or `arm64` |

---

## Security notes

- **No credentials in the repo.** `ssh/id_*`, `ssh/*.pem`, `ssh/*.key`, and `gh/hosts.yml` (OAuth tokens) are gitignored.
- **Docker config guard.** The `docker` module hard-aborts if `config.json` contains an `"auth"` key (embedded base64 credentials). Use a credential store (`credStore`) instead.
- **Checksum verification.** The `nvim` module verifies the AppImage SHA-256 against the release checksum before writing the binary to `$PATH`.
- **No `curl | sh`.** Oh My Zsh is cloned directly via `git` rather than piped through a shell.
- **Backup rotation.** Each re-link keeps the 3 most recent `.bak-*` files per target and prunes the rest.
