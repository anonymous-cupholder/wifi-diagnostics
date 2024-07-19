#!/bin/sh

# © 2024 A.K. Aunby

# Ensure the script is running on GhostBSD
if ! grep -q 'ID="ghostbsd"' /etc/os-release; then
    echo "Error: This script is intended for GhostBSD only."
    exit 1
fi

# File paths
LOADER_CONF="/boot/loader.conf"
RC_CONF="/etc/rc.conf"
WPA_SUPPLICANT_CONF="/etc/wpa_supplicant.conf"
LOG_FILE="wifi_diagnostic_results.log"
RESULTS_FILE="wifi_diagnostic_results.txt"
BACKUP_DIR="./backup"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup configuration files
cp "$LOADER_CONF" "$BACKUP_DIR/loader.conf.bak"
cp "$RC_CONF" "$BACKUP_DIR/rc.conf.bak"
cp "$WPA_SUPPLICANT_CONF" "$BACKUP_DIR/wpa_supplicant.conf.bak"

# Output file contents
output_file_contents() {
    local file=$1
    if [ -f "$file" ]; then
        echo -e "\nContents of ${file}:\n" | tee -a "$LOG_FILE" "$RESULTS_FILE"
        cat "$file" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    else
        echo -e "\nError: File ${file} does not exist.\n" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    fi
}

# Print section header
section_header() {
    local header=$1
    echo -e "\n====================" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "$header" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo -e "====================\n" | tee -a "$LOG_FILE" "$RESULTS_FILE"
}

# Check if a command exists
check_command() {
    local cmd=$1
    if ! command -v "$cmd" > /dev/null; then
        echo "Error: Command not found: $cmd. Please install it." | tee -a "$LOG_FILE" "$RESULTS_FILE"
        exit 1
    fi
}

# Check if the script is run as root
check_root() {
    if [ "$(id -u)" -ne 0; then
        echo "Error: Run this script as root." | tee -a "$LOG_FILE" "$RESULTS_FILE"
        exit 1
    fi
}

# Run a command and log its output
run_and_log() {
    local cmd="$1"
    echo -e "\nRunning: $cmd\n" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    eval "$cmd" 2>&1 | tee -a "$LOG_FILE" "$RESULTS_FILE"
}

# Display usage information
display_usage() {
    echo "Usage: $0 [-v]" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Collects info to get networking working on your hardware." | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Set execute privilege: chmod +x wifi-diagnostics.sh" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Run: wifi-diagnostics.sh" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Options: -v  Enable verbose mode" | tee -a "$LOG_FILE" "$RESULTS_FILE"
}

# Parse command-line options
VERBOSE=0
while getopts "v" opt; do
    case $opt in
        v)
            VERBOSE=1
            ;;
        *)
            display_usage
            exit 1
            ;;
    esac
done

# Ensure required commands are available
required_commands="uname pciconf usbconfig kldstat cat ifconfig ping service killall netstat sockstat wpa_supplicant"
for cmd in $required_commands; do
    check_command "$cmd"
done

# Ensure the script is run as root
check_root

# Clear log files
> "$LOG_FILE"
> "$RESULTS_FILE"

# Set execute privilege for the script
chmod +x "$0"

# Display usage information
display_usage

# System information
section_header "Operating System Information"
run_and_log "uname -a"

# PCI devices configuration
section_header "PCI Devices Configuration List (verbose)"
run_and_log "pciconf -lv"

# USB devices configuration
section_header "USB Devices Configuration List"
run_and_log "usbconfig list"
run_and_log "usbconfig dump_device_desc"

# Kernel loaded modules
section_header "Kernel Loaded Modules"
run_and_log "kldstat"

# Forum posts and documentation
section_header "Networking Forum Posts and Documentation"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
Read Networking Forum posts at https://forums.ghostbsd.org/viewtopic.php?f=64&t=16
USB wifi device Edimax EW-7811 post & PCI wifi device RTL8188CE post:
PCI device RealTek RTL8188CE: https://forums.ghostbsd.org/viewtopic.php?f=64&t=570
USB device Edimax EW-7811un: https://forums.ghostbsd.org/viewtopic.php?f=64&t=526

Refer to PDF files at /usr/share/doc/?xxxx? for wifi setup examples.
EOF

# Output configuration files
output_file_contents "$LOADER_CONF"
output_file_contents "$RC_CONF"
output_file_contents "$WPA_SUPPLICANT_CONF"

# Device creation instructions
section_header "Device Creation Command"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
Create your device with:
ifconfig wlan0 create wlandev rtwn0

Or use the -HT option:
ifconfig -HT wlan0 create wlandev rtwn0

Substitute <your device name> for rtwn0.
EOF

# Firmware availability
section_header "Firmware Availability Check"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
Is the firmware for your wifi device available in this directory ?xxxx?
Did it load into your wifi device?
Did you acknowledge the Copyright Notice in /boot/loader.conf?
EOF

# Configuration for RealTek RTL8188CE
section_header "RealTek RTL8188CE Wi-Fi PCI Setup"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
Refer to GhostBSD Forums post: https://forums.ghostbsd.org/viewtopic.php?f=64&t=570

Add these lines to /boot/loader.conf:
boot_verbose="YES"
# verbose_loading="YES"
kld_list="geom_mirror geom_journal geom_eli linux if_rtwn_pci if_rtwn"
# add if_rtwn and if_rtwn_pci to kld_list
# if_wlan_load="YES"
if_rtwn_pci_load="YES"
if_rtwn_load="YES"
rtwn-rtl8192cfwE_B_load="YES"
rtwn-rtl8192cfwE_load="YES"
legal.realtek.license_ack=1

Add these lines to /etc/rc.conf:
wlans_rtwn0="wlan0"
ifconfig_wlan0="WPA SYNCDHCP"

Add to /etc/wpa_supplicant.conf:
network={
    ssid="innflux"
    key_mgmt=NONE
}
EOF

# Commands for wpa_supplicant and dhclient
section_header "Commands for wpa_supplicant and dhclient"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
Manually run:
killall dhclient
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf
dhclient wlan0

For debugging, use:
killall dhclient
service netif restart
service routing restart
wpa_supplicant -d -K -i wlan0 -c /etc/wpa_supplicant.conf
dhclient wlan0

If dhclient fails, kill it and try again:
killall dhclient
dhclient wlan0
EOF

# Network interface and socket connections
section_header "Network Interface and Socket Connections"
run_and_log "netstat -r"
run_and_log "netstat -i"
run_and_log "sockstat -4"

# Ping tests
section_header "Ping Tests"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
Ping Google DNS 3 times:
ping -c 3 8.8.8.8

Ping OpenDNS 3 times:
ping -c 3 208.67.222.222

Ping Hurricane Electric 3 times:
ping -c 3 he.net

Ping OpenNic DNS in Colorado:
ping -c 3 63.231.92.27

Sometimes restart network interfaces and routing after editing /etc/rc.conf or /etc/wpa_supplicant.conf:
service netif restart && service routing restart
EOF

# Additional help
section_header "Additional Help"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
For more help, visit the GhostBSD Telegram group: https://t.me/GhostBSD or IRC chat group.
Post a copy of these outputs to pastebin.com and share the URL link for review.
EOF
