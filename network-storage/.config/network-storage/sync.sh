#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="$HOME/.config/network-storage"
CONFIG_FILE="$CONFIG_DIR/config.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config not found at $CONFIG_FILE" >&2
  exit 1
fi
source "$CONFIG_FILE"

MOUNT_PATH="${MOUNT_BASE}/${SMB_SHARE_DOCS}"

# Check if mount is available
if ! mountpoint -q "$MOUNT_PATH" 2>/dev/null; then
  # Try to trigger automount by accessing it
  ls "$MOUNT_PATH" &>/dev/null || true
  sleep 2
  if ! mountpoint -q "$MOUNT_PATH" 2>/dev/null; then
    echo "Documents share not mounted — skipping sync" >&2
    exit 0
  fi
fi

echo "Syncing documents with ${SMB_SERVER}..."
unison network-storage 2>&1 || {
  echo "Sync encountered issues — run 'unison network-storage' manually to resolve" >&2
  exit 1
}
echo "Sync complete at $(date)"
