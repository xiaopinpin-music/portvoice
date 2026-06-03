# PortVoice Product Definition

## Product Summary

PortVoice is a small macOS accessibility application that announces device connection and disconnection events for blind and VoiceOver users.

The first goal is simple: when a USB device or display is connected or disconnected, the Mac should speak immediately so the user does not need to guess what happened.

## Primary Users

PortVoice is designed primarily for:

- Blind macOS users
- VoiceOver users
- Low-vision users
- Musicians, creators, students, and professionals who frequently connect external devices

## Core Problem

Blind Mac users often cannot visually confirm whether a device has been connected, disconnected, mounted, or recognized.

Common examples:

- USB flash drive connected
- External SSD connected
- Audio interface connected
- MIDI controller connected
- HDMI or external display connected
- Device disconnected unexpectedly

Without clear audio feedback, the user may need to manually inspect Finder, System Settings, VoiceOver focus, or other tools just to confirm a basic hardware event.

## V0.1 Scope

Allowed in V0.1:

- USB connected announcement
- USB disconnected announcement
- Basic speech output
- Simple accessible app window
- Enable / Disable switch
- Basic status text

Not allowed in V0.1:

- Licensing system
- Trial system
- Payment system
- Google login
- Cloud account
- Device brand recognition
- Custom aliases
- Complex settings
- Database

## Accessibility Principles

PortVoice must be VoiceOver-friendly from the beginning.

Important principles:

- Every button and switch must have clear accessibility labels.
- The app must be usable without sight.
- The interface must stay simple.
- Spoken announcements must be clear and not too long.
- The app should not spam repeated announcements unnecessarily.

## Future Business Model

Possible future plan:

- 15-day trial
- Early adopter price: an early-supporter price
- Regular price: a standard price
- One-time purchase
- Lifetime updates

This business model is not part of V0.1 and must not block the prototype.

## Mascot

PortVoice may use a rooster or chicken mascot in future branding.

The product name should remain professional, while the mascot can make the project memorable and friendly.

Possible mascot concept:

- ChickenPort Rooster
- A rooster that announces device connection events
- Optional future Chicken Mode for fun sound feedback

## Mission

Make macOS device connection feedback more accessible for blind users.
