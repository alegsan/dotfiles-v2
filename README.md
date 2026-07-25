# dotfiles-v2

Personal system configuration — bootstraps Ubuntu machines from scratch.
**Ansible** manages system state (packages, binaries, `/etc` files, user identity).
**Dotfiles** are plain files symlinked into `$HOME` by Ansible.

## Quick start (fresh machine)

```bash
curl -fsSL https://raw.githubusercontent.com/alegsan/dotfiles-v2/feature/chezmoi-ansible/bootstrap.sh | bash
cd ~/.dotfiles
ansible-playbook ansible/playbooks/main.yml -K -e profile=work   # or profile=private
```

`bootstrap.sh` is quiet by default — add `-v` for full command output and example next steps.
Options: `-v/--verbose`, `--repo URL`, `--dir DIR`.

On first run Ansible will prompt for your **name** and **email** (used for
`~/.gitconfig.local`). These are saved to `/etc/ansible/facts.d/user.fact` and
never prompted again.

## Selective runs

```bash
# Only base packages (apt)
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags packages

# Only Homebrew + brew packages
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags brew

# Only neovim + LazyVim deps
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags lazyvim

# Only symlink dotfiles (fast, no sudo needed except facts file)
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags dotfiles

# Only work-specific tasks
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags work
```

Or via Make:

```bash
make install  PROFILE=work
make dotfiles PROFILE=work
make lazyvim  PROFILE=work
make brew     PROFILE=work
make packages PROFILE=work
```

## Structure

```
bootstrap.sh                      # Install git + ansible, clone repo, install collections
Makefile                          # Convenience targets
.ansible-lint                     # ansible-lint config
ansible.cfg                       # localhost inventory + sudo become
ansible/
  inventory/
    hosts.yml                     # localhost only
    group_vars/
      all.yml                     # shared vars (repo_dir, dotfiles_dir, packages)
      work.yml                    # work packages + user_name/user_email
      private.yml                 # private packages + user_name/user_email
  playbooks/
    main.yml                      # master playbook
  requirements.yml                # ansible-galaxy collections (community.general)
  roles/
    common/                       # apt packages, zsh, ~/.local/bin
    brew/                         # Linuxbrew + brew packages/casks
    neovim/                       # neovim nightly via asdf, luarocks, node provider
    dotfiles/                     # symlink dotfiles, write *.local files
    work/                         # work-only tasks (/etc files, docker group, etc.)
    private/                      # private-only tasks
dotfiles/
  zshrc                           # → ~/.zshrc
  gitconfig                       # → ~/.gitconfig (includes ~/.gitconfig.local)
  config/
    nvim/                         # → ~/.config/nvim
  work/
    config/                       # → ~/.config/<dir> (work profile only)
  private/
    config/                       # → ~/.config/<dir> (private profile only)
```

## How dotfiles work

All files under `dotfiles/` are **symlinked** into `$HOME` by the `dotfiles`
Ansible role — no copying, no templating engine.

- **Common** (`dotfiles/config/`, `dotfiles/zshrc`, `dotfiles/gitconfig`) →
  symlinked on every machine.
- **Profile-specific** (`dotfiles/work/config/*`, `dotfiles/private/config/*`)
  → each subdirectory is symlinked into `~/.config/` only on the matching
  profile.

Machine-specific values live in generated files that Ansible writes once and
never overwrites (`force: false`):

| Generated file | Contents |
|---|---|
| `~/.gitconfig.local` | `[user] name` and `email` |
| `~/.zshrc.local` | Profile-specific env vars, proxy settings, etc. |

## Adding a new dotfile

```bash
# Common (both machines)
cp ~/.config/foo/config dotfiles/config/foo/
git add dotfiles/config/foo/

# Work-only
cp ~/.config/bar/config dotfiles/work/config/bar/
git add dotfiles/work/config/bar/

# Re-apply symlinks
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags dotfiles
```

## Adding profile-specific packages

Edit `ansible/inventory/group_vars/work.yml` or `private.yml`:

```yaml
profile_packages:
  - my-new-tool
```

Then run:

```bash
make packages PROFILE=work
```

## User identity

Name and email are prompted on first run and saved to
`/etc/ansible/facts.d/user.fact`. To change them later, either:

```bash
# Edit the facts file directly
sudo nano /etc/ansible/facts.d/user.fact

# Or delete it to trigger the prompt again
sudo rm /etc/ansible/facts.d/user.fact
ansible-playbook ansible/playbooks/main.yml -K -e profile=work --tags dotfiles
```
