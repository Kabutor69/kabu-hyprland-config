# Starship prompt
eval "$(starship init zsh)"

# Basic settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Enable colors
autoload -U colors && colors

# Load completions
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*:default' list-colors \
    'di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# Selection mechanism
typeset -g SHIFT_HELD=0

clear-selection-on-redraw() {
    if (( REGION_ACTIVE )) && [[ "$LASTWIDGET" != *-select ]]; then
        REGION_ACTIVE=0
    fi
}
autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-pre-redraw clear-selection-on-redraw

# Shift selection widgets
backward-char-select() {
    if (( ! REGION_ACTIVE )); then
        zle set-mark-command
    fi
    zle backward-char
}
forward-char-select() {
    if (( ! REGION_ACTIVE )); then
        zle set-mark-command
    fi
    zle forward-char
}
beginning-of-line-select() {
    if (( ! REGION_ACTIVE )); then
        zle set-mark-command
    fi
    zle beginning-of-line
}
end-of-line-select() {
    if (( ! REGION_ACTIVE )); then
        zle set-mark-command
    fi
    zle end-of-line
}

zle -N backward-char-select
zle -N forward-char-select
zle -N beginning-of-line-select
zle -N end-of-line-select

# Smart delete widgets
smart-delete() {
    if (( REGION_ACTIVE )); then
        zle kill-region
    else
        zle delete-char
    fi
}
smart-ctrl-delete() {
    if (( REGION_ACTIVE )); then
        zle kill-region
    else
        zle kill-word
    fi
}
zle -N smart-delete
zle -N smart-ctrl-delete

# Shift selection shortcuts
bindkey '^[[1;2D' backward-char-select
bindkey '^[[1;2C' forward-char-select
bindkey '^[[1;2H' beginning-of-line-select
bindkey '^[[1;2F' end-of-line-select

#  Ctrl word navigation
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Navigation and delete
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' smart-delete
bindkey '^[[3;2~' kill-region
bindkey '^[[3;5~' smart-ctrl-delete

# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting 
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# wallpaper colors
if [[ -f ~/.config/colors.zsh ]]; then
    source ~/.config/colors.zsh
fi

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias gc="git clone "
alias gcm="git commit -m "

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

