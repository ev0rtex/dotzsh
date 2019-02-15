space-toggle() {
    if [[ $BUFFER[1] != " " ]]; then
        BUFFER=" $BUFFER"
	(( CURSOR+=1 ))
    else
        (( CURSOR-=1 ))
	BUFFER=$BUFFER[2,-1]
    fi
    zle reset-prompt
}
zle -N space-toggle

bindkey -a "^_" space-toggle
bindkey    "^_" space-toggle
