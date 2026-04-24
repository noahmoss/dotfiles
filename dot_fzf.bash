# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/noahmoss/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/noahmoss/.fzf/bin"
fi

eval "$(fzf --bash)"
