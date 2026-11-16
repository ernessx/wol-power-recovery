#!/usr/bin/env bash
# Execute a controlled shutdown with an RTC wake alarm fallback

set -euo pipefail

DELAY_SECONDS=45
WAKE_TIMEOUT_SECONDS=240

echo "=== Fallback RTC Wake-on-LAN Test ==="
echo "Scheduling system shutdown in ${DELAY_SECONDS} seconds."
echo "RTC fallback alarm will trigger in ${WAKE_TIMEOUT_SECONDS} seconds."
echo "Ensure your server remains connected to AC power."

sudo systemd-run --on-active="${DELAY_SECONDS}" /usr/sbin/rtcwake -m off -s "${WAKE_TIMEOUT_SECONDS}"

echo "Scheduled successfully. Monitor server power-off and transmit the magic packet within ~60 seconds."
