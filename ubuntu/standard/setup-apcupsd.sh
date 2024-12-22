#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

ANY_ACTION_APPLIED=false

# Check if an argument is provided and is not empty
if [ "$#" -eq 0 ] || [ -z "$1" ]; then
    # If no argument is provided, print an error message and exit
    echo "No apcupsd device provided."
    echo "e.g: {'/dev/usb/hiddev0', 'IPv4', ...}"
    exit 1
fi
# Assign the provided argument
USER_DEVICE="$1"

# Check if apcupsd is installed
if ! command -v apcupsd &> /dev/null; then
    # If apcupsd is not installed, install it
    echo "apcupsd is not installed. Installing it..."
    sudo apt-get install -y apcupsd

    # Check if the installation was successful
    if [ "$?" -ne 0 ]; then
        echo "Failed to install apcupsd. Please check your system's package manager and try again."
        exit 1
    fi

    echo "apcupsd has been successfully installed."

    # Backup the global configuration file
    sudo cp /etc/apcupsd/apcupsd.conf /etc/apcupsd/apcupsd.conf.bak
    # Modify the battery level and minutes settings in the configuration file
    sudo sed -i 's/BATTERYLEVEL 5/BATTERYLEVEL 30/' /etc/apcupsd/apcupsd.conf
    sudo sed -i 's/MINUTES 3/MINUTES 5/' /etc/apcupsd/apcupsd.conf

    # Serve apcaccess everywhere on port 3551
    sudo sed -i 's/NISIP 127.0.0.1/NISIP 0.0.0.0/' /etc/apcupsd/apcupsd.conf

    # Backup control configuration file
    sudo cp /etc/apcupsd/apccontrol /etc/apcupsd/apccontrol.bak
    # Modify the shutdown and reboot commands in the control configuration file
    sudo sed -i 's/${SHUTDOWN} -r now "apcupsd UPS ${2} initiated reboot"/systemctl reboot/' /etc/apcupsd/apccontrol
    sudo sed -i 's/${SHUTDOWN} -h now "apcupsd UPS ${2} initiated shutdown"/systemctl poweroff/' /etc/apcupsd/apccontrol
    ANY_ACTION_APPLIED=true
fi

# Check if apcupsd device match
CURR_DEVICE=$(grep "^DEVICE " /etc/apcupsd/apcupsd.conf | cut -d' ' -f2)
if [ "$CURR_DEVICE" != "$USER_DEVICE" ]; then
    # Replace device in the configuration file
    CURR_DEVICE="${CURR_DEVICE//\//\\/}"
    USER_DEVICE="${USER_DEVICE//\//\\/}"
    sudo sed -i "s/DEVICE $CURR_DEVICE/DEVICE $USER_DEVICE/" /etc/apcupsd/apcupsd.conf

    # Replace ups communication type
    MATCH_UPSTYPE=$(grep "^UPSTYPE " /etc/apcupsd/apcupsd.conf)
    if [[ $USER_DEVICE == *"/"* ]]; then
        sudo sed -i "s/$MATCH_UPSTYPE/UPSTYPE usb/" /etc/apcupsd/apcupsd.conf
    else
        sudo sed -i "s/$MATCH_UPSTYPE/UPSTYPE net/" /etc/apcupsd/apcupsd.conf
    fi

    echo "apcaccess set to $USER_DEVICE."
    ANY_ACTION_APPLIED=true
fi

# Restart apcupsd service if any action was applied
! $ANY_ACTION_APPLIED && exit 0
sudo systemctl restart apcupsd
echo "apcupsd configured."