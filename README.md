# dotfiles-v2

Personal system configuration — bootstraps Ubuntu machines from scratch.
**Ansible** manages system packages and tools. **chezmoi** manages dotfiles.

## Quick start (fresh machine)

```bash
curl -fsSL https://raw.githubusercontent.com/alegsan/dotfiles-v2/feature/chezmoi-ansible/bootstrap.sh | bash
cd ~/.dotfiles
ansible-playbook ansible/playbooks/main.yml -K -e profile=work   # or profile=private
```

## Selective installs

```bash
# Only neovim + lazyvim
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags lazyvim

# Only base packages
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags packages

# Only apply dotfiles
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags dotfiles
```

Or via Make:
```bash
make install PROFILE=work
make lazyvim PROFILE=work
make dotfiles PROFILE=work
```

## Structure

```
bootstrap.sh                    # Install git + ansible, clone repo
Makefile                        # Convenience targets
ansible/
  ansible.cfg
  inventory/
    hosts.yml                   # localhost only
    group_vars/
      all.yml                   # shared vars
      work.yml                  # company-specific packages/vars
      private.yml               # personal packages/vars
  playbooks/
    main.yml                    # master playbook
  roles/
    common/                     # base packages, zsh
    neovim/                     # neovim AppImage install
    chezmoi/                    # chezmoi install + apply
    work/                       # work-only tasks
    private/                    # private-only tasks
home/                           # chezmoi source directory
  .chezmoi.toml.tmpl            # prompts for profile/name/email on first run
  .chezmoiignore                # per-profile file exclusions
  dot_gitconfig.tmpl
  dot_zshrc.tmpl
  dot_config/nvim/
    init.lua                    # LazyVim bootstrap
    lua/plugins/
      init.lua                  # custom plugins entry
      ui.lua                    # UI/colorscheme overrides
      lsp.lua                   # LSP overrides
```

## Adding a new dotfile

```bash
# From any machine with chezmoi initialized:
chezmoi add ~/.config/some/file
chezmoi edit ~/.config/some/file
chezmoi re-add ~/.config/some/file   # sync changes back to source
```
