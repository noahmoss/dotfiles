# dotfiles

Personal config managed with [chezmoi](https://www.chezmoi.io/). Zsh, neovim, tmux, git, starship.

## Bootstrap

```sh
brew install chezmoi
chezmoi init --apply <this-repo-url>
brew bundle --file=~/.local/share/chezmoi/Brewfile
```
