#
# Key bindings:
#   - Enable Vi mode for ZSH
#   - NOTE: Find key chars easily using `sed -n l`
#

export KEYTIMEOUT=1

bindkey -v
bindkey    '^?'    backward-delete-char
bindkey    '^h'    backward-delete-char
bindkey    '^[[3~' delete-char
bindkey -a '^[[3~' delete-char
bindkey    '^w'    backward-kill-word
bindkey    '^[f'   forward-word
bindkey -a '^[f'   forward-word
bindkey    '^[b'   backward-word
bindkey -a '^[b'   backward-word
bindkey    '^r'    history-incremental-search-backward
bindkey    '^a'    beginning-of-line
#bindkey -a '^a'    beginning-of-line
bindkey    '^e'    end-of-line
bindkey -a '^e'    end-of-line
bindkey    "${terminfo[khome]}" beginning-of-line
bindkey    "${terminfo[kend]}"  end-of-line
bindkey -a "${terminfo[khome]}" beginning-of-line
bindkey -a "${terminfo[kend]}"  end-of-line
bindkey    "${terminfo[kpp]}"   up-line-or-history
bindkey    "${terminfo[knp]}"   down-line-or-history
bindkey -a "${terminfo[kpp]}"   up-line-or-history
bindkey -a "${terminfo[knp]}"   down-line-or-history
bindkey    '^ '   autosuggest-accept
bindkey    '^@\n' autosuggest-execute # Sent by iTerm2 key map from Ctrl+Enter -> Hex: 0x00 0x0A

# Make sure ^K and ^U work
bindkey    '^K' kill-line
bindkey    '^U' vi-kill-line
