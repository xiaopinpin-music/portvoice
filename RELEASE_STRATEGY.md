# PortVoice Release Strategy

## Current Release Status

PortVoice is currently at:

- V0.5.0 Internal Alpha DMG

This build is working, but it is not a public commercial release yet.

## Current Build

Local DMG build path:

- dist/PortVoice-0.5.0.dmg

Current confirmed behavior:

- PortVoice.app launches
- DMG opens
- Interface is accessible with VoiceOver
- USB announcements work
- Named storage announcements work
- Example: Cadangan connected

## Public DMG Policy

Do not upload the DMG as a public unrestricted download yet.

Reason:

- The trial system is not implemented yet.
- The license system is not implemented yet.
- The app is not notarized yet.
- The notification behavior still needs tester feedback.
- The uninstall flow must be tested with real users.

The repository can remain public and open-source.

The DMG should be shared carefully with selected testers first.

## Tester Groups

### Family / Close Personal Users

Status:

- Free license
- Can help test basic usability
- Good for trusted feedback

Purpose:

- Find obvious issues
- Confirm installation and uninstall flow
- Confirm device announcement behavior

### Blind and Low-Vision Testers

Status:

- Limited 15-day trial
- Manual access at first

Purpose:

- Test real VoiceOver usage
- Test announcement clarity
- Test whether Full, Simple, or Simple notification mode is best
- Test install and uninstall instructions

### Non-Disabled Mac Users

Status:

- Limited tester access

Purpose:

- Confirm universal usability
- Test whether PortVoice is useful beyond blindness
- Give feedback on whether announcements are too verbose or useful

### Early Supporters

Possible early supporter price:

- an early-supporter price for selected early supporters
- a standard price for later new users

Final pricing should be decided after feedback.

## Trial Strategy

Initial trial strategy:

- Manual 15-day trial
- Tester name and date tracked manually
- DMG shared privately
- Feedback requested before trial ends

Future trial strategy:

- License key activation
- Online validation
- Graceful offline behavior
- Clear expired-trial messaging

## Important License Note

Trial reset prevention should not rely only on easily deleted local files.

The early prototype should not spend too much effort on anti-crack protection.

The main value of PortVoice should be:

- Useful accessibility
- Trust
- Support
- Updates
- Community feedback

## Feedback Strategy

Before deciding final defaults, collect feedback about:

- Notification detail level
- Duplicate announcements
- Spoken wording
- Voice language
- Install flow
- Uninstall flow
- Start at login
- Menu bar behavior

## Notification Mode Decision

Do not force one style on every user.

Planned modes:

- Simple: speak the most useful final announcement
- Full: speak every detected event
- Simple: wait briefly and speak the best available event

Default mode should be chosen after tester feedback.

## Uninstall Requirement

Every tester build should include a clear uninstall path.

Minimum requirement:

- Manual uninstall instructions
- uninstall-portvoice.sh support script

Future requirement:

- In-app uninstall help
- Support guide for full cleanup

## Release Readiness Checklist

Before public release:

- App icon
- About window
- Menu bar mode
- Start at login
- Notification modes
- Cleaner DMG experience
- Tested uninstall flow
- Basic documentation
- License/trial decision
- Notarization plan

## Product Principle

PortVoice is built from blind Mac user experience and designed as a universal accessibility utility for everyone.

The product should not become a reduced or separate experience for disabled users.

The goal is equal confidence when using the same Mac ecosystem.
