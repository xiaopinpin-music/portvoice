# PortVoice Start at Login Plan

## Goal

PortVoice should support optional start at login behavior.

This must be user-controlled, not forced.

## Product Decision

Add a checkbox or toggle:

- Start in background at login

When enabled:

- PortVoice opens automatically when the user logs into macOS.

When disabled:

- PortVoice does not open automatically.
- The user can still open PortVoice manually.

## Why It Must Be Optional

Some users share a Mac with family members, parents, siblings, or coworkers.

In that situation, PortVoice should not force itself to start for everyone.

A blind user may want PortVoice active when they use the Mac, but another family member may not need spoken USB announcements.

Optional start at login avoids forcing uninstall or complicated cleanup.

## Difference from Enable / Disable

### Enable / Disable

Controls whether PortVoice is currently listening and speaking.

### Start in background at login

Controls whether PortVoice automatically opens when the user logs in.

These are different settings and should not be merged.

## Accessibility Requirement

The setting must be clear with VoiceOver.

Recommended label:

- Start in background at login

Recommended hint:

- When enabled, PortVoice opens automatically after you log into your Mac.

## Future Behavior

When menu bar mode exists, Start in background at login should probably launch PortVoice quietly in the menu bar.

Until menu bar mode exists, it may open the normal PortVoice window.

## Shared Mac Use Case

Example:

A blind user shares a MacBook with family.

The blind user can enable PortVoice when needed.

When the Mac returns to a parent or sibling, PortVoice can be disabled or not started automatically.

The user should not need to uninstall PortVoice just because another person uses the Mac.

## Success Condition

A user can choose whether PortVoice starts automatically at login without making the Mac confusing for other users.

## Background Launch Requirement

When Start in background at login is enabled, PortVoice should launch without opening the main dashboard window.

Expected behavior:

- User logs into macOS.
- PortVoice starts silently in the background.
- Device monitoring starts automatically.
- The main window does not appear.
- Spoken device announcements still work.

The dashboard should only appear when the user manually opens PortVoice or chooses to show the window from a future menu bar item.

## Reason

The goal is to make PortVoice helpful without being visually or behaviorally intrusive.

This is especially important for shared Macs used by family members.

PortVoice should not force the main window to appear every time the Mac starts.
