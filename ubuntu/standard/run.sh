#!/usr/bin/env bash

# Check the distribution release version
case "$DISTRIB_RELEASE" in
    "22.04")
        NODE_TIMEZONE="Canada/Eastern"
        NODE_POLKIT="setup-polkit.sh"
        ;;
    "24.04")
        NODE_TIMEZONE="America/New_York"
        NODE_POLKIT="setup-polkit-js.sh"
        ;;
    *)
        echo "The distribution release version $DISTRIB_RELEASE has not been tested."
        exit 1
        ;;
esac

# Change to the directory where the script is located
cd "$(dirname "$0")"

# Run various setup scripts with the appropriate parameters
bash "patch-byobu-ssh.sh"
bash "setup-swappiness.sh"

# Check if the system has been booted with systemd as the init system
if [ -d /run/systemd/system ]; then
    bash "setup-apcupsd.sh" "${NODE_APCUPSD_DEVICE}"
    bash "setup-console-blanking.sh"
    bash "${NODE_POLKIT}"
    bash "setup-systemd.sh" "${NODE_INHIBIT_MAX_DELAY}"
    bash "setup-timezone.sh" "${NODE_TIMEZONE}"
fi