#!/usr/bin/env bash
# deploy.sh — install these dotfiles into $HOME, backing up originals first
# Usage: ./deploy.sh [--dry-run]
#   --dry-run   print what would be linked/installed; touch nothing on disk
#
# What it does: symlinks every entry of the FILES map (repo path → $HOME
# path) so edits in the repo apply live. Existing real files/dirs at a
# target are first copied to ~/.dotfiles-backup/<timestamp>/ (symlinks that
# already point into this repo are replaced without a backup — that is the
# idempotent re-run case). Then install_shinbun clones the optional shinbun
# news reader at the pinned commit below and links it into ~/.local/bin.
#
# What it deliberately does NOT do: no sudo, no apt, no system files —
# everything stays under $HOME. Installing packages is your job (the README
# has the apt line). It also does not run theme-set: run `theme-set dragon`
# once after installing to generate the theme fragments.
#
# To reverse: delete the symlinks it created — `find ~ -lname "$PWD/*"`
# lists them — and copy back anything you want from
# ~/.dotfiles-backup/<timestamp>/.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "run as your user, not root — nothing here needs root"
  exit 1
fi

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "unknown arg: $1 (use --dry-run)"; exit 1 ;;
  esac
done

# shinbun (github.com/v0idravl/shinbun) pinned commit. To bump: check the
# repo's log, verify the commit, update SHINBUN_REF. The clone is checked out
# detached at exactly this ref — an upstream force-push can't move us.
SHINBUN_REPO="https://github.com/v0idravl/shinbun.git"
SHINBUN_REF="07c5c448f7b9655175a7c60fed3a3fb51787ea21"

# ── Mapping: repo path → target path ────────────────────────────
# .zshrc/.tmux.conf plus every top-level dir under .config/ and every file
# under .local/bin/ (and .local/share/, if the repo ever grows assets
# there) — enumerated with find, so the map can never drift from what the
# repo actually ships. .config entries are linked as whole directories:
# theme-set writes its GENERATED fragments (theme.conf, theme.css, …) into
# the same dirs, and .gitignore already excludes them — linking the dir is
# what makes `theme-set dragon` work right after install.
declare -A FILES=(
  [".zshrc"]="$HOME/.zshrc"
  [".tmux.conf"]="$HOME/.tmux.conf"
)
while IFS= read -r d; do
  FILES["$d"]="$HOME/$d"
done < <(cd "$DOTFILES" && find .config -mindepth 1 -maxdepth 1 -type d | sort)
while IFS= read -r f; do
  FILES["$f"]="$HOME/$f"
done < <(cd "$DOTFILES" && find .local/bin -type f | sort)
share_dir="$DOTFILES/.local/share"
if [[ -d "$share_dir" ]]; then
  while IFS= read -r f; do
    FILES["$f"]="$HOME/$f"
  done < <(cd "$DOTFILES" && find .local/share -type f | sort)
fi

# ── Helpers ──────────────────────────────────────────────────────
log() { echo "  $*"; }
die() { echo "deploy.sh: $*" >&2; exit 1; }

backup() {
  local target="$1"
  local rel="${target#"$HOME"/}"
  local dest="$BACKUP_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  cp -a "$target" "$dest"
  log "backed up: ~/$rel → $BACKUP_DIR/$rel"
}

link() {
  local src="$DOTFILES/$1"
  local dst="$2"
  # dry-run must be pure: no mkdir, no backup, nothing on disk
  if $DRY_RUN; then
    log "[dry-run] would link: $dst → $src"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" ]]; then
    # replace symlinks without a backup only when they are OURS (point into
    # this repo — the idempotent re-run case); a symlink pointing anywhere
    # else belongs to somebody, back it up like a real file
    case "$(readlink "$dst")" in
      "$DOTFILES"/*) ;;
      *) backup "$dst" ;;
    esac
    rm -f "$dst"
  elif [[ -e "$dst" ]]; then
    # real file or directory (a .config target may be either): back it up
    # first, then remove — the original is always recoverable
    backup "$dst"
    rm -rf "$dst"
  fi
  ln -s "$src" "$dst"
  log "linked: $dst"
}

# ── shinbun (optional, network) ─────────────────────────────────
# Single-file Python stdlib world-news-over-Tor reader. Not shipped in this
# repo (it is its own project), so it is installed as a PINNED detached
# clone at ~/.local/lib/shinbun with a symlink in ~/.local/bin — the
# SHINBUN_REF commit above is the attestation, never a moving branch.
install_shinbun() {
  local dest="$HOME/.local/lib/shinbun"
  local bin="$HOME/.local/bin/shinbun"
  if $DRY_RUN; then
    log "[dry-run] would install shinbun: clone $SHINBUN_REPO @ $SHINBUN_REF"
    log "[dry-run]   → $dest (detached), link shinbun.py → $bin"
    return
  fi
  if [[ "$SHINBUN_REF" == "__PIN_ME__" ]]; then
    die "SHINBUN_REF is still the __PIN_ME__ placeholder — pin a verified commit at the top of deploy.sh"
  fi
  # shinbun.py runs under python3 and the clone is managed with git; both
  # are hard requirements, but their absence must not fail the dotfiles
  # install — shinbun is optional
  command -v git >/dev/null     || { log "SKIP shinbun: git not installed"; return; }
  command -v python3 >/dev/null || { log "SKIP shinbun: python3 not installed"; return; }

  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" fetch --quiet origin
    if [[ "$(git -C "$dest" rev-parse HEAD)" == "$(git -C "$dest" rev-parse "$SHINBUN_REF^{commit}")" ]]; then
      log "shinbun already at pinned ref $SHINBUN_REF — skipping clone"
    else
      git -C "$dest" checkout --quiet --detach "$SHINBUN_REF"
      log "shinbun: moved existing clone to pinned ref $SHINBUN_REF (detached)"
    fi
  else
    [[ -e "$dest" ]] && die "$dest exists but is not a git clone — move it aside first"
    mkdir -p "$(dirname "$dest")"
    git clone --quiet "$SHINBUN_REPO" "$dest"
    git -C "$dest" checkout --quiet --detach "$SHINBUN_REF"
    log "shinbun: cloned $SHINBUN_REPO at $SHINBUN_REF → $dest"
  fi

  chmod +x "$dest/shinbun.py"
  mkdir -p "$(dirname "$bin")"
  [[ -e "$bin" && ! -L "$bin" ]] && backup "$bin"
  ln -sf "$dest/shinbun.py" "$bin"
  log "linked: $bin → $dest/shinbun.py"
}

# ── Link everything ──────────────────────────────────────────────
echo ""
while IFS= read -r repo_path; do
  link "$repo_path" "${FILES[$repo_path]}"
done < <(printf '%s\n' "${!FILES[@]}" | sort)

install_shinbun

echo ""
if $DRY_RUN; then
  log "dry-run only — nothing was touched"
else
  log "done — run 'theme-set dragon' once to generate the theme fragments"
fi
