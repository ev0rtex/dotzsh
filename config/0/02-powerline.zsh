#
# Powerline setup
[[ -f ${HOME}/.pippowerline ]] && \
    PIP_POWERLINE=$(cat ${HOME}/.pippowerline) || \
    PIP_POWERLINE=$(pip show powerline-status | tee ${HOME}/.pippowerline)

POWERLINE_ROOT="$(awk '$1 == "Location:" {print $2}' <<< "$PIP_POWERLINE")/powerline"
POWERLINE_BIN="$(awk '$1 == "Location:" {split($2, a, "/lib/"); print a[1]}' <<< "$PIP_POWERLINE")/bin"

[[ ":$PATH:" == *":$POWERLINE_BIN:"* ]] || \
    export PATH="$PATH:$POWERLINE_BIN"

source $POWERLINE_ROOT/bindings/zsh/powerline.zsh
export LC_POWERLINE="✓" # U+2713 (checkmark)
