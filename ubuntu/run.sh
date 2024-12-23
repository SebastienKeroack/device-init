#!/usr/bin/env bash

show_help() {
    echo "Usage: $0 <initialiser> [OPTIONS]"
    echo
    echo "Initialisers:"
    echo "  standard        Run the standard initialiser"
    echo
    echo "Options:"
    echo "  --inhibit-max-delay <seconds>  Set the maximum delay for node inhibition (default: 60)"
    echo "  --apcupsd-device <device>      Set the APC UPS device (default: /dev/usb/hiddev0)"
    echo "  --verbose, -v                  Enable verbose mode"
    echo "  --help, -h                     Show this help message"
}

setup_context() {
    # Change to the directory where the script is located
    cd "$(dirname "$0")"

    # If there is no log file for the current day, fetch package lists
    if ! compgen -G "log/$(date +'%Y%m%d_*').log" > /dev/null; then
        echo "Fetch package lists..."
        sudo apt-get update
    fi

    # Set up a log folder.
    mkdir -p log
    # Redirect the output to both the log file and the terminal.
    exec > >(tee -a "log/$(date +'%Y%m%d_%H%M%S').log") 2>&1
}
setup_context

# Parse the script arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        "standard")
            SCRIPT_PATH="standard/run.sh"
            shift
            ;;
        "--inhibit-max-delay")
            INHIBIT_MAX_DELAY="$2"
            shift 2
            ;;
        "--apcupsd-device")
            APCUPSD_DEVICE="$2"
            shift 2
            ;;
        "--verbose"|"-v")
            set -x
            shift
            continue
            ;;
        "--help"|"-h")
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [ -z ${SCRIPT_PATH+x} ]; then
    echo "Error: No initialiser specified."
    show_help
    exit 1
fi

# Set the maximum delay for node inhibition to 60 seconds
export NODE_INHIBIT_MAX_DELAY=${INHIBIT_MAX_DELAY:=60}
# Set the APC UPS device (can be a device path or an IP address)
# Possible values: /dev/usb/hiddev0 for a USB device, or 10.1.1.2 for a network device
export NODE_APCUPSD_DEVICE=${APCUPSD_DEVICE:="/dev/usb/hiddev0"}

# Source the lsb-release file to get the distribution information
if test -f /etc/lsb-release; then
    # Export the variables from the lsb-release file to make them available to child scripts
    while IFS='=' read -r key value; do
        export "$key=$value"
    done < /etc/lsb-release
else
    echo "/etc/lsb-release file not found."
    exit 1
fi

# Check the distribution release version
if [ "$DISTRIB_RELEASE" != "22.04" ] && [ "$DISTRIB_RELEASE" != "24.04" ]; then
    echo "The distribution release version $DISTRIB_RELEASE has not been tested."
    echo "Please use version 22.04 or 24.04."
    exit 1
fi

# Check if the script is running as root or if the user has sudo privileges
if [ "$EUID" -ne 0 ]; then
    if ! sudo -v > /dev/null 2>&1; then
        echo "This script requires sudo privileges."
        exit 1
    fi
fi

# Execute the specified initialiser
bash "$SCRIPT_PATH"
echo "Done."