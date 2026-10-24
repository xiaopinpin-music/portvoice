# PortVoice Product Roadmap

## Philosophy

PortVoice should be useful for blind users, low-vision users, musicians, creators, power users, and general Mac users.

Accessibility should not require a separate reduced experience.

Users should be able to choose the amount of spoken feedback they prefer.

## Notification Modes

### Simple Mode

Fast, clear, and useful for most users.

Speak the most useful device name when available.

Example:

- Cadangan connected

Simple Mode should avoid unnecessary generic announcements when a better named announcement is available.

### Full Mode

Speak every detected event.

Example:

- USB connected
- Cadangan connected

Full Mode is useful for users who want more detail, debugging, testing, or maximum confirmation.

## Product Decision

The app should not force one notification style on every user.

The current public direction is:

- Simple Mode for most users
- Full Mode for users who want every detail

The final default behavior should still be validated with real tester feedback.

## Completed

V0.5.0
- Internal Alpha DMG

V0.6.0
- Notification Modes (Simple and Full)

V0.7.0
- Menu Bar Mode
- About window

V0.8.0
- Start in background at login
- External display detection
- Generic device announcements

V0.9.0
- Adaptive voice that follows the Mac's language
- 42 languages
- Respect Do Not Disturb and Focus
- Redesigned VoiceOver-first window
- Universal binary (Apple Silicon and Intel)

V0.9.1
- Minimum macOS is now 12 Monterey
- Cleaner app bundle that relies only on the Swift runtime built into macOS

## Next

V1.0.0
- Public release
- Friendlier installation for blind and sighted users

Later
- Named announcements for iPhone, iPad, audio interfaces, and card readers
- Device categories
