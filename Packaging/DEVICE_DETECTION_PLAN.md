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
