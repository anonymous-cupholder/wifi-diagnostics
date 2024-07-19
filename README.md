# wifi-diagnostics.sh

© 2024 A.K. Aunby

## Overview

`wifi-diagnostics.sh` is a shell script designed to help diagnose and gather information about networking hardware and configurations on GhostBSD systems. It collects various details about the system, including PCI and USB device configurations, kernel modules, and network configuration files, to assist in troubleshooting network issues.

## Usage

### Basic Usage

Set execute privilege for the script:
```
chmod +x wifi-diagnostics.sh
```

Run the script:
```
./wifi-diagnostics.sh
```

### Options

- `-v` : Enable verbose mode. This will provide more detailed output.
- `-i` : Enable interactive mode. This allows you to select which diagnostics to run.

### Example

Run the script in interactive mode:
```
./wifi-diagnostics.sh -i
```

## Diagnostics

The script provides the following diagnostics:

1. **System Information**: Collects basic system information using `uname`.
2. **PCI Devices Configuration**: Lists PCI device configurations using `pciconf`.
3. **USB Devices Configuration**: Lists USB device configurations using `usbconfig`.
4. **Kernel Loaded Modules**: Lists currently loaded kernel modules using `kldstat`.
5. **Output Configuration Files**: Displays contents of key network configuration files (`/boot/loader.conf`, `/etc/rc.conf`, and `/etc/wpa_supplicant.conf`).
6. **Ping Tests**: Performs a series of ping tests to check network connectivity.

### Interactive Mode

In interactive mode, you will be presented with a menu to select the diagnostics you want to run:

```
Select diagnostics to run:
1) System Information
2) PCI Devices Configuration
3) USB Devices Configuration
4) Kernel Loaded Modules
5) Output Configuration Files
6) Ping Tests
7) All of the above
8) Exit
Enter your choice [1-8]: 
```

## Output

The script logs all outputs to the following files:
- `wifi_diagnostic_results.log`: Detailed log file containing all command outputs.
- `wifi_diagnostic_results.txt`: Summary file containing key information.

## Additional Help

For more help, visit the [GhostBSD Telegram group](https://t.me/GhostBSD) or IRC chat group. Post a copy of the outputs to pastebin.com and share the URL link for review.


This `README.md` provides a clear overview of the script, its usage, options, and the diagnostics it performs. It also includes instructions for running the script and a description of the output files.
