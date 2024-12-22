#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if an argument is provided and is not empty
if [ "$#" -eq 0 ] || [ -z "$1" ]; then
    # If no argument is provided, print an error message and exit
    echo "No timezone provided."
    exit 1
fi
# Assign the provided argument
USER_TIMEZONE="$1"

# Check if the current system timezone matches the provided timezone
# If it matches, exit the script as no further action is needed
timedatectl | grep -q "$USER_TIMEZONE" && exit 0

# Set the system timezone to the provided timezone
sudo timedatectl set-timezone "$USER_TIMEZONE"
echo "System timezone set to $USER_TIMEZONE."