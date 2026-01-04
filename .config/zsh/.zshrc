# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added a config file for you to customize HyDE before loading zshrc
# Edit $ZDOTDIR/.user.zsh to customize HyDE before loading zshrc

#  Plugins 
# oh-my-zsh plugins are loaded  in $ZDOTDIR/.user.zsh file, see the file for more information

#  Aliases 
# Override aliases here in '$ZDOTDIR/.zshrc' (already set in .zshenv)

#  This is your file 
# Add your configurations here

export EDITOR=nvim


# ====== ALIASES ======

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

    # directory
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
alias C='cmake -G Ninja -S . -B build/'
alias b='ninja -C build'
alias x='./build/main'
alias bx='ninja -C build && ./build/main'

    # micellious 
alias c='clear'
alias zin='hydectl zoom --in --intensity'
alias zout='hydectl zoom --out --intensity'
alias zreset='hydectl zoom --reset' 
alias mynvim='NVIM_APPNAME=mynvim nvim'
alias dots='/usr/bin/git --git-dir=$HOME/Documents/dotfiles/ --work-tree=$HOME'
alias lazydots='lazygit --git-dir=$HOME/Documents/dotfiles --work-tree=$HOME'


# ====== TMUX FUNCTIONS ======

# Create new tmux session (requires session name)
tn() {
    if [ $# -eq 0 ]; then
        echo "Usage: tn <session-name>"
        echo "Example: tn work"
    else
        tmux new-session -s "$1"
    fi
}

# Attach to tmux session (requires session name)
ta() {
    if [ $# -eq 0 ]; then
        echo "Available tmux sessions:"
        tmux list-sessions
        echo ""
        echo "Usage: ta <session-name>"
        echo "Example: ta main"
    else
        tmux attach-session -t "$1"
    fi
}

alias tl='tmux list-sessions'
alias tks='tmux kill-session' 
alias tkS='tmux kill-server'


# cursor fix for tmux
if [[ -n "$TMUX" ]]; then
    # Reset cursor constantly in tmux
    function _tmux_cursor_fix() {
        echo -ne '\e[5 q'
    }
    
    # Reset cursor before every command
    precmd_functions+=(_tmux_cursor_fix)
    
    # Also reset after keymap changes
    function zle-keymap-select() {
        if [[ $KEYMAP == vicmd ]]; then
            echo -ne '\e[1 q'
        else
            echo -ne '\e[5 q'
        fi
        zle reset-prompt
    }
    zle -N zle-keymap-select
    
    # Initial cursor
    echo -ne '\e[5 q'
fi


