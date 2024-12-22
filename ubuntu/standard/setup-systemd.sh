#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the configuration directory and file path
CONF_DIR="/etc/systemd/logind.conf.d"
CONF_FILE="$CONF_DIR/zz-setmaxdelay.conf"

# Check if an argument is provided and is not empty
if [ "$#" -eq 0 ] || [ -z "$1" ]; then
    # If no argument is provided, print an error message and exit
    echo "No inhibit max delay (secs) provided."
    echo "e.g: 60"
    exit 1
fi
# Assign the provided argument
USER_INHIBIT_MAX_DELAY="$1"

# Check if the configuration file already exists, if so, exit the script
test -f "$CONF_FILE" && exit 0

# Create the logind configuration directory if it does not exist
sudo mkdir -p "$CONF_DIR"

# Apply the inhibit delay max seconds by creating a configuration file
echo "[Login]
InhibitDelayMaxSec=$USER_INHIBIT_MAX_DELAY" | sudo tee "$CONF_FILE"

# Restart the systemd-logind service to apply the changes
sudo systemctl restart systemd-logind
echo "systemd-logind configured."