#
# Install if needed
if [[ ! -d ${HOME}/.asdf ]]; then
    echo "Installing 'asdf' version manager"
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.6.2
fi

source ${HOME}/.asdf/asdf.sh
source ${HOME}/.asdf/completions/asdf.bash
