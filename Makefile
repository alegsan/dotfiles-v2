DOTFILES_DIR := $(shell pwd)
ANSIBLE_DIR  := $(DOTFILES_DIR)/ansible
PLAYBOOK     := $(ANSIBLE_DIR)/playbooks/main.yml
PROFILE      ?= work

.PHONY: help install dotfiles lazyvim packages brew lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Full setup for PROFILE (default: work). Usage: make install PROFILE=private
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE)

dotfiles: ## Only symlink dotfiles
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags dotfiles

lazyvim: ## Only install neovim + LazyVim deps
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags lazyvim

brew: ## Only install Homebrew + brew packages
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags brew

packages: ## Only install apt packages
	ansible-playbook $(PLAYBOOK) -K -e profile=$(PROFILE) --tags packages

lint: ## Lint ansible playbooks
	ansible-lint $(PLAYBOOK)
