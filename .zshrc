# ==================================================
# ZSH CONFIG — wasi
# Location: ~/.config/zsh/.zshrc
# ==================================================

# ---------- XDG ----------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ---------- Editor ----------
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- PATH ----------
export PATH="$HOME/.local/bin:$PATH"

# ---------- History ----------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

# ---------- Zsh behavior ----------
setopt AUTO_CD
setopt NO_BEEP
bindkey -v
export KEYTIMEOUT=1

# ==================================================
# COMPLETION
# ==================================================
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ''

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
alias pic='kitty icat'
alias camera='guvcview'
alias f='fastfetch --logo-type kitty-icat --logo-width 35'
alias ff='fastfetch -l small'
alias n='nvim'
alias C='cmake -G Ninja -S . -B build/'
alias b='ninja -C build'
alias x='./build/main'
alias bx='ninja -C build && ./build/main'

# ----- misc -----
alias c='clear'
alias zin='hydectl zoom --in --intensity'
alias zout='hydectl zoom --out --intensity'
alias zreset='hydectl zoom --reset'
alias mynvim='NVIM_APPNAME=mynvim nvim'

# dotfiles (bare repo)
alias dots='/usr/bin/git --git-dir=$HOME/Documents/dotfiles/ --work-tree=$HOME'
alias lazydots='lazygit --git-dir=$HOME/Documents/dotfiles --work-tree=$HOME'

# safety
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

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

lt() {
  eza -lT --icons --git -L "${1:-1}"
}

ltg() {
  eza -lT --icons --git --git-ignore --git-repos -L "${1:-1}"
}

lta() {
  eza -laT --icons --git -L "${1:-1}"
}

tree() {
  eza --tree --icons "$@"
}

# ==================================================
# FZF
# ==================================================
fe() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git \
    | fzf --preview 'eza --tree --level=3 --icons --color=always {}') || return
  cd "$dir"
}
