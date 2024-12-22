#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the configuration file path for fstab
CONF_FILE="/etc/fstab"
# Define the match string to check if swap is already disabled
MATCH_STR="#\/swap.img"

# Check if the configuration file has not been configured for the base system
# If the line is found, exit the script as no further action is needed
grep -q "# UNCONFIGURED FSTAB FOR BASE SYSTEM" "$CONF_FILE" && exit 0

# Check if swap is disabled by searching for the match string in the configuration file
# If the match string is found, exit the script as no further action is needed
grep -q "$MATCH_STR" "$CONF_FILE" && exit 0

# Apply swappiness by commenting out the swap entry in the configuration file
sudo sed -i "/\/swap.img/s/^/#/" "$CONF_FILE"
echo "Swappiness disabled."