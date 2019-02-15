_smart-clone() {
    if [[ ${1} == *:* ]]; then
        #
        # Grab some project info
        local proj_path=${1##*:}
        local proj_base=${proj_path##*/}
        local proj_name=${proj_base%.git}
        local repo_path=${2:-${proj_name}}

        case ${1%%:*} in
            #
            # For instructure repos, install the needed post-commit hook
            gerrit|inst-gerrit)
                local hook_path=${repo_path}/.git/hooks/commit-msg

                if git clone ${@}; then
                    curl -sSLo ${hook_path} https://gerrit.instructure.com/tools/hooks/commit-msg
                    chmod +x ${hook_path}
                    cd ${repo_path}
                    git config --local user.email "dwarkentin@instructure.com"
                else
                    echo "Skipping repo config due to error"
                fi
                ;;
            gitlab|inst-gitlab)
                if git clone ${@}; then
                    cd ${repo_path}
                    git config --local user.email "dwarkentin@instructure.com"
                else
                    echo "Skipping repo config due to error"
                fi
                ;;

            #
            # For anything else just do a regular clone
            *)
                if git clone ${@}; then
                    cd ${repo_path}
                    git config --local user.email "ev0rtex@gmail.com"
                else
                    echo "Skipping repo config due to error"
                fi
                ;;
        esac
    else
        git clone ${@}
    fi
}

alias -s git='_smart-clone'
