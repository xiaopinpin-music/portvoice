#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PortVoice"
APP_PATH="/Applications/${APP_NAME}.app"
BUNDLE_ID="music.xiaopinpin.portvoice"

echo "PortVoice clean uninstall"
echo "Stopping PortVoice if it is running..."

osascript -e 'tell application "PortVoice" to quit' >/dev/null 2>&1 || true
pkill -x "PortVoice" >/dev/null 2>&1 || true

echo "Removing application..."

if [ -d "${APP_PATH}" ]; then
    rm -rf "${APP_PATH}"
    echo "Removed ${APP_PATH}"
else
    echo "Application not found at ${APP_PATH}"
fi

echo "Removing user preferences and support files..."

rm -f "${HOME}/Library/Preferences/${BUNDLE_ID}.plist"
rm -rf "${HOME}/Library/Application Support/${APP_NAME}"
rm -rf "${HOME}/Library/Caches/${BUNDLE_ID}"
rm -rf "${HOME}/Library/Logs/${APP_NAME}"

echo "PortVoice uninstall complete."
echo "If PortVoice is still visible in Finder, empty Trash or restart Finder."
