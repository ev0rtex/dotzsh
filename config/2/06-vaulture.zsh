#
# Set up VAULTED_ASKPASS to use autovault
eval "$(autovault env)"

#
# Checks to ensure the 'op' session that 1pass saves can be decrypted by the GPG agent
#    - This ensures that the GPG agent loads the key _before_ 'vaulted' gets called and usurps STDIO
check_session() {
    local op_dir="${HOME}/.1pass"
    if [[ ! -d "${op_dir}" ]]; then
        echo "ERROR: 1pass doesn't appear to be installed"
        return 1
    fi
    if [[ -f "${op_dir}/config" ]] && [[ -f "${op_dir}/cache/_session.gpg" ]]; then
        gpg -qdr ${$(grep self_key ${op_dir}/config)##*=} ${op_dir}/cache/_session.gpg > /dev/null
    else
        echo "ERROR: 1pass doesn't appear to be configured/initialized yet"
        return 1
    fi
}

#
# Wrap the vaulted binary
vaulted() {
    if which vaulted > /dev/null; then
        check_session
        command vaulted ${@}
    else
        echo "ERROR: Vaulted doesn't appear to be installed"
        return 1
    fi
}

#
# Wrap the rapture binary
rapture() {
    if [[ -n "${GOPATH}" ]] && [[ -x "${GOPATH}/bin/rapture" ]]; then
        export _rapture_session_id \
            _rapture_session_key \
            _rapture_session_salt \
            _rapture_wrap=true

        check_session
        eval "$(${GOPATH}/bin/rapture ${@})"
    else
        echo "ERROR: Rapture doesn't appear to be installed"
        return 1
    fi
}

# ============================================================================ #
# Utilities and shell candy                                                    #
# ---------------------------------------------------------------------------- #

VAULTURE_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/vaulture"

#
# Get the account alias from the given ARN. Uses a cache whenever possible
_acct_from_arn() {
    local acct_cache="${VAULTURE_CACHE_DIR}/accts"
    local acct_id=$(awk -F: '{print $5}' <<< "${1}")

       [[ ! -d "${acct_cache}" ]] && mkdir -p "${acct_cache}"
    if [[ ! -f "${acct_cache}/${acct_id}" ]]; then
        local res=$(aws iam list-account-aliases 2>/dev/null)
        if [[ $? == 255 ]]; then  # On failure returns N=SIG(127): $? == 128+N
            echo "${acct_id}"     # Return the account ID for the sake of sanity
        else
            jq -r '.AccountAliases[0]' <<< "${res}" | tee "${acct_cache}/${acct_id}"
        fi
    else
        cat "${acct_cache}/${acct_id}"
    fi
}

#
# Extract an alias from the rapture aliases file or from account alias cache
_alias_from_arn() {
    local append_role=0
    local use_rapture=0
    local arn=""
    local alias=""
    for arg in "${@}"; do
        case "${arg}" in
            -r|--role ) append_role=1 ;;
            -u|--rapt ) use_rapture=1 ;;
            arn:aws:* ) arn="${arg}"  ;;
        esac
    done

    # Check for a rapture alias if desired
    if [[ "${use_rapture}" == "1" ]]; then
        alias=$(cat ${HOME}/.rapture/aliases.json | jq -r "to_entries[] | select(.value==\"${arn}\").key")
        [[ -n "${alias}" ]] && \
            append_role=0
    fi
    # Use AWS account alias if we didn't find one yet
    if [[ -z "${alias}" ]]; then
        alias=$(_acct_from_arn "${arn}")
    fi

    # Output with or without the role
    if [[ "${append_role}" == "1" ]]; then
        local role=$(awk -F: '{print $6}' <<< "${arn}")
        echo "${alias} (${role##*/})"
    else
        echo "${alias}"
    fi
}

#
# Refresh credentials
revault() {
    if [[ -n "${VAULTED_ENV}" ]]; then
        if rapture init ${VAULTED_ENV}; then
            if [[ -n "${RAPTURE_ROLE}" ]]; then
                rapture assume ${RAPTURE_ROLE}
            elif [[ -n "${VAULTED_ENV_ROLE_ARN}" ]]; then
                rapture assume ${VAULTED_ENV_ROLE_ARN}
            fi
        else
            echo "Failed rapture init for vault '${VAULTED_ENV}'"
            return 1
        fi
    else
        echo "You don't appear to be in a 'vaulted' environment...nothing to do"
        return 0
    fi
}

#
# PL9K prompt segment for AWS env
prompt_vaulture() {
    local venv="${VAULTED_ENV}"
    local role=""

    #
    # If the environment is mixed up, figure out the latest env to use
    local _exp_rapture=0
    local _exp_vaulted=0
    [[ -n "${RAPTURE_ROLE_EXPIRATION}" ]] && \
        _exp_rapture=$(( $(date +%s -d "${RAPTURE_ROLE_EXPIRATION}") - $(date +%s) ))
    [[ -n "${VAULTED_ENV_EXPIRATION}" ]] && \
        _exp_vaulted=$(( $(date +%s -d "${VAULTED_ENV_EXPIRATION}") - $(date +%s) ))

    #
    # Use the most recent env type in case of conflict
    local _dirty=""
    if [[ ${_exp_rapture} > ${_exp_vaulted} ]] && [[ -n "${RAPTURE_ASSUMED_ROLE_ARN}" ]]; then
        role=$(_alias_from_arn --role -u "${RAPTURE_ASSUMED_ROLE_ARN}")
    fi
    if [[ ${_exp_vaulted} > ${_exp_rapture} ]] && [[ -n "${VAULTED_ENV_ROLE_ARN}" ]]; then
        role=$(_alias_from_arn --role "${VAULTED_ENV_ROLE_ARN}")
    fi

    [[ -n "${role}" ]] && \
        venv="${venv}  ${role}"
    if [[ -n "${venv}" ]]; then
        "$1_prompt_segment" "$0" "$2" green black "${venv}" 'AWS_ICON'
    fi
}

