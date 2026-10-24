# PortVoice System Requirements

## Minimum Requirements

PortVoice runs on:

- macOS 11 Big Sur or newer
- Apple Silicon (arm64) or Intel (x86_64) Mac — the build is universal
- A VoiceOver-friendly workflow

## Swift Package Target

The build pins an explicit deployment floor:

- macOS 11 Big Sur (built per architecture as `arm64-apple-macosx11.0` and `x86_64-apple-macosx11.0`)

## Recommended Environment

- A recent stable macOS, or a developer beta for forward testing
- VoiceOver enabled for accessibility testing
- External USB, Thunderbolt, or storage devices for device-detection testing

## Architecture Support

PortVoice ships as a universal binary:

- Apple Silicon (arm64)
- Intel (x86_64)

Both architectures are built with a macOS 11 Big Sur minimum, so the app runs natively on Intel and Apple Silicon Macs from Big Sur onward. This matters for many blind, low-vision, Indonesian, and older-Mac users who still rely on Intel Macs and earlier macOS versions.

## Language Support

Announcements and the interface follow the Mac's language automatically, in 42 languages:

Arabic, Catalan, Chinese (Simplified, Traditional, Hong Kong), Croatian, Czech, Danish, Dutch, English (US, Australia, Canada, Philippines, UK), Finnish, French (France, Canada), German, Greek, Hebrew, Hindi, Hungarian, Indonesian, Italian, Japanese, Korean, Malay, Norwegian, Polish, Portuguese (Brazil, Portugal), Romanian, Russian, Slovak, Slovenian, Spanish (Spain, Latin America), Swedish, Thai, Turkish, Ukrainian, and Vietnamese.

The spoken voice adapts to the Mac's preferred language with no configuration, using Apple's on-device voices, so it works offline. Additional languages can be added by translating the bundled strings.

## Supported Device Types

- USB device connection and disconnection events
- External storage volumes, including named-volume announcements
- External displays / HDMI connect and disconnect

## Planned Device Support

These devices are already announced today as "Device connected" and "Device disconnected". Future versions aim to announce them by name and category:

- iPhone and iPad
- Camera and card reader
- Audio interface
- Thunderbolt devices
- More detailed device categories

## Accessibility Requirement

PortVoice must remain fully usable with VoiceOver. All controls and documentation stay clear, linear, and screen-reader friendly.

## Honest Support Wording

PortVoice is tested primarily on Apple Silicon with the latest macOS, currently macOS 27.2. The universal build targets macOS 11 Big Sur and newer on both Apple Silicon and Intel Macs. Device-detection coverage continues to expand, and only tested behavior is described as working.
