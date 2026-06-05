#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PortVoice"
BUILD_DIR=".build/release"
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building ${APP_NAME} release binary..."
swift build -c release

echo "Creating app bundle..."
rm -rf "dist"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"

cat > "${CONTENTS_DIR}/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>PortVoice</string>
    <key>CFBundleDisplayName</key>
    <string>PortVoice</string>
    <key>CFBundleIdentifier</key>
    <string>com.xiaopinpinmusic.portvoice</string>
    <key>CFBundleVersion</key>
    <string>0.8.0</string>
    <key>CFBundleShortVersionString</key>
    <string>0.8.0</string>
    <key>CFBundleExecutable</key>
    <string>PortVoice</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "Created ${APP_DIR}"
