#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PortVoice"
APP_VERSION="0.9.0"
MIN_MACOS="11.0"
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

# Build each architecture with an explicit macOS 11 (Big Sur) deployment target.
# The default package floor is silently raised by the toolchain, so the explicit
# -target is what actually pins the minimum OS to Big Sur. Both --arch builds emit
# to the same path, so each binary is copied out before the next build overwrites it.
echo "Building ${APP_NAME} ${APP_VERSION} — arm64 @ macOS ${MIN_MACOS}..."
swift build -c release --arch arm64 -Xswiftc -target -Xswiftc "arm64-apple-macosx${MIN_MACOS}"
ARM_DIR="$(swift build -c release --arch arm64 -Xswiftc -target -Xswiftc "arm64-apple-macosx${MIN_MACOS}" --show-bin-path)"
cp "${ARM_DIR}/${APP_NAME}" "${TMP}/${APP_NAME}-arm64"
if [ -d "${ARM_DIR}/${APP_NAME}_${APP_NAME}.bundle" ]; then
    cp -R "${ARM_DIR}/${APP_NAME}_${APP_NAME}.bundle" "${TMP}/bundle"
fi

echo "Building ${APP_NAME} ${APP_VERSION} — x86_64 @ macOS ${MIN_MACOS}..."
swift build -c release --arch x86_64 -Xswiftc -target -Xswiftc "x86_64-apple-macosx${MIN_MACOS}"
X86_DIR="$(swift build -c release --arch x86_64 -Xswiftc -target -Xswiftc "x86_64-apple-macosx${MIN_MACOS}" --show-bin-path)"
cp "${X86_DIR}/${APP_NAME}" "${TMP}/${APP_NAME}-x86_64"

echo "Creating app bundle..."
rm -rf "dist"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Universal executable (Intel + Apple Silicon) via lipo.
lipo -create "${TMP}/${APP_NAME}-arm64" "${TMP}/${APP_NAME}-x86_64" -output "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Localized resources (en / id ...). Required so announcements and the UI follow
# the Mac's language inside the packaged app. Identical across architectures.
if [ -d "${TMP}/bundle" ]; then
    cp -R "${TMP}/bundle" "${RESOURCES_DIR}/${APP_NAME}_${APP_NAME}.bundle"
    echo "  bundled localizations: ${APP_NAME}_${APP_NAME}.bundle"
else
    echo "  WARNING: resource bundle not found — localizations may be missing"
fi

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
    <string>${APP_VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleExecutable</key>
    <string>PortVoice</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MIN_MACOS}</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "Signing (ad-hoc)..."
codesign --force --deep --sign - "${APP_DIR}"

echo "Created ${APP_DIR} (universal arm64+x86_64, ${APP_VERSION}, min macOS ${MIN_MACOS})"