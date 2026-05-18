#!/usr/bin/env bash
# bootstrap.sh - Install git + ansible, clone dotfiles repo.
# Everything else is driven by ansible + chezmoi.
#
# One-liner usage:
#   curl -fsSL https://raw.githubusercontent.com/YOU/dotfiles-v2/main/bootstrap.sh | bash
#   curl -fsSL ... | bash -s -- --repo https://github.com/YOU/dotfiles-v2 --dir ~/.dotfiles

set -euo pipefail

# ─── Defaults ─────────────────────────────────────────────────────────────────
REPO_URL="${DOTFILES_REPO:-https://github.com/alegsan/dotfiles-v2.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# ─── Args ─────────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --repo) REPO_URL="$2"; shift 2 ;;
    --dir)  DOTFILES_DIR="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# ─── Helpers ──────────────────────────────────────────────────────────────────
log()  { echo -e "\033[1;32m[bootstrap]\033[0m $*"; }
warn() { echo -e "\033[1;33m[bootstrap]\033[0m $*"; }
die()  { echo -e "\033[1;31m[bootstrap]\033[0m $*" >&2; exit 1; }

[[ "$(id -u)" -eq 0 ]] && die "Do not run as root. Script uses sudo internally."

# ─── System prerequisites ─────────────────────────────────────────────────────
log "Updating package index..."
sudo apt-get update -qq

log "Installing git, curl, software-properties-common..."
sudo apt-get install -y -qq git curl software-properties-common

# ─── Ansible ──────────────────────────────────────────────────────────────────
if ! command -v ansible &>/dev/null; then
  log "Adding Ansible PPA and installing..."
  sudo add-apt-repository --yes --update ppa:ansible/ansible
  sudo apt-get install -y -qq ansible
else
  warn "ansible already installed: $(ansible --version | head -1)"
fi

# ─── Clone / update dotfiles repo ─────────────────────────────────────────────
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  warn "Repo exists at $DOTFILES_DIR — pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  log "Cloning $REPO_URL → $DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
log "Bootstrap done. Ansible + repo ready."
echo
echo "  Next steps:"
echo "  cd $DOTFILES_DIR"
echo
echo "  # Full setup (prompts for sudo password):"
echo "  ansible-playbook ansible/playbooks/main.yml -K -e profile=work"
echo "  ansible-playbook ansible/playbooks/main.yml -K -e profile=private"
echo
echo "  # Selective — only install lazyvim:"
echo "  ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags lazyvim"
echo
echo "  # Only apply dotfiles (no package installs):"
echo "  ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags dotfiles"
echo
