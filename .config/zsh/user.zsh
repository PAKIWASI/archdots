#  Startup 
# Commands to execute on startup (before the prompt is shown)
# Check if the interactive shell option is set


if [[ $- == *i* ]]; then
    # HYDE: This is a good place to load graphic/ascii art, display system information, etc.
    
    # Skip display in neovim terminal or tmux popup             set in .tmux.conf
    if [ -n "$NVIM" ] || [ "$TERM_PROGRAM" = "nvim" ] || [ -n "$TMUX_POPUP" ]; then
       # Clear on popup terminal (it does not support pics)
       # if [ -n "$TMUX_POPUP" ]; then
       #     clear
       # fi
    else
        # Regular terminal - decide between fastfetch or random logo
        if [ -n "$TMUX" ]; then
            # In tmux (but not popup) - show random logo
            LOGO_DIR="$HOME/.config/fastfetch/logo"
            if [ -d "$LOGO_DIR" ] && command -v kitty >/dev/null 2>&1; then
                RANDOM_LOGO=$(find "$LOGO_DIR" -type f -name "*logo*" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | shuf -n 1)
                if [ -n "$RANDOM_LOGO" ]; then
                    kitty icat --align center "$RANDOM_LOGO"
                fi
            fi
        else
            # In normal kitty terminal (not tmux) - show fastfetch
            if command -v fastfetch >/dev/null; then
                if do_render "image"; then
                    fastfetch --logo-type kitty
                fi
            fi
        fi
    fi
fi




#   Overrides 
# HYDE_ZSH_NO_PLUGINS=1 # Set to 1 to disable loading of oh-my-zsh plugins, useful if you want to use your zsh plugins system 
# unset HYDE_ZSH_PROMPT # Uncomment to unset/disable loading of prompts from HyDE and let you load your own prompts
# HYDE_ZSH_COMPINIT_CHECK=1 # Set 24 (hours) per compinit security check // lessens startup time
# HYDE_ZSH_OMZ_DEFER=1 # Set to 1 to defer loading of oh-my-zsh plugins ONLY if prompt is already loaded

if [[ ${HYDE_ZSH_NO_PLUGINS} != "1" ]]; then
    #  OMZ Plugins 
    # manually add your oh-my-zsh plugins here
    plugins=(
        "vi-mode"       # VI mode for command line
        "zoxide"        # directory jumping
    )
fi




