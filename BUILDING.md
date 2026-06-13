# Building PortVoice

## Requirements

To build PortVoice you need:

- A recent Xcode with the Swift toolchain (Swift 5.10 or newer)
- A build machine new enough to run that Xcode

The built app itself runs on:

- macOS 11 Big Sur or newer
- Apple Silicon (arm64) or Intel (x86_64) — the release build is universal

VoiceOver is recommended for accessibility testing.

## Quick Build (debug)

From the repository root:

    swift build

This compiles a debug binary for the current architecture — useful for fast iteration.

## App Bundle (release, universal)

    bash Scripts/build-app.sh

This produces `dist/PortVoice.app` as a universal binary (Apple Silicon + Intel), with each architecture pinned to a macOS 11 Big Sur deployment target, localized resources bundled inside the app, and an ad-hoc code signature.

## Disk Image (DMG)

    bash Scripts/build-dmg.sh

This rebuilds the app and packages `dist/PortVoice-<version>.dmg` with an Applications symlink for drag-to-install.

## Localization

User-facing announcements and interface strings live in:

- `Sources/PortVoice/Resources/en.lproj/Localizable.strings`
- `Sources/PortVoice/Resources/id.lproj/Localizable.strings`

They are loaded from the package resource bundle (`Bundle.module`) and follow the Mac's language. Add a language by creating a new `<code>.lproj/Localizable.strings`.

## Implemented

- App entry point, main window, and menu bar item
- Enable / disable control and status area
- Adaptive speech service — follows the Mac's language and respects Do Not Disturb
- USB device connection and disconnection detection
- External storage volume detection, including named-volume announcements
- External display / HDMI connect and disconnect detection
- Start in background at login
- English and Indonesian localization

## Notes

- The deployment floor is pinned per architecture (`arm64-apple-macosx11.0` and `x86_64-apple-macosx11.0`) and combined with `lipo`, because the toolchain otherwise raises the minimum automatically.
- `dist/` is a build-artifact directory and is not tracked in git.
