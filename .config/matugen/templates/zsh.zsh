ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg={{colors.outline.default.hex}}'

ZSH_HIGHLIGHT_STYLES[default]='fg={{colors.on_surface.default.hex}}'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg={{colors.error.default.hex}}'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg={{colors.tertiary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[alias]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[builtin]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[function]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[command]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[precommand]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg={{colors.secondary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[path]='fg={{colors.primary.default.hex}},underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[path_approx]='fg={{colors.secondary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[globbing]='fg={{colors.tertiary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg={{colors.secondary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg={{colors.secondary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg={{colors.tertiary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg={{colors.secondary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg={{colors.secondary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg={{colors.primary.default.hex}}'
ZSH_HIGHLIGHT_STYLES[assign]='fg={{colors.on_surface.default.hex}}'

export FZF_DEFAULT_OPTS="
--color=fg:{{colors.on_surface.default.hex}},bg:{{colors.surface.default.hex}},hl:{{colors.primary.default.hex}}
--color=fg+:{{colors.on_surface.default.hex}},bg+:{{colors.surface_variant.default.hex}},hl+:{{colors.primary.default.hex}}
--color=info:{{colors.secondary.default.hex}},prompt:{{colors.primary.default.hex}},pointer:{{colors.error.default.hex}}
--color=marker:{{colors.primary.default.hex}},spinner:{{colors.tertiary.default.hex}},header:{{colors.primary.default.hex}}
--color=border:{{colors.outline.default.hex}}
"

export LS_COLORS='di=01;34:ln=01;36:so=01;35:pi=33:ex=01;32:bd=01;33:cd=01;33:su=30;41:sg=30;46:tw=30;42:ow=30;43'
