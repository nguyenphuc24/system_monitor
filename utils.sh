declare -A LAST_ALERT
should_alert() {
    local KEY=$1
    local NOW=$(date +%s)

    if [ -z "${LAST_ALERT[$KEY]}" ]; then
        LAST_ALERT[$KEY]=0
    fi

    if (( NOW - LAST_ALERT[$KEY] > COOLDOWN )); then
        LAST_ALERT[$KEY]=$NOW
        return 0
    else
        return 1
    fi
}
