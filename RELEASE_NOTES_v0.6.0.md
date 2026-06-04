# PortVoice v0.6.0 Internal Alpha

## Status

This is the second internal alpha DMG build of PortVoice.

## Main Change

PortVoice now includes configurable notification modes.

## Notification Modes

### Simple Mode

Simple Mode is designed for most users.

It speaks the most useful device name when available.

Example:

- Cadangan connected

This mode avoids unnecessary generic announcements when a better named announcement is available.

### Full Mode

Full Mode speaks every detected event.

Example:

- USB connected
- Cadangan connected

This mode is useful for users who want maximum detail, debugging, or testing.

## Confirmed Working

- PortVoice launches from source using swift run.
- PortVoice launches as PortVoice.app.
- PortVoice opens from a DMG.
- The interface is accessible with VoiceOver.
- Notification Mode picker appears in the app.
- Simple Mode works.
- Full Mode is available.
- USB connection announcements work in Full Mode.
- Named storage announcements work.
- Confirmed example: Cadangan connected.

## Build Improvements

The DMG build script now always rebuilds a fresh app bundle before creating the DMG.

This prevents old PortVoice.app builds from being accidentally packaged into a new DMG.

## Included Scripts

- Scripts/build-app.sh
- Scripts/build-dmg.sh
- Scripts/uninstall-portvoice.sh

## Local DMG Build Path

dist/PortVoice-0.6.0.dmg

## Known Limitations

- Start at login is not implemented yet.
- Menu bar mode is not implemented yet.
- App icon is not implemented yet.
- About window is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.
- Intel Mac support is planned but not guaranteed yet.
- macOS 12 Monterey support is planned but not guaranteed yet.

## Next Priorities

1. Start at Login.
2. Menu Bar Mode.
3. App icon.
4. About window.
5. Universal Apple Silicon and Intel build investigation.
6. Public tester preparation.

## Accessibility Note

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.
