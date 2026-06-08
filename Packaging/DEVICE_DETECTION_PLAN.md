# PortVoice Device Detection Plan

## Goal

Make PortVoice more useful for non-storage devices without overpromising exact model names.

## Current Confirmed Scope

PortVoice v0.8.0 is strongest for storage volumes that appear in Finder.

Examples:

- External SSD
- External hard drive
- USB flash drive
- Memory card
- NVMe enclosure
- Any mounted storage volume where macOS provides a volume name

When macOS provides a volume name, PortVoice can announce that name.

## Non-Storage Devices

Some connected devices do not appear as Finder volumes.

Examples:

- iPhone
- MIDI keyboard
- Audio interface
- Yamaha / Korg / Roland / Akai controllers
- HDMI adapter
- LAN adapter
- Other USB accessories

These devices may appear through different macOS systems:

- USB device tree
- Audio device list
- MIDI system
- Network interface list
- Display system

## Product Rule

Do not promise exact device model names for every connected device.

Safe behavior:

- If macOS provides a reliable storage volume name, announce the volume name.
- If a generic device connection is detected, announce a generic device event.
- Avoid brand/model-specific promises unless detection has been tested.

## Safe Public Wording

PortVoice announces storage volume names when macOS provides them.

For other connected devices, PortVoice may announce generic connection events such as Device connected or Device disconnected.

## Notification Modes

### Simple Mode

Speaks the most useful storage volume name when macOS provides one.

Useful for:

- External SSD
- Hard drive
- Flash drive
- Memory card
- NVMe enclosure
- Finder-mounted storage devices

### Full Mode

Speaks generic device events and storage volume names when macOS provides them.

Useful for users who want more connection feedback.

## Future V0.9.0 Direction

Add universal non-storage device detection:

- Generic USB device connected
- Generic USB device disconnected
- Audio device connected
- Audio device disconnected
- MIDI device connected
- MIDI device disconnected
- Phone/device detection if macOS exposes it reliably

## Accessibility Requirement

Announcements must be fast.

A connection announcement should happen as soon as macOS exposes the device event.

PortVoice should not wait too long, because the purpose is to confirm that a device was detected.

## V0.9 Product Decision

PortVoice should not depend on brand-specific device names.

Reason:

Different users may connect different devices:

- iPhone
- Yamaha
- Korg
- Roland
- Akai
- MIDI controllers
- Audio interfaces
- HDMI adapters
- LAN adapters
- USB hubs
- Other USB accessories

A brand-specific approach would be fragile and incomplete.

## Universal Detection Rule

For V0.9, prefer universal behavior:

- Finder-mounted storage volume:
  announce the volume name when macOS provides one.

- Non-storage USB or connected device:
  announce a generic event such as Device connected or Device disconnected.

## User Expectation

Do not promise that PortVoice can always speak the exact product name.

Safe promise:

PortVoice confirms that a relevant device connection or disconnection was detected.

## Example

External SSD or flash drive with a volume name:

- My Drive connected
- My Drive disconnected

Non-storage device:

- Device connected
- Device disconnected

## Future Intelligence

Exact categories can be added later if stable:

- Audio device connected
- MIDI device connected
- Phone connected
- Network adapter connected
- Display adapter connected

## Dashboard Window Issue

Observed issue:

- After background launch, choosing Show PortVoice from the menu bar may still expose a confusing window-group behavior instead of reliably opening the full dashboard.
- Opening the app manually can follow the same state because the app is already running in background mode.

Accessibility impact:

- This is confusing for VoiceOver users.
- The dashboard must open as a real, complete, VoiceOver-readable window when the user chooses Show PortVoice from the menu bar.
- The background menu bar utility must remain active after closing the dashboard.

Decision:

Do not solve this with rushed window patches.

Preferred future direction:

- Design a proper dashboard window lifecycle.
- Keep background startup clean.
- Keep the menu bar utility running independently.
- Make Show PortVoice reliably open one complete dashboard window.
- Avoid empty windows or confusing window groups.

Public terminology:

- Use menu bar, not internal nicknames.
- Use dashboard for the main UI.
