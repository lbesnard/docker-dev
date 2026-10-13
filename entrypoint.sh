#!/usr/bin/env bash
set -u
REPOS="$HOME/github_repo"
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

sync_repo() {
  local url=$1 dir=$2
  if [[ -d $dir/.git ]]; then
    git -C "$dir" pull --ff-only -q || echo "warn: pull failed for $dir"
  else
    git clone -q "$url" "$dir" || echo "warn: clone failed for $url"
  fi
}

sync_repo https://github.com/lbesnard/dotfiles.git "$REPOS/dotfiles"
if [[ -S ${SSH_AUTH_SOCK:-} ]]; then
  sync_repo git@github.com:lbesnard/dotfiles_private.git "$REPOS/dotfiles_private"
else
  echo "warn: no ssh-agent, skipping dotfiles_private"
fi

D="$REPOS/dotfiles"
link() { [[ -e $D/$1 ]] && mkdir -p "$(dirname "$2")" && ln -sfn "$D/$1" "$2"; }

# Allowlist: no env_private, ssh, or gh (gh auth lives in a volume)
link alias            ~/.alias
link alias_forgit     ~/.alias_forgit
link bashrc           ~/.bashrc
link bash_profile     ~/.bash_profile
link complete         ~/.complete
link env              ~/.env
link flake8           ~/.flake8
link gitconfig        ~/.gitconfig
link gitignore        ~/.gitignore
link nvim             ~/.config/nvim
link tmux/tmux.conf   ~/.tmux.conf
link vim/vimrc        ~/.vimrc
link zsh_alias        ~/.zsh_alias
link zsh/zshrc        ~/.zshrc
link zsh/zshrc.common ~/.zshrc.common
link zsh/zshrc.homeserver ~/.zshrc.homeserver
link cheat            ~/.cheat
link zsh/zshrc.server ~/.zshrc.server
link zsh/zshrc.laptop ~/.zshrc.local
link zsh/zshrc.server ~/.zshrc.ssh
link zsh/functions    ~/.zsh_functions
link zsh/completions  ~/.zsh_complete
link aws              ~/.aws
link bin              ~/bin

exec "$@"
