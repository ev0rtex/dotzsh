#
# reset-accept:
#     This will redraw the prompt prior to executing the command (helps me get a current execution timestamp)
reset-accept() {
    zle reset-prompt
    zle accept-line
}
zle -N reset-accept
bindkey '^M' reset-accept

#
# zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(reset-accept)

