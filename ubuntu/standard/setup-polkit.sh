#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Initialize a flag to track if any action has been applied
ANY_ACTION_APPLIED=false
# Define the configuration directory for polkit rules
CONF_DIR="/etc/polkit-1/localauthority/50-local.d"
# Define the path for the polkit rule file to allow power state changes
CONF_FILE_POWER_STATE="$CONF_DIR/allow_power_state.pkla"
# Define the path for the polkit rule file to allow unit management
CONF_FILE_MANAGE_UNIT="$CONF_DIR/allow_manage_units.pkla"

# Check if the configuration directory exists and if "other" users can access it
# If not, change the permissions to allow "other" users to access the parent directory
! test -d "$CONF_DIR" && sudo chmod o+x $(dirname "$CONF_DIR")

# Check if the polkit rule file already exists
if ! test -f "$CONF_FILE_POWER_STATE"; then
    # If the file does not exist, create it with the necessary rules
    echo "[Allow the curent called user to modify the powered state]
Identity=unix-user:$USER
Action=org.freedesktop.login1.set-reboot-parameter;org.freedesktop.login1.set-wall-message;org.freedesktop.login1.halt-multiple-sessions;org.freedesktop.login1.halt;org.freedesktop.login1.hibernate-multiple-sessions;org.freedesktop.login1.hibernate;org.freedesktop.login1.power-off-multiple-sessions;org.freedesktop.login1.power-off;org.freedesktop.login1.reboot-multiple-sessions;org.freedesktop.login1.reboot;org.freedesktop.login1.suspend-multiple-sessions;org.freedesktop.login1.suspend
ResultAny=yes" | sudo tee "$CONF_FILE_POWER_STATE"
    echo -e "$CONF_FILE_POWER_STATE configured.\n"
    ANY_ACTION_APPLIED=true
fi

# Check if the polkit rule file already exists
if ! test -f "$CONF_FILE_MANAGE_UNIT"; then
    # If the file does not exist, create it with the necessary rules
    echo "[Allow the curent called user to start/stop a unit/service]
Identity=unix-user:$USER
Action=org.freedesktop.systemd1.manage-units
ResultAny=yes" | sudo tee "$CONF_FILE_MANAGE_UNIT"
    echo -e "$CONF_FILE_MANAGE_UNIT configured.\n"
    ANY_ACTION_APPLIED=true
fi

# Restart DBus if any action was applied
! $ANY_ACTION_APPLIED && exit 0
sudo invoke-rc.d dbus restart
echo "polkit configured."