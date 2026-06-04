# PortVoice Menu Bar Plan

## Goal

PortVoice should support menu bar mode so it can run quietly without always showing the main dashboard window.

This is important before implementing background launch at login.

## Product Name

Internal nickname:

- the menu bar

Meaning:

- Menu bar controller for PortVoice

## Why Menu Bar Mode Matters

If PortVoice starts in the background at login, the user still needs a simple way to control it.

The user should be able to:

- Show the main dashboard
- Enable or disable PortVoice
- Check current notification mode
- Quit PortVoice
- Later: change Simple / Full mode
- Later: open About PortVoice

## Expected Behavior

When PortVoice is running:

- It may show a menu bar item.
- The menu bar item should not be visual-only.
- VoiceOver should be able to read it clearly.
- The dashboard should not be forced open when running in background.

## Initial Menu Items

Minimum first version:

- Show PortVoice
- Enable PortVoice / Disable PortVoice
- Quit PortVoice

Future menu items:

- Notification Mode: Simple
- Notification Mode: Full
- Start in background at login
- About PortVoice
- Open Uninstall Help

## Accessibility Requirement

The menu bar item must be usable with VoiceOver.

Recommended accessible label:

- PortVoice

Recommended menu item names:

- Show PortVoice
- Enable PortVoice
- Disable PortVoice
- Quit PortVoice

Avoid icon-only controls without accessible names.

## Relationship to Start at Login

Start in background at login should depend on Menu Bar Mode.

Reason:

If PortVoice starts silently at login, the user must still have a discoverable control point.

Menu Bar Mode becomes that control point.

## Shared Mac Use Case

For a shared family Mac:

- The blind user can enable PortVoice when needed.
- PortVoice can run quietly.
- A family member can quit or disable it from the menu bar if needed.
- No uninstall is required just because another person uses the Mac.

## Success Condition

PortVoice can run without forcing the main dashboard to appear, while still giving the user a VoiceOver-accessible way to show, disable, or quit the app.
