# wifi-diagnostics.sh

© 2024 Anonymous Cupholder

## Overview

`wifi-diagnostics.sh` is a shell script designed to help diagnose and gather information about networking hardware and configurations on GhostBSD systems. It collects various details about the system, including PCI and USB device configurations, kernel modules, and network configuration files, to assist in troubleshooting network issues.

## Usage

### Basic Usage

Set execute privilege for the script:
```sh
chmod +x wifi-diagnostics.sh
```

Run the script:
```sh
./wifi-diagnostics.sh
```

### Options

- `-v` : Enable verbose mode. This will provide more detailed output.
- `-i` : Enable interactive mode. This allows you to select which diagnostics to run.

### Example

Run the script in interactive mode:
```sh
sudo ./wifi-diagnostics.sh -i
```

## Diagnostics

The script provides the following diagnostics:

1. **List Network Interfaces**: Lists all available network interfaces using `ifconfig -a`.
2. **Check Wi-Fi Connection Status**: Checks the status of the Wi-Fi connection using `ifconfig wlan0` and `wpa_cli status`.
3. **Ping Tests**: Performs a series of ping tests to check network connectivity.
4. **DNS Resolution Test**: Tests DNS resolution using `drill`.
5. **Gateway Reachability Test**: Tests the reachability of the default gateway using `ping`.
6. **Output Configuration Files**: Displays contents of key network configuration files (`/boot/loader.conf`, `/etc/rc.conf`, and `/etc/wpa_supplicant.conf`).
7. **Kernel Loaded Modules**: Lists currently loaded kernel modules using `kldstat`.
8. **USB Devices Configuration**: Lists USB device configurations using `usbconfig`.
9. **PCI Devices Configuration**: Lists PCI device configurations using `pciconf`.
10. **System Information**: Collects basic system information using `uname`.
11. **All of the above**: Run all diagnostics.
12. **Exit**: Exit the script.

### Interactive Mode

In interactive mode, you will be presented with a menu to select the diagnostics you want to run:

```
Select diagnostics to run:
1) List Network Interfaces
2) Check Wi-Fi Connection Status
3) Ping Tests
4) DNS Resolution Test
5) Gateway Reachability Test
6) Output Configuration Files
7) Kernel Loaded Modules
8) USB Devices Configuration
9) PCI Devices Configuration
10) System Information
11) All of the above
12) Exit
Enter your choice [1-12]: 
```

## Output

The script logs all outputs to the following files:
- `wifi_diagnostic_results.log`: Detailed log file containing all command outputs.
- `wifi_diagnostic_results.txt`: Summary file containing key information.

## Additional Help

For more help, visit the [GhostBSD Telegram group](https://t.me/GhostBSD) or IRC chat group. Post a copy of these outputs to pastebin.com and share the URL link for review.
