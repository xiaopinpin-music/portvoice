# Changelog

All notable changes to PortVoice, newest first.

---

## v0.8.0


### Status

This is an internal alpha release focused on background startup behavior.

### Main Change

PortVoice now supports Start in background at login.

When enabled, PortVoice can start automatically after macOS login without opening the main dashboard.

### Confirmed Working

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

### Architecture Improvement

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

### Important Behavior

Manual launch:

- Dashboard appears.
- the menu bar appears.
- User can change settings.

Background login launch:

- the menu bar appears.
- Dashboard does not appear.
- PortVoice keeps listening for device events.

### Known Limitations

- App icon is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.
- Intel Mac support is planned but not guaranteed yet.
- macOS 12 Monterey support is planned but not guaranteed yet.
- Public tester distribution is not started yet.

### Next Priorities

1. App icon / Bekcil visual direction.
2. Tester guide.
3. Clean install and uninstall guide.
4. Universal Apple Silicon and Intel build investigation.
5. Public tester preparation.

### Accessibility Note

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.

---

## v0.7.1


### Status

This is an internal alpha maintenance release after v0.7.0.

### Main Changes

PortVoice now includes an accessible About PortVoice window and clearer branding direction.

### Added

- About PortVoice window
- About PortVoice menu item in the menu bar
- Bekcil mascot wording
- Public creator name cleanup
- Public documentation cleanup to use Xiao Pinpin as the creator name

### About Window Content

The About PortVoice window includes:

- PortVoice
- Version 0.7.1 Internal Alpha
- Created by Xiao Pinpin
- Bekcil, the cheerful little duck helper
- Built from blind Mac user experience
- Designed as a universal accessibility utility for everyone

### Confirmed Working

- PortVoice launches from source using swift run.
- the menu bar menu bar appears.
- About PortVoice opens from the menu bar.
- About text is readable with VoiceOver.
- Show PortVoice works.
- Enable / Disable works.
- Quit PortVoice works.
- Close window keeps PortVoice running.
- Simple Mode works.
- Full Mode works.

### Known Limitations

- Start in background at login is still under investigation.
- SMAppService login item registration currently needs further packaging validation.
- App icon is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.
- Intel Mac support is planned but not guaranteed yet.
- macOS 12 Monterey support is planned but not guaranteed yet.

### Next Priorities

1. App icon / Bekcil visual direction.
2. Continue Start in background at login investigation.
3. Universal Apple Silicon and Intel build investigation.
4. Public tester preparation.

### Accessibility Note

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.

---

## v0.7.0


### Status

This is the third internal alpha DMG build of PortVoice.

### Main Change

PortVoice now includes the first version of Menu Bar Mode.

Internal nickname:

- the menu bar

### Menu Bar Features

The first the menu bar build adds a PortVoice menu bar controller with:

- Show PortVoice
- Enable PortVoice / Disable PortVoice
- Quit PortVoice

### Why This Matters

Menu Bar Mode is an important foundation before implementing Start in background at login.

If PortVoice starts silently when the user logs into macOS, the user still needs a simple and VoiceOver-accessible way to control the app.

the menu bar provides that control point.

### Confirmed Working

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

### Included Scripts

- Scripts/build-app.sh
- Scripts/build-dmg.sh
- Scripts/uninstall-portvoice.sh

### Local DMG Build Path

dist/PortVoice-0.7.0.dmg

### Known Limitations

- Start in background at login is not implemented yet.
- Background login behavior is planned after menu bar mode.
- App icon is not implemented yet.
- About window is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.
- Intel Mac support is planned but not guaranteed yet.
- macOS 12 Monterey support is planned but not guaranteed yet.

### Next Priorities

1. Start in background at login.
2. App icon / Bekcil mascot direction.
3. About window.
4. Universal Apple Silicon and Intel build investigation.
5. Public tester preparation.

### Accessibility Note

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.

---

## v0.6.0


### Status

This is the second internal alpha DMG build of PortVoice.

### Main Change

PortVoice now includes configurable notification modes.

### Notification Modes

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

### Confirmed Working

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

### Build Improvements

The DMG build script now always rebuilds a fresh app bundle before creating the DMG.

This prevents old PortVoice.app builds from being accidentally packaged into a new DMG.

### Included Scripts

- Scripts/build-app.sh
- Scripts/build-dmg.sh
- Scripts/uninstall-portvoice.sh

### Local DMG Build Path

dist/PortVoice-0.6.0.dmg

### Known Limitations

- Start at login is not implemented yet.
- Menu bar mode is not implemented yet.
- App icon is not implemented yet.
- About window is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.
- Intel Mac support is planned but not guaranteed yet.
- macOS 12 Monterey support is planned but not guaranteed yet.

### Next Priorities

1. Start at Login.
2. Menu Bar Mode.
3. App icon.
4. About window.
5. Universal Apple Silicon and Intel build investigation.
6. Public tester preparation.

### Accessibility Note

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.

---

## v0.5.0


### Status

This is the first working internal alpha DMG build of PortVoice.

### Confirmed Working

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

### Included Scripts

- Scripts/build-app.sh
- Scripts/build-dmg.sh
- Scripts/uninstall-portvoice.sh

### Local DMG Build Path

dist/PortVoice-0.5.0.dmg

### Known Limitations

- Duplicate announcements may occur, for example USB connected followed by named storage connected.
- Start at login is not implemented yet.
- Menu bar mode is not implemented yet.
- App icon is not implemented yet.
- About window is not implemented yet.
- The app is not notarized yet.
- Trial and license system is not implemented yet.

### Next Priorities

1. Reduce duplicate announcements.
2. Add start at login.
3. Add menu bar mode.
4. Add app icon.
5. Add About window.
6. Prepare public tester build.

### Accessibility Note

PortVoice is designed from the lived accessibility needs of blind macOS and VoiceOver users.

