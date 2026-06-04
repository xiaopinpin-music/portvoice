# PortVoice App Packaging Plan

## Goal

Turn the working PortVoice Swift prototype into a normal macOS app.

## Current Working Prototype

Confirmed working with:

- swift run
- USB connected announcement
- USB disconnected announcement
- Storage volume name announcement
- Example: Cadangan connected

## Packaging Target

Create:

- PortVoice.app
- DMG installer
- Drag to Applications install flow

## Recommended Path

Use an Xcode macOS app project for packaging while preserving the current working Swift source files.

## Rules

- Do not break the current Swift Package prototype.
- Keep `swift run` working.
- Add app packaging gradually.
- Test after every packaging step.

## Next Technical Steps

1. Create Xcode macOS app project structure.
2. Reuse existing files from `Sources/PortVoice`.
3. Build `PortVoice.app`.
4. Test app launch without Terminal.
5. Create DMG.
6. Test drag-to-Applications install flow.

## Success Condition

A tester can open PortVoice like a normal Mac app and hear device announcements without using Terminal.
