# PortVoice Uninstall Plan

## Goal

PortVoice must include a clean and simple uninstall path for non-technical users.

The uninstall experience should be clear enough for blind and VoiceOver users.

## Why This Matters

Many users do not know where macOS apps store files.

PortVoice should not make users feel trapped or leave confusing files behind.

## V0.5 Current App

Current build includes:

- PortVoice.app
- DMG installer
- No login item yet
- No license system yet
- No trial system yet
- No helper app yet

Current basic uninstall:

- Quit PortVoice
- Delete `/Applications/PortVoice.app`

## Future Uninstall Targets

When features are added, the uninstaller should clean:

- `/Applications/PortVoice.app`
- Login item / start at login registration
- Menu bar helper if added
- User preferences
- Caches
- Logs
- Local support files
- Trial/license local files when appropriate

## Important Product Rule

PortVoice should provide an uninstall option before giving builds to external testers.

This is especially important for blind users and non-technical users.

## Trial and License Note

When the 15-day trial system exists, uninstall must be designed carefully.

Normal uninstall should remove the app and normal support files.

Trial reset prevention should not depend only on easily deleted local files.

## Planned Uninstall Options

### Option 1: Simple Manual Uninstall

For early testers:

1. Quit PortVoice.
2. Open Applications.
3. Move PortVoice.app to Trash.

### Option 2: Uninstall Script

For support:

- Provide a script named `uninstall-portvoice.sh`.
- It should remove the app and known local PortVoice files.
- It should be readable and simple.

### Option 3: In-App Uninstall Help

Later app versions should include:

- Help menu
- Uninstall instructions
- Link or button to open the uninstall guide

## Accessibility Requirement

Uninstall instructions must be VoiceOver-friendly.

Avoid visual-only instructions.

Use clear step-by-step text.

## Success Condition

A non-technical user can remove PortVoice cleanly without guessing where files are stored.
