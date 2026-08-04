export PATH := $(HOME)/.local/bin:$(PATH)

DOTFILES_DIR := $(shell pwd)
ANSIBLE_DIR  := $(DOTFILES_DIR)/ansible
PLAYBOOK     := $(ANSIBLE_DIR)/playbooks/main.yml
PROFILE      ?= work

.PHONY: help install dotfiles zsh lazyvim packages brew gnome_terminal lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Full setup for PROFILE (default: work). Usage: make install PROFILE=private
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE)

dotfiles: ## Only symlink dotfiles. Usage: make dotfiles PROFILE=private
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags dotfiles

lazyvim: ## Only install neovim + LazyVim deps
	ansible-playbook $(PLAYBOOK) -K --tags lazyvim

brew: ## Only install Homebrew + brew packages
	ansible-playbook $(PLAYBOOK) -K --tags brew

packages: ## Only install apt packages. Usage: make packages PROFILE=private
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags packages

zsh: ## Only install zsh + oh-my-zsh. Usage: make zsh PROFILE=private
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags zsh

gnome_terminal: ## Install and configure GNOME Terminal
	ansible-playbook $(PLAYBOOK) -K --tags gnome_terminal

lint: ## Lint ansible playbooks
	@command -v ansible-lint >/dev/null 2>&1 || \
		{ echo "\033[1;31m[error]\033[0m ansible-lint not found. Run 'make packages PROFILE=work' or 'make packages PROFILE=private' first."; exit 1; }
	ansible-lint $(PLAYBOOK)
