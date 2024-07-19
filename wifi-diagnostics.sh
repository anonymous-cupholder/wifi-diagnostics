#!/bin/sh

# © 2024 Anonymous Cupholder

# Ensure the script is running on GhostBSD
if ! grep -q 'ID="ghostbsd"' /etc/os-release; then
    echo "Error: This script is intended for GhostBSD only."
    exit 1
fi

# File paths
LOADER_CONF="/boot/loader.conf"
RC_CONF="/etc/rc.conf"
WPA_SUPPLICANT_CONF="/etc/wpa_supplicant.conf"
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/wifi_diagnostic_results.log"
RESULTS_FILE="$LOG_DIR/wifi_diagnostic_results.txt"
BACKUP_DIR="./backup"

# Create necessary directories
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

# Log rotation
rotate_logs() {
    if [ -f "$LOG_FILE" ]; then
        mv "$LOG_FILE" "$LOG_FILE.$(date +'%Y%m%d%H%M%S')"
    fi
    if [ -f "$RESULTS_FILE" ]; then
        mv "$RESULTS_FILE" "$RESULTS_FILE.$(date +'%Y%m%d%H%M%S')"
    fi
}

# Rotate logs to avoid overwriting
rotate_logs

# Backup configuration files
backup_file() {
    local file=$1
    local backup="$BACKUP_DIR/$(basename "$file").bak"
    if [ -f "$file" ]; then
        cp "$file" "$backup"
        echo "Backup of $file created at $backup" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    fi
}

backup_file "$LOADER_CONF"
backup_file "$RC_CONF"
backup_file "$WPA_SUPPLICANT_CONF"

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
    if [ "$VERBOSE" -eq 1 ]; then
        eval "$cmd" 2>&1 | tee -a "$LOG_FILE" "$RESULTS_FILE"
    else
        eval "$cmd" 2>&1 | tee -a "$LOG_FILE" "$RESULTS_FILE"
    fi
}

# Display usage information
display_usage() {
    echo "Usage: $0 [-v] [-i]" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Collects info to get networking working on your hardware." | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Set execute privilege: chmod +x wifi-diagnostics.sh" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Run: wifi-diagnostics.sh" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "Options:" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "  -v  Enable verbose mode" | tee -a "$LOG_FILE" "$RESULTS_FILE"
    echo "  -i  Enable interactive mode" | tee -a "$LOG_FILE" "$RESULTS_FILE"
}

# Restart network services
restart_network_services() {
    section_header "Restarting Network Services"
    run_and_log "service netif restart"
    run_and_log "service routing restart"
}

# Interactive mode menu
interactive_menu() {
    echo -e "\n"
    echo "Select diagnostics to run:"
    echo "1) List Network Interfaces"
    echo "2) Check Wi-Fi Connection Status"
    echo "3) Ping Tests"
    echo "4) DNS Resolution Test"
    echo "5) Gateway Reachability Test"
    echo "6) Output Configuration Files"
    echo "7) Kernel Loaded Modules"
    echo "8) USB Devices Configuration"
    echo "9) PCI Devices Configuration"
    echo "10) System Information"
    echo "11) Restart Network Services"
    echo "12) All of the above"
    echo "13) Exit"
    echo -n "Enter your choice [1-13]: "
    read -r choice
    return $choice
}

# Parse command-line options
VERBOSE=0
INTERACTIVE=0
while getopts "vi" opt; do
    case "$opt" in
        v)
            VERBOSE=1
            ;;
        i)
            INTERACTIVE=1
            ;;
        *)
            display_usage
            exit 1
            ;;
    esac
done

# Ensure required commands are available
required_commands="uname pciconf usbconfig kldstat cat ifconfig ping service killall netstat sockstat wpa_supplicant drill"
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

# Function to run all diagnostics
run_all_diagnostics() {
    list_network_interfaces
    check_wifi_status
    ping_tests
    dns_resolution_test
    gateway_reachability_test
    output_configuration_files
    kernel_loaded_modules
    usb_devices_configuration
    pci_devices_configuration
    system_information
    restart_network_services
}

# Functions for diagnostics
list_network_interfaces() {
    section_header "Available Network Interfaces"
    run_and_log "ifconfig -a"
}

check_wifi_status() {
    section_header "Wi-Fi Connection Status"
    run_and_log "ifconfig wlan0"
    run_and_log "wpa_cli status"
}

ping_tests() {
    section_header "Ping Tests"
    run_and_log "ping -c 3 8.8.8.8"
    run_and_log "ping -c 3 208.67.222.222"
    run_and_log "ping -c 3 he.net"
    run_and_log "ping -c 3 63.231.92.27"
}

dns_resolution_test() {
    section_header "DNS Resolution Test"
    run_and_log "drill google.com"
}

gateway_reachability_test() {
    section_header "Gateway Reachability Test"
    GATEWAY=$(netstat -rn | grep '^default' | awk '{print $2}')
    if [ -n "$GATEWAY" ]; then
        run_and_log "ping -c 3 $GATEWAY"
    else
        echo "No default gateway found." | tee -a "$LOG_FILE" "$RESULTS_FILE"
    fi
}

output_configuration_files() {
    output_file_contents "$LOADER_CONF"
    output_file_contents "$RC_CONF"
    output_file_contents "$WPA_SUPPLICANT_CONF"
}

kernel_loaded_modules() {
    section_header "Kernel Loaded Modules"
    run_and_log "kldstat"
}

usb_devices_configuration() {
    section_header "USB Devices Configuration List"
    run_and_log "usbconfig list"
    run_and_log "usbconfig dump_device_desc"
}

pci_devices_configuration() {
    section_header "PCI Devices Configuration List (verbose)"
    run_and_log "pciconf -lv"
}

system_information() {
    section_header "Operating System Information"
    run_and_log "uname -a"
}

# Interactive mode
if [ "$INTERACTIVE" -eq 1 ]; then
    while true; do
        interactive_menu
        choice=$?
        case "$choice" in
            1)
                list_network_interfaces
                ;;
            2)
                check_wifi_status
                ;;
            3)
                ping_tests
                ;;
            4)
                dns_resolution_test
                ;;
            5)
                gateway_reachability_test
                ;;
            6)
                output_configuration_files
                ;;
            7)
                kernel_loaded_modules
                ;;
            8)
                usb_devices_configuration
                ;;
            9)
                pci_devices_configuration
                ;;
            10)
                system_information
                ;;
            11)
                restart_network_services
                ;;
            12)
                run_all_diagnostics
                ;;
            13)
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 13."
                ;;
        esac
    done
else
    # Run all diagnostics if not in interactive mode
    run_all_diagnostics
fi

# Additional help
section_header "Additional Help"
cat <<EOF | tee -a "$LOG_FILE" "$RESULTS_FILE"
For more help, visit the GhostBSD Telegram group: https://t.me/GhostBSD or IRC chat group.
Post a copy of these outputs to pastebin.com and share the URL link for review.
EOF
