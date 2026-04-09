#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Setting up System Monitor =="


echo "Please create .env file and edit it!"


# cấp quyền
chmod +x "$SCRIPT_DIR/monitor.sh"

# copy systemd service
sudo cp "$SCRIPT_DIR/systemd/system-monitor.service" /etc/systemd/system/

echo "Please edit service file:"
echo "sudo nano /etc/systemd/system/system-monitor.service"

echo "Then run:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl enable system-monitor"
echo "sudo systemctl start system-monitor"