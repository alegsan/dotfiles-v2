#!/usr/bin/env bash
# bootstrap.sh - Install git + ansible, clone dotfiles repo.
# Everything else is driven by ansible.
#
# One-liner usage:
#   curl -fsSL https://raw.githubusercontent.com/alegsan/dotfiles-v2/feature/chezmoi-ansible/bootstrap.sh | bash
#   curl -fsSL ... | bash -s -- --repo https://github.com/alegsan/dotfiles-v2 --dir ~/.dotfiles
#
# Options:
#   -v, --verbose   print full command output + example next steps
#   --repo URL      dotfiles repo URL (default: $DOTFILES_REPO or the repo below)
#   --dir DIR       install dir (default: $DOTFILES_DIR or ~/.dotfiles)

set -euo pipefail

# ─── Defaults ─────────────────────────────────────────────────────────────────
REPO_URL="${DOTFILES_REPO:-https://github.com/alegsan/dotfiles-v2.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
VERBOSE=0

# ─── Args ──────────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--verbose) VERBOSE=1; shift ;;
    --repo) REPO_URL="$2"; shift 2 ;;
    --dir)  DOTFILES_DIR="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ─── Helpers ───────────────────────────────────────────────────────────────────
log()  { echo -e "\033[1;32m[bootstrap]\033[0m $*"; }
warn() { echo -e "\033[1;33m[bootstrap]\033[0m $*"; }
die()  { echo -e "\033[1;31m[bootstrap]\033[0m $*" >&2; exit 1; }

# Quiet by default; show stdout/stderr only in verbose mode, but always
# surface output on failure.
run() {
  if [[ $VERBOSE -eq 1 ]]; then "$@"; return $?; fi
  local out
  out=$("$@" 2>&1) || { printf '%s\n' "$out" >&2; return 1; }
}

[[ "$(id -u)" -eq 0 ]] && die "Do not run as root. Script uses sudo internally."

# ─── System prerequisites ─────────────────────────────────────────────────────
log "Updating package index..."
run sudo apt-get update -qq

log "Installing git, curl, software-properties-common..."
run sudo apt-get install -y -qq git curl software-properties-common

# ─── Ansible ───────────────────────────────────────────────────────────────────
if ! command -v ansible &>/dev/null; then
  log "Installing Ansible..."
  run sudo add-apt-repository --yes --update ppa:ansible/ansible
  run sudo apt-get install -y -qq ansible
else
  warn "ansible already installed: $(ansible --version | head -1)"
fi

# ─── Clone / update dotfiles repo ─────────────────────────────────────────────
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  warn "Pulling latest into $DOTFILES_DIR..."
  run git -C "$DOTFILES_DIR" pull --ff-only
else
  log "Cloning $REPO_URL → $DOTFILES_DIR"
  run git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# ─── Ansible collections ───────────────────────────────────────────────────────
log "Installing Ansible collections (community.general)..."
run ansible-galaxy collection install -r "$DOTFILES_DIR/ansible/requirements.yml"

# ─── Done ─────────────────────────────────────────────────────────────────────
log "Bootstrap done. Ansible + repo ready."
log "Next: cd $DOTFILES_DIR && make install PROFILE=work"
if [[ $VERBOSE -eq 1 ]]; then
  echo
  echo "  cd $DOTFILES_DIR"
  echo "  make install PROFILE=work      # or PROFILE=private"
  echo "  make dotfiles PROFILE=work     # symlink dotfiles only"
  echo "  make lazyvim  PROFILE=work     # neovim + LazyVim deps only"
  echo "  make brew     PROFILE=work     # Homebrew + packages only"
  echo "  make packages PROFILE=work     # apt packages only"
fi