#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Patch the prompted "0;10;1c" when executing byobu/tmux over ssh
# Define the configuration file path for byobu/tmux
CONF_FILE="$HOME/.byobu/.tmux.conf"

# Check if the configuration file already contains the "escape-time" setting
# If it does, exit the script
grep -q "escape-time" "$CONF_FILE" && exit 0

# Create the .byobu directory in the user's home directory if it doesn't exist
mkdir -p "$HOME/.byobu"

# Append the "escape-time" setting to the configuration file
echo "set -sg escape-time 40" >> $CONF_FILE
echo "$CONF_FILE patch successfully applied."