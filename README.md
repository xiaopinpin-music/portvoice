# PortVoice

PortVoice is an accessibility-focused macOS application for blind and VoiceOver users.

It provides spoken feedback when useful external devices are connected or disconnected.

## Current Status

PortVoice is a working internal release, shared with a small circle of testers.

Current milestone:

- v0.9.1 — universal (Apple Silicon + Intel), macOS 12 Monterey and newer, 42 languages

Confirmed working:

- PortVoice.app runs as a normal macOS app and from the menu bar
- Interface is accessible with VoiceOver
- Device connect and disconnect announcements
- Storage volume announcements, spoken by volume name
- External display connect and disconnect announcements (HDMI, DisplayPort, USB-C)
- Start in background at login
- Announcements and interface follow the Mac's language

Confirmed example:

- Device connected
- Cadangan connected
- Display connected

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

- VoiceOver-first interface with clear labels, hints, and states
- Menu bar mode, with the main window available when needed
- Start in background at login (optional)
- Simple and Full notification modes
- Enable / Disable toggle and a test speech button
- Device connection and disconnection monitoring
- Storage volume monitoring with named announcements
- External display monitoring
- Respects Do Not Disturb and Focus (optional, on by default)
- Spoken voice follows the Mac's language, in 42 languages, using Apple's on-device voices (works offline)
- About window and help
- App bundle, DMG, and uninstall scripts

## Build and Run

Run from source:

swift run

Build the app bundle:

./Scripts/build-app.sh

Build the DMG:

./Scripts/build-dmg.sh

The DMG is created locally at:

dist/PortVoice-<version>.dmg

## Uninstall

For early testing, PortVoice includes an uninstall support script:

./Scripts/uninstall-portvoice.sh

Manual uninstall:

1. Quit PortVoice.
2. Delete /Applications/PortVoice.app.

## Project Documents

- [Design Philosophy](DESIGN_PHILOSOPHY.md)
- [System Requirements](SYSTEM_REQUIREMENTS.md)
- [Support PortVoice](SPONSORS.md)
- [Product Roadmap](PRODUCT_ROADMAP.md)
- [Changelog](CHANGELOG.md)

## Roadmap

Next priorities:

1. Real-world testing with blind and sighted users
2. A simpler, friendlier installation experience
3. Public release

Future features:

- Named announcements for iPhone, iPad, audio interfaces, and card readers (these are announced as "Device" today)
- Device categories
- Custom aliases
- Custom sounds

## Accessibility

PortVoice must remain usable with VoiceOver from the beginning.

All user-facing instructions should be clear, linear, and screen-reader friendly.

## License

The source code is released under the MIT License, so anyone can read it, learn from it, and check that PortVoice does only what it says.

The PortVoice name, the Bekcil mascot, and the app's artwork belong to Xiao Pinpin and are not covered by the MIT License. They may not be used without written permission. You are welcome to learn from the code and build your own app — please give it its own name and its own character.

## Creator

Created by Xiao Pinpin.

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.
