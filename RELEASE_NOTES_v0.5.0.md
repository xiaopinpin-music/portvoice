# PortVoice v0.5.0 Internal Alpha

## Status

This is the first working internal alpha DMG build of PortVoice.

## Confirmed Working

- PortVoice launches from source using swift run.
- PortVoice launches as PortVoice.app.
- PortVoice opens from a DMG.
- The interface is accessible with VoiceOver.
- Test speech works.
- USB connection announcements work.
- Storage volume detection works.
- Named storage announcements work.

Confirmed example:

- USB connected
- Cadangan connected

## Included Scripts

- Scripts/build-app.sh
- Scripts/build-dmg.sh
- Scripts/uninstall-portvoice.sh

## Local DMG Build Path

dist/PortVoice-0.5.0.dmg

## Known Limitations

- Duplicate announcements may occur, for example USB connected followed by named storage connected.
- Start at login is not implemented yet.
- Menu bar mode is not implemented yet.
- App icon is not implemented yet.
- About window is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.

## Next Priorities

1. Reduce duplicate announcements.
2. Add start at login.
3. Add menu bar mode.
4. Add app icon.
5. Add About window.
6. Prepare public tester build.

## Accessibility Note

PortVoice is designed from the lived accessibility needs of blind macOS and VoiceOver users.
