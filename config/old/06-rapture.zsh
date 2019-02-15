#
# Helper to call 'op' using the '1pass' saved session
_op() {
    # Refresh the session if needed
    if [[ ! $(find ~/.1pass/cache/_session.gpg -mmin -29) ]]; then
        1pass -r >/dev/null
    fi

    # Use the cached session for the 'op' CLI
    gpg -qdr ${$(grep self_key ~/.1pass/config)##*=} ~/.1pass/cache/_session.gpg | op ${@}
}

_rapture-env() {
    local vault_pass=${1}
    local aws_totp=${2}
    local rap_args=${@:3}

    echo "$(/usr/bin/expect -f - <<< "
        set timeout 5
        spawn ${GOPATH}/bin/rapture ${rap_args}
        expect {
            -re \"(?:Initializing vaulted env|Vault) '\\[^']+':?\" {
                exp_continue
            }
            -re \"\\[P|p]assword:\" {
                exp_send \"${vault_pass}\\r\"
                exp_continue
            }
            -re \"MFA (?:code|token):\" {
                exp_send \"${aws_totp}\\r\"
                exp_continue
            }
            -re \"\\r\\n(.*\\r\\necho.*)\" {
                exp_continue
            }
        }
        puts \"---\\n\$expect_out(1,string)\"
    " | sed -e '1,/---/d' | tr -d '\r')"
}

old_rapture() {
    if [[ -n "${GOPATH}" ]] && [[ -x "${GOPATH}/bin/rapture" ]]; then
        export _rapture_session_id \
            _rapture_session_key \
            _rapture_session_salt \
            _rapture_wrap=true

        #
        # Hijack to inject password and TOTP
        if [[ ${1} == "init" ]]; then
            vault=${2}
            vault_item=$(_op get item "cli:vaulted:${vault}")
            vault_pass=$(jq -r '.details.password' <<< ${vault_item})
            aws_ref=$(jq -r '.details.sections[].fields | select(.[].t | startswith("AWS:")) | .[].t' <<< ${vault_item})
            aws_totp=$(_op get totp "${aws_ref}")
            #echo -e "vault_item: \n$(jq -r '.' <<< ${vault_item})\nvault_pass: ${vault_pass}\naws_ref: ${aws_ref}\naws_totp: ${aws_totp}"

            eval "$(_rapture-env ${vault_pass} ${aws_totp} ${@})"
        else
            eval "$(${GOPATH}/bin/rapture ${@})"
        fi
    else
        echo "ERROR: Rapture doesn't appear to be installed"
    fi
}
