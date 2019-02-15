_increase-number() {
  integer pos NUMBER i first last prelength diff
  pos=$CURSOR
  # find numbers starting from the left of the cursor to the end of the line
  while [[ $BUFFER[$pos] != [[:digit:]] ]]; do
    (( pos++ ))
    (( $pos > $#BUFFER )) && return
  done

  # use the numeric argument and default to 1
  # negate if called as decrease-number
  NUMBER=${NUMERIC:-1}
  if [[ $WIDGET = decrease-number ]]; then
    (( NUMBER = 0 - $NUMBER ))
  fi

  # find the start of the number
  i=$pos
  while [[ $BUFFER[$i-1] = [[:digit:]] ]]; do
    (( i-- ))
  done
  first=$i

  # include one leading - if found
  if [[ $BUFFER[$first-1] = - ]]; then
    (( first-- ))
  fi

  # find the end of the number
  i=$pos
  while [[ $BUFFER[$i+1] = [[:digit:]] ]]; do
    (( i++ ))
  done
  last=$i

  # change the number and move cursor after it
  prelength=$#BUFFER
  (( BUFFER[$first,$last] += $NUMBER ))
  (( diff = $#BUFFER - $prelength ))
  (( CURSOR = last + diff ))

  zle reset-prompt
}
zle -N increase-number _increase-number
zle -N decrease-number _increase-number
bindkey "^a" increase-number
bindkey "^x" decrease-number
