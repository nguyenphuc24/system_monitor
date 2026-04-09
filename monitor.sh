#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ===== ENV =====
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo ".env file not found!"
    exit 1
fi

source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/alert.sh"
source "$SCRIPT_DIR/utils.sh"

# ===== LOG SETUP =====
LOG_DIR="$SCRIPT_DIR/logs"
MONITOR_LOG="$LOG_DIR/monitor.log"
ALERT_LOG="$LOG_DIR/alert.log"

# tạo folder nếu chưa có
mkdir -p "$LOG_DIR"

# ===== CONFIG =====
INTERVAL=3
COOLDOWN=60

# ===== LOOP =====
while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # CPU (%)
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    CPU=$(printf "%.2f" "$CPU")

    # RAM (%)
    RAM=$(free | awk '/Mem/ {printf("%.2f"), $3/$2 * 100}')

    # DISK (%)
    DISK=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

    # ===== MONITOR LOG =====
    echo "$TIMESTAMP | CPU:${CPU}% RAM:${RAM}% DISK:${DISK}%" >> "$MONITOR_LOG"

    # ===== CPU ALERT =====
    if (( $(echo "$CPU > $CPU_THRESHOLD" | bc -l) )); then
        if should_alert "CPU"; then
            MESSAGE="$TIMESTAMP | CPU CRITICAL: ${CPU}% (threshold ${CPU_THRESHOLD}%)"
            
            echo "$MESSAGE" >> "$ALERT_LOG"
            send_alert "CPU" "CRITICAL" "Usage ${CPU}% (threshold ${CPU_THRESHOLD}%)"
        fi
    fi

    # ===== RAM ALERT =====
    if (( $(echo "$RAM > $RAM_THRESHOLD" | bc -l) )); then
        if should_alert "RAM"; then
            MESSAGE="$TIMESTAMP | RAM CRITICAL: ${RAM}% (threshold ${RAM_THRESHOLD}%)"
            
            echo "$MESSAGE" >> "$ALERT_LOG"
            send_alert "RAM" "CRITICAL" "Usage ${RAM}% (threshold ${RAM_THRESHOLD}%)"
        fi
    fi

    # ===== DISK ALERT =====
    if (( DISK > DISK_THRESHOLD )); then
        if should_alert "DISK"; then
            MESSAGE="$TIMESTAMP | DISK CRITICAL: ${DISK}% (threshold ${DISK_THRESHOLD}%)"
            
            echo "$MESSAGE" >> "$ALERT_LOG"
            send_alert "DISK" "CRITICAL" "Usage ${DISK}% (threshold ${DISK_THRESHOLD}%)"
        fi
    fi

    sleep $INTERVAL
done