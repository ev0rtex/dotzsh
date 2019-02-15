#
# Set up the needed env for dinghy
if [[ -z ${DOCKER_HOST} ]]; then
    eval "$(dinghy shellinit)"
fi

#
# Helper to forward ports from localhost to dinghy VM for docker
dinghy-expose () {
    local stone_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/stone"
    local stone_log="${stone_cache}/output.log"
    local _kill=0
    local _start=1

    for arg in "${@}"; do
        case "${arg}" in
            -k|--kill )   _kill=1;_start=0 ;;
            -u|--update ) _kill=1;_start=1 ;;
        esac
    done

    [[ ! -d "${stone_cache}" ]] && \
        mkdir -p "${stone_cache}"

    #
    # Kill existing if needed
    local stone_pid=$(pidof stone | tr -d ' ')
    if [[ -n "${stone_pid}" ]]; then
        if [[ "${_kill}" == "1" ]]; then
            echo "Stopping stone process ${stone_pid}"
            kill ${stone_pid}
        else
            echo -e "Stone is already running as process ${stone_pid}\nLog file: ${stone_log}"
            _start=0
        fi
    elif [[ "${_kill}" == "1" ]]; then
        echo "Stone is not currently running"
    fi

    #
    # Start
    if [[ "${_start}" == "1" ]]; then
        local bindings=$(docker ps -q | grep -v $(docker ps -q --filter='name=dinghy_http_proxy') | xargs -L 1 docker port | grep -o "[0-9]\+$" | tr '\n' ' ' | sed -e "s/\([0-9]\{1,\}\)/$(dinghy ip):\1 \1 --/g")
        eval "nohup stone ${bindings} >${stone_log} 2>&1 &!" >/dev/null
        echo -e "Stone is running as pid ${!}\nLog file: ${stone_log}"
    fi
}
