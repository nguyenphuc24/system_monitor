#! /bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
ALERT_LOG="logs/alert.log"

alert_format(){
    local LEVEL=$1
    local TYPE=$2
    local MESSAGE=$3
    local TIME_STAMP=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$TIME_STAMP] [$LEVEL] [$TYPE] $MESSAGE"
} 

log_alert(){
    local MSG=$1

    echo "$MSG" >> $ALERT_LOG
}
alert_terminal() {
    local MSG=$1
    echo -e "\033[31m$MSG\033[0m" 
}

#Telebot function
send_telegram() {
    local MSG=$1

    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${CHAT_ID}" \
        --data-urlencode "text=${MSG}"
}

send_alert() {
    local TYPE=$1
    local LEVEL=$2
    local MESSAGE=$3

    FORMATTED_MSG=$(alert_format "$LEVEL" "$TYPE" "$MESSAGE")

    # log
    log_alert "$FORMATTED_MSG"

    # terminal
    alert_terminal "$FORMATTED_MSG"

    # telegram
    if [ "$ENABLE_TELEGRAM" = true ]; then
        send_telegram "$FORMATTED_MSG"
    fi

    # email
    if [ "$ENABLE_EMAIL" = true ]; then
        send_email "$FORMATTED_MSG"
    fi
}