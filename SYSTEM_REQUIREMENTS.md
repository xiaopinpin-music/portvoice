# PortVoice System Requirements

## Current Alpha Requirement

PortVoice V0.5 Internal Alpha is currently tested on:

- Apple Silicon Mac
- macOS 14 Sonoma or newer
- Latest macOS developer beta environment
- VoiceOver-enabled macOS workflow

## Current Official Minimum

Minimum macOS target:

- macOS 14 Sonoma

This matches the current Swift package platform target:

- .macOS(.v14)

## Recommended Environment

Recommended:

- Apple Silicon Mac
- Latest stable macOS or latest developer beta for testing
- VoiceOver enabled for accessibility testing
- External USB, Thunderbolt, or storage devices for device detection testing

## Intel Mac Support

Intel Mac support is not guaranteed in the current internal alpha.

The current build is developed and tested on Apple Silicon.

Future goal:

- Universal Apple Silicon and Intel Mac build

## Supported Device Types in Current Alpha

Confirmed or targeted in the current alpha:

- USB device connection events
- External storage volumes
- Named storage volume announcements

Confirmed example:

- USB connected
- Cadangan connected

## Planned Device Support

Future versions should improve detection for:

- iPhone and iPad
- Camera and card reader
- Audio interface
- Display / HDMI
- Thunderbolt devices
- More detailed device categories

## Accessibility Requirement

PortVoice must remain usable with VoiceOver.

All controls and documentation should remain clear, linear, and screen-reader friendly.

## Support Policy for Early Testers

Early tester builds should be described honestly.

Do not claim support for systems that have not been tested yet.

Current safe wording:

PortVoice V0.5 Internal Alpha is tested on Apple Silicon Mac with macOS 14 or newer. Intel Mac support is planned but not guaranteed yet.
