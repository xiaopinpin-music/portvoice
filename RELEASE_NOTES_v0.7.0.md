# PortVoice v0.7.0 Internal Alpha

## Status

This is the third internal alpha DMG build of PortVoice.

## Main Change

PortVoice now includes the first version of Menu Bar Mode.

Internal nickname:

- the menu bar

## Menu Bar Features

The first the menu bar build adds a PortVoice menu bar controller with:

- Show PortVoice
- Enable PortVoice / Disable PortVoice
- Quit PortVoice

## Why This Matters

Menu Bar Mode is an important foundation before implementing Start in background at login.

If PortVoice starts silently when the user logs into macOS, the user still needs a simple and VoiceOver-accessible way to control the app.

the menu bar provides that control point.

## Confirmed Working

- PortVoice launches from source using swift run.
- PortVoice launches as PortVoice.app.
- PortVoice opens from DMG.
- Interface is accessible with VoiceOver.
- Notification Mode picker works.
- Simple Mode works.
- Full Mode works.
- Menu bar item appears.
- Menu bar item is readable with VoiceOver.
- Show PortVoice works.
- Enable / Disable works.
- Quit PortVoice works.

## Included Scripts

- Scripts/build-app.sh
- Scripts/build-dmg.sh
- Scripts/uninstall-portvoice.sh

## Local DMG Build Path

dist/PortVoice-0.7.0.dmg

## Known Limitations

- Start in background at login is not implemented yet.
- Background login behavior is planned after menu bar mode.
- App icon is not implemented yet.
- About window is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.
- Intel Mac support is planned but not guaranteed yet.
- macOS 12 Monterey support is planned but not guaranteed yet.

## Next Priorities

1. Start in background at login.
2. App icon / Bekcil mascot direction.
3. About window.
4. Universal Apple Silicon and Intel build investigation.
5. Public tester preparation.

## Accessibility Note

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.
