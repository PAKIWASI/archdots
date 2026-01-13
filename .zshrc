
# ==================================================
# XDG BASE DIRS
# ==================================================
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ==================================================
# EDITOR / ENV
# ==================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# ==================================================
# PATH
# ==================================================
export PATH="$HOME/.local/bin:$PATH"

# ==================================================
# HISTORY
# ==================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt HIST_VERIFY

# ==================================================
# CORE ZSH BEHAVIOR
# ==================================================
setopt AUTO_CD
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt NO_CLOBBER

bindkey -v
export KEYTIMEOUT=1

# ==================================================
# COMPLETION SYSTEM
# ==================================================
autoload -Uz compinit
compinit

# general completion behavior
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_LIST
setopt AUTO_MENU
setopt NUMERIC_GLOB_SORT
setopt NO_CASE_GLOB

# completion styles
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# matching (case-insensitive + smart separators)
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# ==================================================
# BETTER HISTORY SEARCH (↑ ↓)
# ==================================================
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# ==================================================
# DIRECTORY STACK
# ==================================================
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
alias d='dirs -v'

# ==================================================
# STARSHIP PROMPT
# ==================================================
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

# ==================================================
# ZOXIDE
# ==================================================
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi

# ==================================================
# FZF
# ==================================================
autoload -Uz fzf-history-widget
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --preview-window=right:60%
"

# fuzzy cd with tree preview
fe() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git \
    | fzf --preview 'eza --tree --level=3 --icons --color=always {}') || return
  cd "$dir"
}

# use zsh history
export FZF_CTRL_R_OPTS="
  --height=40%
  --layout=reverse
  --border
  --prompt='history ❯ '
  --preview 'echo {}'
"

# bind Ctrl-R
bindkey '^R' fzf-history-widget

# ==================================================
# ALIASES
# ==================================================

# ----- pacman -----
alias sp='sudo pacman'
alias sps='sudo pacman -S'
alias spss='sudo pacman -Ss'
alias spsyu='sudo pacman -Syu'
alias spr='sudo pacman -R'
alias sprns='sudo pacman -Rns'
alias spq='sudo pacman -Q'
alias pacorphs='pacman -Qtdq'
alias pacorphs-rm='sudo pacman -Rns $(pacman -Qtdq)'
alias pacforeign='pacman -Qqm'

# ----- directory -----
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias mkdir='mkdir -p'

# ----- applications -----
alias ff='fastfetch -l small'
alias n='nvim'

# ----- build -----
alias C='cmake -G Ninja -S . -B build/'
alias b='ninja -C build'
alias x='./build/main'
alias bx='ninja -C build && ./build/main'

# ----- misc -----
alias c='clear'



# safety
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# reload
alias sz='source ~/.config/zsh/.zshrc'

# ==================================================
# TMUX HELPERS
# ==================================================
tn() {
  if [ $# -eq 0 ]; then
    echo "Usage: tn <session-name>"
  else
    tmux new-session -s "$1"
  fi
}

ta() {
  if [ $# -eq 0 ]; then
    tmux list-sessions
    echo "Usage: ta <session-name>"
  else
    tmux attach-session -t "$1"
  fi
}

alias tl='tmux list-sessions'
alias tks='tmux kill-session'
alias tkS='tmux kill-server'

# ----- tmux cursor fix -----
if [[ -n "$TMUX" ]]; then
  function _tmux_cursor_fix() {
    echo -ne '\e[5 q'
  }
  precmd_functions+=(_tmux_cursor_fix)

  function zle-keymap-select() {
    if [[ $KEYMAP == vicmd ]]; then
      echo -ne '\e[1 q'
    else
      echo -ne '\e[5 q'
    fi
    zle reset-prompt
  }
  zle -N zle-keymap-select

  echo -ne '\e[5 q'
fi

# ==================================================
# EZA
# ==================================================
export EZA_THEME="$XDG_CONFIG_HOME/eza/theme.yml"

alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lls='eza -l --icons --git --total-size'
alias las='eza -la --icons --git --total-size'

alias lm='eza -l --sort=modified --icons --git'
alias lz='eza -l --sort=size --icons --git'
alias lx='eza -l --sort=extension --icons --git'
alias lg='eza -l --git --git-ignore --git-repos --icons'

lt()  { eza -lT  --icons --git -L "${1:-1}"; }
ltg() { eza -lT  --icons --git --git-ignore --git-repos -L "${1:-1}"; }
lta() { eza -laT --icons --git -L "${1:-1}"; }

tree() {
  eza --tree --icons "$@"
}
