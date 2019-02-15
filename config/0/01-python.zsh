export PATH="$PATH:$(python2 -m site --user-base)/bin:$(python3 -m site --user-base)/bin"

#
# Virtualenvwrapper
export WORKON_HOME=${HOME}/.virtualenvs
export PROJECT_HOME=${HOME}/src
source $(python -m site --user-base)/bin/virtualenvwrapper.sh
