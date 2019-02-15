# ------------------------------------------------------- #
#                         Terminfo                        #
# ------------------------------------------------------- #
# This fixes macOS terminfo to support modern features    #
# ======================================================= #
# Run:
#   mkdir ~/.terminfo
#   export TERMINFO=~/.terminfo
#   curl -fsSL http://invisible-island.net/datafiles/current/terminfo.src.gz | gunzip > /tmp/terminfo.src
#   tic -x /tmp/terminfo.src
#

export TERMINFO=${HOME}/.terminfo

if [[ ! -d ${TERMINFO} ]]; then
    echo "Updating user terminfo DB..."
    mkdir -p ${TERMINFO}
    curl -fsSL http://invisible-island.net/datafiles/current/terminfo.src.gz | gunzip > /tmp/terminfo.src
    tic -x /tmp/terminfo.src
fi
