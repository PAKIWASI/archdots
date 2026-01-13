
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
# COMPLETION SYSTEM (CORE)
# ==================================================
autoload -Uz compinit

# zsh-completions (Arch path)
if [ -d /usr/share/zsh/plugins/zsh-completions ]; then
  fpath=(/usr/share/zsh/plugins/zsh-completions $fpath)
fi

compinit

# completion behavior
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

# matching: case-insensitive + smart separators
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

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
# FZF (CORE CONFIG)
# ==================================================
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --prompt='❯ '
  --preview-window=right:60%
"

# ==================================================
# FZF CTRL-R HISTORY SEARCH (REAL, ZSH-NATIVE)
# ==================================================
fzf-history() {
  local cmd
  cmd=$(
    fc -rl 1 |
    sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' |
    fzf --tac --no-sort --query="$LBUFFER" \
        --prompt='history ❯ '
  ) || return

  LBUFFER="$cmd"
}
zle -N fzf-history
bindkey '^R' fzf-history

# ==================================================
# HISTORY SUBSTRING SEARCH (↑ ↓)
# ==================================================
if [ -f /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]; then
  source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ==================================================
# AUTOSUGGESTIONS
# ==================================================
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
bindkey '^ ' autosuggest-accept

# ==================================================
# ALIASES
# ==================================================

# pacman
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

# directories
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias mkdir='mkdir -p'

# applications
alias pic='kitty icat'
alias camera='guvcview'
alias f='fastfetch --logo-type kitty-icat --logo-width 35'
alias ff='fastfetch -l small'
alias n='nvim'
alias mynvim='NVIM_APPNAME=mynvim nvim'

# build
alias C='cmake -G Ninja -S . -B build/'
alias b='ninja -C build'
alias x='./build/main'
alias bx='ninja -C build && ./build/main'

# misc
alias c='clear'
alias zin='hydectl zoom --in --intensity'
alias zout='hydectl zoom --out --intensity'
alias zreset='hydectl zoom --reset'

# dotfiles
alias dots='/usr/bin/git --git-dir=$HOME/Documents/dotfiles/ --work-tree=$HOME'
alias lazydots='lazygit --git-dir=$HOME/Documents/dotfiles --work-tree=$HOME'

# safety
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

alias sz='source ~/.config/zsh/.zshrc'

# ==================================================
# TMUX HELPERS
# ==================================================
tn() {
  [[ $# -eq 0 ]] && echo "Usage: tn <session>" || tmux new-session -s "$1"
}

ta() {
  [[ $# -eq 0 ]] && tmux list-sessions || tmux attach-session -t "$1"
}

alias tl='tmux list-sessions'
alias tks='tmux kill-session'
alias tkS='tmux kill-server'

# tmux cursor fix
if [[ -n "$TMUX" ]]; then
  _tmux_cursor_fix() { echo -ne '\e[5 q'; }
  precmd_functions+=(_tmux_cursor_fix)

  zle-keymap-select() {
    [[ $KEYMAP == vicmd ]] && echo -ne '\e[1 q' || echo -ne '\e[5 q'
    zle reset-prompt
  }
  zle -N zle-keymap-select
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

tree() { eza --tree --icons "$@"; }

# ==================================================
# SYNTAX HIGHLIGHTING (MUST BE LAST)
# ==================================================
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
