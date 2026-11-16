#!/usr/bin/env bash
# Send a Wake-on-LAN magic packet using UDP broadcast

set -euo pipefail

TARGET_MAC="${1:-}"
BROADCAST_IP="${2:-255.255.255.255}"
PORT="${3:-9}"

if [[ -z "$TARGET_MAC" ]]; then
    echo "Usage: $0 <TARGET_MAC> [BROADCAST_IP] [PORT]" >&2
    echo "Example: $0 00:11:22:33:44:55 192.168.1.255 9" >&2
    exit 1
fi

# Check if wakeonlan is installed
if command -v wakeonlan >/dev/null 2>&1; then
    wakeonlan -i "$BROADCAST_IP" -p "$PORT" "$TARGET_MAC"
    exit 0
fi

# Fallback using Python 3
python3 -c '
import socket, sys

mac_str = sys.argv[1].replace(":", "").replace("-", "")
if len(mac_str) != 12:
    raise ValueError("Invalid MAC address length")

broadcast = sys.argv[2]
port = int(sys.argv[3])

mac_bytes = bytes.fromhex(mac_str)
payload = b"\xff" * 6 + mac_bytes * 16

with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    s.sendto(payload, (broadcast, port))
print(f"Magic packet sent to {sys.argv[1]} via {broadcast}:{port}")
' "$TARGET_MAC" "$BROADCAST_IP" "$PORT"
