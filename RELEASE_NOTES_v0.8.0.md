# PortVoice v0.8.0 Internal Alpha

## Status

This is an internal alpha release focused on background startup behavior.

## Main Change

PortVoice now supports Start in background at login.

When enabled, PortVoice can start automatically after macOS login without opening the main dashboard.

## Confirmed Working

- Start in background at login checkbox works.
- Background startup uses a user LaunchAgent.
- PortVoice starts from /Applications with the --background argument.
- the menu bar appears in the menu bar after login.
- Empty dashboard/window no longer appears during background launch.
- Storage disconnect announcements work.
- Storage connect announcements work.
- Voice output is no longer duplicated after ensuring only one PortVoice background process is running.
- Turning off Start in background at login removes the LaunchAgent.
- PortVoice can be disabled without uninstalling the app.

## Architecture Improvement

PortVoice now uses a two-layer structure:

Layer 1:

- AppRuntime
- the menu bar menu bar
- Device monitoring
- Speech coordination

Layer 2:

- Dashboard / ContentView
- User controls
- Status display

This makes PortVoice more suitable as a real background macOS utility.

## Important Behavior

Manual launch:

- Dashboard appears.
- the menu bar appears.
- User can change settings.

Background login launch:

- the menu bar appears.
- Dashboard does not appear.
- PortVoice keeps listening for device events.

## Known Limitations

- App icon is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.
- Intel Mac support is planned but not guaranteed yet.
- macOS 12 Monterey support is planned but not guaranteed yet.
- Public tester distribution is not started yet.

## Next Priorities

1. App icon / Bekcil visual direction.
2. Tester guide.
3. Clean install and uninstall guide.
4. Universal Apple Silicon and Intel build investigation.
5. Public tester preparation.

## Accessibility Note

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.
