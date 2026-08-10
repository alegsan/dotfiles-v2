export PATH := $(HOME)/.local/bin:$(PATH)

DOTFILES_DIR := $(shell pwd)
ANSIBLE_DIR  := $(DOTFILES_DIR)/ansible
PLAYBOOK     := $(ANSIBLE_DIR)/playbooks/main.yml
PROFILE      ?= work

.PHONY: help install dotfiles zsh lazyvim packages brew gnome_terminal gnome lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Full setup for PROFILE (default: work). Usage: make install PROFILE=private
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE)

dotfiles: ## Only symlink dotfiles. Usage: make dotfiles PROFILE=private
	# depends on: zsh (for ~/.zshrc symlink)
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common,brew,zsh,dotfiles

lazyvim: ## Only install neovim + LazyVim deps
	# depends on: brew → common
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common,brew,lazyvim

brew: ## Only install Homebrew + brew packages
	# depends on: common
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common,brew

packages: ## Only install apt packages. Usage: make packages PROFILE=private
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common

zsh: ## Only install zsh + oh-my-zsh + starship. Usage: make zsh PROFILE=private
	# depends on: brew → common
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common,brew,zsh

tools: ## Install general CLI tools (gh, lynx, ...). Usage: make tools PROFILE=work
	# depends on: brew → common
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common,brew,tools

gnome_terminal: ## Install and configure GNOME Terminal
	# depends on: brew → common
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common,brew,gnome_terminal

lint: ## Lint ansible playbooks
	@command -v ansible-lint >/dev/null 2>&1 || \
		{ echo "\033[1;31m[error]\033[0m ansible-lint not found. Run 'pipx install ansible-lint' first."; exit 1; }
	ANSIBLE_COLLECTIONS_PATH=/usr/lib/python3/dist-packages ansible-lint $(PLAYBOOK)


gnome: ## Configure GNOME desktop (dock, workspaces, theme, wallpaper)
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags common,gnome
