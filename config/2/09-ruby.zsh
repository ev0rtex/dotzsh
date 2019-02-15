#
# Stuff for chruby
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh

#
# Add gem executable path
export PATH="${PATH}:$(gem env | awk -F':' '/EXECUTABLE DIRECTORY/ { printf "%s",$2 }' | sed -e 's/^[[:space:]]*//')"
