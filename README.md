# Headless Server Wake-on-LAN Power Recovery

> Step-by-step guide: **[Restoring Remote Wake-on-LAN on Headless Linux Servers Without BIOS Displays](https://erness.dev/tutorials/wol-power-recovery/)**. The guide explains the why behind each file, the safety notes and what went wrong along the way.

This repository provides configuration files and helper scripts to enable persistent Wake-on-LAN (WoL) on headless Linux servers without requiring a physical monitor or BIOS changes.

## Overview

Many headless servers lack integrated graphics, making it difficult to adjust BIOS power management settings such as AC power loss recovery. Furthermore, attempting to modify LPC chipset registers (such as `GEN_PMCON_3`) using `setpci` often fails because the motherboard BIOS rewrites these registers during POST or shutdown.

This project provides:
- A systemd oneshot service to persistently arm your Ethernet interface for Magic Packet reception (`ethtool -s <iface> wol g`).
- A safe testing script combining `rtcwake` fallback alarms with controlled shutdowns.
- Cross-platform wake scripts (Bash and PowerShell) to remotely power on your server.

## Requirements

- Headless Linux server with root or sudo access.
- Wired Ethernet connection supporting Magic Packet Wake-on-LAN.
- Installed packages on the server: `ethtool`, `pciutils`, `util-linux`.
- A client machine (Linux, macOS, or Windows) on the same local subnet to send magic packets.

## Installation

1. Copy the systemd service template to your system directory:
   ```bash
   sudo cp systemd/server-wol.service /etc/systemd/system/server-wol.service
   ```

2. Edit `/etc/systemd/system/server-wol.service` and replace `YOUR_INTERFACE` with your actual network device name (e.g. `eth0` or `enp9s0`):
   ```bash
   ip link show
   sudo nano /etc/systemd/system/server-wol.service
   ```

3. Reload systemd and enable the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now server-wol.service
   ```

4. Verify that Wake-on-LAN is armed:
   ```bash
   ethtool YOUR_INTERFACE | grep Wake
   ```
   The output should show `Wake-on: g`.

## Testing Wake-on-LAN Safely

To test remote wake-up without getting locked out of your server if the magic packet fails, run the RTC fallback test script:

```bash
sudo ./scripts/test-rtcwake-fallback.sh
```

This arms an RTC wake alarm 4 minutes into the future and shuts the server down. Send a magic packet from your client device using `scripts/send-wol.sh` or `scripts/send-wol.ps1` within 2 minutes. If Wake-on-LAN succeeds, your server boots immediately. If it fails, the RTC alarm powers the server back on automatically.
