#!/usr/bin/env zsh
setopt HIST_FCNTL_LOCK
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
unsetopt HIST_SAVE_NO_DUPS
unsetopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
unsetopt autocd
setopt extended_glob
setopt nullglob
if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
    autoload -Uz -- "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
    ghostty-integration
    unfunction ghostty-integration
fi
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
export YSU_MESSAGE_POSITION="after"
export YSU_HARDCORE=1
