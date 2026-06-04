#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PortVoice"
VERSION="0.6.0"
DIST_DIR="dist"
APP_PATH="${DIST_DIR}/${APP_NAME}.app"
DMG_PATH="${DIST_DIR}/${APP_NAME}-${VERSION}.dmg"
DMG_ROOT="${DIST_DIR}/dmg-root"

if [ ! -d "${APP_PATH}" ]; then
    echo "PortVoice.app not found. Building app first..."
    ./Scripts/build-app.sh
fi

echo "Preparing DMG folder..."
rm -rf "${DMG_ROOT}"
mkdir -p "${DMG_ROOT}"

cp -R "${APP_PATH}" "${DMG_ROOT}/"

ln -s /Applications "${DMG_ROOT}/Applications"

rm -f "${DMG_PATH}"

echo "Creating DMG..."
hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${DMG_ROOT}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

echo "Created ${DMG_PATH}"
