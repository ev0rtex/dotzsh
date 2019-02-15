# Use 'even-better-ls' (repo in ~/source/misc/even-better-ls)
export LS_COLORS=$(/usr/local/bin/ls_colors_generator)
run_ls() {
  ls-i --color=auto -w $(tput cols) "$@"
}
alias ls="run_ls"

