# wifi-diagnostics.sh

© 2024 Anonymous Cupholder

## Purpose

The `wifi-diagnostics.sh` script collects and logs networking information to help diagnose GhostBSD Wi-Fi issues.

## Prerequisites

0. GhostBSD
1. Root access.
2. Required commands: `uname`, `pciconf`, `usbconfig`, `kldstat`, `cat`, `ifconfig`, `ping`, `service`, `killall`, `netstat`, `sockstat`, `wpa_supplicant`.
3. Ensure the script has execute permissions.

## Installation

1. **Download the Script**

    Download the `wifi-diagnostics.sh` script to your local machine.

2. **Set Execute Permissions**

    ```sh
    chmod +x wifi-diagnostics.sh
    ```

## Usage

1. **Run the Script**

    ```sh
    ./wifi-diagnostics.sh
    ```

2. **Output Files**

    The script generates two output files:
    - `wifi_diagnostic_results.log`: Detailed log of the script execution.
    - `wifi_diagnostic_results.txt`: Summary of the diagnostic results.

## Sections in the Script

1. **Operating System Information**
    - Collects OS details using `uname -a`.

2. **PCI Devices Configuration**
    - Lists PCI device details using `pciconf -lv`.

3. **USB Devices Configuration**
    - Lists USB devices and details using `usbconfig list` and `usbconfig dump_device_desc`.

4. **Kernel Loaded Modules**
    - Lists loaded kernel modules using `kldstat`.

5. **Networking Forum Posts and Documentation**
    - Provides links to relevant forum posts and documentation for further reading.

6. **Configuration Files**
    - Outputs the contents of `/boot/loader.conf`, `/etc/rc.conf`, and `/etc/wpa_supplicant.conf`.

7. **Device Creation Command**
    - Provides instructions to create Wi-Fi device.

8. **Firmware Availability Check**
    - Instructions to check firmware availability and loading.

9. **RealTek RTL8188CE Wi-Fi PCI Setup**
    - Specific setup instructions for RealTek RTL8188CE Wi-Fi PCI devices.

10. **Commands for wpa_supplicant and dhclient**
    - Provides commands to run `wpa_supplicant` and `dhclient` manually.

11. **Network Interface and Socket Connections**
    - Lists network interface and socket connections using `netstat` and `sockstat`.

12. **Ping Tests**
    - Runs several `ping` tests to verify network connectivity.

13. **Additional Help**
    - Provides information on where to seek further help (e.g., GhostBSD Telegram group).

## Troubleshooting

- Ensure you have root privileges when running the script.
- Verify all required commands are installed.
- Check the log files for any errors or warnings.

## Notes

- This script is intended for diagnostic purposes only.
- For further assistance, visit the GhostBSD community forums or contact support.
