#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the configuration file path for needrestart
SERVICE_NAME="enable-console-blanking.service"
SERVICE_CONF_FILE="/etc/systemd/system/$SERVICE_NAME"

# Exit if the service configuration file already exists
test -f "$SERVICE_CONF_FILE" && exit 0

# Create the service configuration file
echo "[Unit]
Description=Enable console blanking and poweroff

[Service]
Type=oneshot
Environment=TERM=linux
StandardOutput=tty
TTYPath=/dev/console
ExecStart=/usr/bin/setterm -blank 1 -powerdown 1 -powersave powerdown

[Install]
WantedBy=multi-user.target" | sudo tee "$SERVICE_CONF_FILE"

# Enable the service
sudo systemctl enable "$SERVICE_NAME" && sudo systemctl start "$SERVICE_NAME"
echo "Console blanking enabled and started."