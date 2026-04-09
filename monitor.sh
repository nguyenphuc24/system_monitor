#! /bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$SCRIPT_DIR/logs/monitor.log"

mkdir -p "$SCRIPT_DIR/logs"


# CPU (%)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
CPU=$(printf "%.2f" "$CPU")

# RAM (%)
RAM=$(free | awk '/Mem/ {printf("%.2f"), $3/$2 * 100}')

# DISK (%)
DISK=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

# TOP 5 PROCESSES
TOP_PROCS=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6)
echo "$TIMESTAMP | CPU:${CPU}% RAM:${RAM}% DISK:${DISK}%" >> "$LOG_FILE"


# CPU
if (( $(echo "$CPU > $CPU_THRESHOLD" | bc -l) )); then
    send_alert "CPU" "CRITICAL" "Usage ${CPU}% (threshold ${CPU_THRESHOLD}%)"
fi

# RAM
if (( $(echo "$RAM > $RAM_THRESHOLD" | bc -l) )); then
    send_alert "RAM" "CRITICAL" "Usage ${RAM}% (threshold ${RAM_THRESHOLD}%)"
fi

# DISK
if (( DISK > DISK_THRESHOLD )); then
    send_alert "DISK" "CRITICAL" "Usage ${DISK}% (threshold ${DISK_THRESHOLD}%)"
fi
