#!/bin/bash
# Install keyd config for left/right Alt -> Muhenkan/Henkan (Japanese IME toggle).
# Requires keyd (https://github.com/rvaiya/keyd) to already be installed.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script with sudo." >&2
  exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/etc-keyd"

install -m 644 "$SRC_DIR/common" /etc/keyd/common
install -m 644 "$SRC_DIR/default.conf" /etc/keyd/default.conf
install -m 644 "$SRC_DIR/japanese-external.conf" /etc/keyd/japanese-external.conf

echo "Installed configs to /etc/keyd/. Checking syntax..."
keyd check

echo "Restarting keyd..."
systemctl restart keyd
systemctl status keyd --no-pager -l | head -8

cat <<'EOF'

Note: default.conf excludes internal keyboard id 0001:0001 (the standard
i8042 "AT Translated Set 2 keyboard" id most laptops use). If your machine's
internal keyboard has a different vendor:product id, run:

    grep -A6 "keyboard" /proc/bus/input/devices

and update the "-0001:0001" line in /etc/keyd/default.conf accordingly.
EOF
