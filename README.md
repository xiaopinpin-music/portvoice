# PortVoice

PortVoice is an accessibility-focused macOS application for blind and VoiceOver users.

It provides spoken feedback when useful external devices are connected or disconnected.

## Current Status

PortVoice is currently a working internal alpha.

Current milestone:

- V0.5 Internal Alpha DMG

Confirmed working:

- App launches with swift run
- App launches as PortVoice.app
- DMG installer can be created
- Interface is accessible with VoiceOver
- Test speech works
- USB connected announcements work
- Storage volume announcements work
- Storage volume names can be spoken

Confirmed example:

- USB connected
- Cadangan connected

## Problem

Blind users often cannot easily know whether a USB device, storage device, audio interface, card reader, phone, or display has successfully connected or disconnected.

macOS may show this visually, but blind users need immediate spoken feedback.

## Goal

PortVoice aims to provide immediate spoken feedback when macOS detects useful external devices.

The long-term goal is simple:

Device connected
↓
PortVoice speaks

Examples:

- USB connected
- USB disconnected
- Cadangan connected
- My Book Thunderbolt Duo connected
- Xiao Pinpin Music connected
- iPhone connected
- Audio interface connected
- Display connected

## Current Features

- VoiceOver-friendly SwiftUI interface
- Enable / Disable toggle
- Test speech button
- USB connection monitoring
- USB disconnection monitoring
- Storage volume monitoring
- Named storage announcements
- App bundle build script
- DMG build script
- Uninstall support script

## Build and Run

Run the prototype from source:

swift run

Build the app bundle:

./Scripts/build-app.sh

Build the DMG:

./Scripts/build-dmg.sh

The DMG is created locally at:

dist/PortVoice-0.5.0.dmg

## Uninstall

For early testing, PortVoice includes an uninstall support script:

./Scripts/uninstall-portvoice.sh

Manual uninstall:

1. Quit PortVoice.
2. Delete /Applications/PortVoice.app.

## Roadmap

Next priorities:

1. Reduce duplicate announcements
2. Start at login
3. Menu bar mode
4. App icon
5. About window
6. Release tag v0.5.0

Future features:

- Device categories
- Display detection
- iPhone / iPad detection
- Audio interface detection
- Card reader detection
- Custom aliases
- Custom sounds
- Multiple languages
- Trial and license system

## Accessibility

PortVoice must remain usable with VoiceOver from the beginning.

All user-facing instructions should be clear, linear, and screen-reader friendly.

## License

MIT License.

## Creator

Created by Ko Pinpin / Xiao Pinpin.

PortVoice is built from the lived accessibility needs of blind macOS users.
