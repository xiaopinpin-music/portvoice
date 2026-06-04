# PortVoice Universal Build Plan

## Goal

PortVoice should eventually ship as one universal macOS app that supports both Apple Silicon and Intel Macs.

The preferred public release target is one DMG file that works for both architectures.

## Preferred User Experience

The user should not need to choose between:

- Apple Silicon build
- Intel build

The preferred download should be:

- PortVoice-universal.dmg

This is simpler for blind users, non-technical users, family users, and general Mac users.

## Preferred Strategy

Use one main repository and one shared codebase.

Avoid creating separate long-term repositories such as:

- portvoice-intel
- portvoice-silicon

Reason:

Separate repositories can cause:

- duplicated work
- missing bug fixes
- version confusion
- different documentation
- inconsistent releases

## Preferred Build Output

Best public release target:

- PortVoice universal DMG

Example:

- PortVoice-1.0.0-universal.dmg

## Fallback Build Outputs

If universal build is not ready, provide separate builds only as a temporary fallback:

- PortVoice-1.0.0-apple-silicon.dmg
- PortVoice-1.0.0-intel.dmg

This should not be the preferred long-term release style.

## Minimum macOS Target

Future compatibility target:

- macOS 12 Monterey or newer

Reason:

Many blind users, low-vision users, Indonesian users, and older Mac users still use Intel Macs and macOS Monterey.

## Current Alpha Status

Current V0.5 Internal Alpha is tested on:

- Apple Silicon Mac
- macOS 14 or newer

Intel support is planned but not guaranteed yet.

## Technical Work Needed

Future work should test:

- SwiftUI compatibility on macOS 12
- USB monitoring compatibility on macOS 12
- Storage volume monitoring compatibility on macOS 12
- Speech output compatibility on macOS 12
- Universal binary build process
- DMG packaging for universal app

## Product Rule

Do not advertise Intel or Monterey support until tested.

Safe wording for now:

PortVoice V0.5 Internal Alpha is tested on Apple Silicon Mac with macOS 14 or newer. Future public builds aim to support one universal DMG for macOS 12 Monterey or newer on both Apple Silicon and Intel Macs.
